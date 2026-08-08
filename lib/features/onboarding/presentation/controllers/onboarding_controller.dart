import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../domain/entities/onboarding_answers.dart';
import '../providers/onboarding_providers.dart';

/// Immutable state for the onboarding wizard: the selected answers plus the
/// async status of the final save.
class OnboardingState {
  const OnboardingState({
    this.problem = OnboardingProblem.breakupRecovery,
    this.breakupTiming,
    this.hurtMost,
    this.goal,
    this.submission = const AsyncData<void>(null),
  });

  final OnboardingProblem problem;
  final BreakupTiming? breakupTiming;
  final HurtMost? hurtMost;
  final OnboardingGoal? goal;
  final AsyncValue<void> submission;

  bool get hasAllAnswers =>
      breakupTiming != null && hurtMost != null && goal != null;

  bool get isSubmitting => submission.isLoading;

  OnboardingState copyWith({
    OnboardingProblem? problem,
    BreakupTiming? breakupTiming,
    HurtMost? hurtMost,
    OnboardingGoal? goal,
    AsyncValue<void>? submission,
  }) {
    return OnboardingState(
      problem: problem ?? this.problem,
      breakupTiming: breakupTiming ?? this.breakupTiming,
      hurtMost: hurtMost ?? this.hurtMost,
      goal: goal ?? this.goal,
      submission: submission ?? this.submission,
    );
  }
}

/// Holds the wizard selections and persists them to Firestore on completion.
///
/// Selections are captured in-memory as the user progresses; nothing is written
/// until [complete] is called on the final (subscription) step, which stores
/// the answers and flips `onboardingCompleted` — at which point the router
/// guard moves the user into the app.
class OnboardingController extends AutoDisposeNotifier<OnboardingState> {
  @override
  OnboardingState build() => const OnboardingState();

  void selectProblem(OnboardingProblem value) =>
      state = state.copyWith(problem: value);

  void selectTiming(BreakupTiming value) =>
      state = state.copyWith(breakupTiming: value);

  void selectHurtMost(HurtMost value) =>
      state = state.copyWith(hurtMost: value);

  void selectGoal(OnboardingGoal value) => state = state.copyWith(goal: value);

  /// A deterministic "recovery score" derived from the answers. This stands in
  /// for the (not-yet-built) AI analysis so the plan screen shows a stable,
  /// personalized-looking number.
  int get recoveryScore {
    final timingBonus = switch (state.breakupTiming) {
      BreakupTiming.lessThan1Month => 4,
      BreakupTiming.oneToThreeMonths => 9,
      BreakupTiming.threeToSixMonths => 15,
      BreakupTiming.moreThanSixMonths => 20,
      null => 0,
    };
    final goalBonus = switch (state.goal) {
      OnboardingGoal.moveOn => 18,
      OnboardingGoal.healFeelBetter => 16,
      OnboardingGoal.buildBetterMe => 14,
      OnboardingGoal.getExBack => 8,
      null => 0,
    };
    return (55 + timingBonus + goalBonus).clamp(0, 100);
  }

  /// Persists all answers and marks onboarding complete. Returns `true` on
  /// success. On failure the error is surfaced through [OnboardingState.submission].
  Future<bool> complete() async {
    final uid = ref.read(currentUserProvider)?.id;
    if (uid == null || !state.hasAllAnswers) return false;

    state = state.copyWith(submission: const AsyncLoading());
    final answers = OnboardingAnswers(
      problem: state.problem,
      breakupTiming: state.breakupTiming!,
      hurtMost: state.hurtMost!,
      goal: state.goal!,
    );
    final result =
        await ref.read(completeOnboardingProvider).call(uid: uid, answers: answers);

    return result.when(
      success: (_) {
        state = state.copyWith(submission: const AsyncData(null));
        return true;
      },
      failure: (failure) {
        state = state.copyWith(
          submission: AsyncError(failure, StackTrace.current),
        );
        return false;
      },
    );
  }
}

final onboardingControllerProvider =
    AutoDisposeNotifierProvider<OnboardingController, OnboardingState>(
  OnboardingController.new,
);
