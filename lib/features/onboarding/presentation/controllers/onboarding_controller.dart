import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../data/datasources/onboarding_draft_local_data_source.dart';
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
  /// Whether the notifier is still mounted. Guards state writes that resolve
  /// after the flow has navigated away (which disposes this auto-dispose
  /// notifier) — e.g. the completion save finishing after the router redirect.
  bool _active = true;

  @override
  OnboardingState build() {
    _active = true;
    ref.onDispose(() => _active = false);
    _restoreDraft();
    return const OnboardingState();
  }

  String? get _uid => ref.read(currentUserProvider)?.id;

  /// Hydrates any locally-saved draft so a mid-flow app restart resumes where
  /// the user left off. Only fills fields that are still unset.
  Future<void> _restoreDraft() async {
    final uid = _uid;
    if (uid == null) return;
    final draft =
        await ref.read(onboardingDraftLocalDataSourceProvider).load(uid);
    if (draft == null || draft.isEmpty || !_active) return;
    state = state.copyWith(
      problem: draft.problem,
      breakupTiming: draft.breakupTiming,
      hurtMost: draft.hurtMost,
      goal: draft.goal,
    );
  }

  /// Persists the current selections locally (fire-and-forget; the store
  /// swallows its own errors).
  void _saveDraft() {
    final uid = _uid;
    if (uid == null) return;
    final s = state;
    ref.read(onboardingDraftLocalDataSourceProvider).save(
          uid,
          OnboardingDraft(
            problem: s.problem,
            breakupTiming: s.breakupTiming,
            hurtMost: s.hurtMost,
            goal: s.goal,
          ),
        );
  }

  void selectProblem(OnboardingProblem value) {
    state = state.copyWith(problem: value);
    _saveDraft();
  }

  void selectTiming(BreakupTiming value) {
    state = state.copyWith(breakupTiming: value);
    _saveDraft();
  }

  void selectHurtMost(HurtMost value) {
    state = state.copyWith(hurtMost: value);
    _saveDraft();
  }

  void selectGoal(OnboardingGoal value) {
    state = state.copyWith(goal: value);
    _saveDraft();
  }

  /// A deterministic "recovery score" derived from all four answers. This
  /// stands in for the (not-yet-built) AI analysis so the plan screen shows a
  /// stable, personalized number: base 40 plus small contributions from the
  /// recovery stage (Q1), goal (Q3), current pain (Q2) and focus area (problem).
  int get recoveryScore {
    final timing = switch (state.breakupTiming) {
      BreakupTiming.lessThan1Month => 6,
      BreakupTiming.oneToThreeMonths => 12,
      BreakupTiming.threeToSixMonths => 18,
      BreakupTiming.moreThanSixMonths => 24,
      null => 0,
    };
    final goal = switch (state.goal) {
      OnboardingGoal.moveOn => 14,
      OnboardingGoal.healFeelBetter => 13,
      OnboardingGoal.buildBetterMe => 12,
      OnboardingGoal.getExBack => 8,
      null => 0,
    };
    final hurt = switch (state.hurtMost) {
      HurtMost.missingThem => 10,
      HurtMost.memories => 9,
      HurtMost.loneliness => 8,
      HurtMost.future => 7,
      null => 0,
    };
    final problem = switch (state.problem) {
      OnboardingProblem.breakupRecovery => 8,
      OnboardingProblem.anxietyStress => 7,
      OnboardingProblem.lowConfidence => 7,
      OnboardingProblem.overthinking => 7,
    };
    return (40 + timing + goal + hurt + problem).clamp(0, 100);
  }

  /// Encouraging caption shown under the recovery score, tiered by score.
  String get recoveryCaption {
    final s = recoveryScore;
    if (s < 60) return "Let's begin 💜";
    if (s < 75) return 'Good Start! Keep going 💜';
    if (s < 87) return "You're making progress 💜";
    return "You're on your way 💜";
  }

  /// The four personalized plan priorities, one per answer dimension, in order:
  /// current pain (Q2), goal (Q3), focus area (problem), recovery stage (Q1).
  List<String> get topPriorities => [
        switch (state.hurtMost) {
          HurtMost.missingThem => 'Let go of painful attachments',
          HurtMost.memories => 'Let go of painful memories',
          HurtMost.loneliness => 'Rebuild connection & self-worth',
          HurtMost.future => 'Create a positive future outlook',
          null => 'Let go of painful memories',
        },
        switch (state.goal) {
          OnboardingGoal.moveOn => 'Move forward with closure',
          OnboardingGoal.healFeelBetter => 'Heal your emotional pain',
          OnboardingGoal.buildBetterMe => 'Build self-love & confidence',
          OnboardingGoal.getExBack => 'Find clarity before deciding',
          null => 'Heal your emotional pain',
        },
        switch (state.problem) {
          OnboardingProblem.breakupRecovery => 'Follow your 30-day recovery plan',
          OnboardingProblem.anxietyStress => 'Calm anxiety & manage stress',
          OnboardingProblem.lowConfidence => 'Strengthen self-worth',
          OnboardingProblem.overthinking => 'Quiet overthinking',
        },
        switch (state.breakupTiming) {
          BreakupTiming.lessThan1Month => 'Stabilize sleep & daily routine',
          BreakupTiming.oneToThreeMonths => 'Process emotions steadily',
          BreakupTiming.threeToSixMonths => 'Reinforce healthy habits',
          BreakupTiming.moreThanSixMonths => 'Grow beyond the breakup',
          null => 'Reinforce healthy habits',
        },
      ];

  /// Persists all answers and marks onboarding complete. Returns `true` on
  /// success. On failure the error is surfaced through [OnboardingState.submission].
  Future<bool> complete() async {
    final uid = ref.read(currentUserProvider)?.id;
    if (uid == null || !state.hasAllAnswers) return false;

    // Captured before the await so nothing touches `ref` after a successful
    // completion disposes this notifier via the router redirect.
    final draftStore = ref.read(onboardingDraftLocalDataSourceProvider);
    final completeUseCase = ref.read(completeOnboardingProvider);

    state = state.copyWith(submission: const AsyncLoading());
    final answers = OnboardingAnswers(
      problem: state.problem,
      breakupTiming: state.breakupTiming!,
      hurtMost: state.hurtMost!,
      goal: state.goal!,
    );
    final result = await completeUseCase.call(uid: uid, answers: answers);

    return result.when(
      success: (_) {
        // The local draft is no longer needed once answers are persisted.
        draftStore.clear(uid);
        // The redirect into the app may already have disposed this notifier;
        // only write state while still mounted.
        if (_active) {
          state = state.copyWith(submission: const AsyncData(null));
        }
        return true;
      },
      failure: (failure) {
        if (_active) {
          state = state.copyWith(
            submission: AsyncError(failure, StackTrace.current),
          );
        }
        return false;
      },
    );
  }
}

final onboardingControllerProvider =
    AutoDisposeNotifierProvider<OnboardingController, OnboardingState>(
  OnboardingController.new,
);
