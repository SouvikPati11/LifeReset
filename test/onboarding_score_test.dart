import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lifereset/features/authentication/presentation/providers/auth_providers.dart';
import 'package:lifereset/features/onboarding/domain/entities/onboarding_answers.dart';
import 'package:lifereset/features/onboarding/presentation/controllers/onboarding_controller.dart';

void main() {
  // Override the auth-derived uid so the controller's draft persistence is a
  // no-op (no Firebase / SharedPreferences needed for the pure scoring logic).
  ProviderContainer makeContainer() {
    final c = ProviderContainer(
      overrides: [currentUserProvider.overrideWithValue(null)],
    );
    addTearDown(c.dispose);
    return c;
  }

  OnboardingController seed(
    ProviderContainer c, {
    required OnboardingProblem problem,
    required BreakupTiming timing,
    required HurtMost hurt,
    required OnboardingGoal goal,
  }) {
    final ctrl = c.read(onboardingControllerProvider.notifier);
    ctrl
      ..selectProblem(problem)
      ..selectTiming(timing)
      ..selectHurtMost(hurt)
      ..selectGoal(goal);
    return ctrl;
  }

  test('recovery score uses all four answers (worked example = 78)', () {
    final ctrl = seed(
      makeContainer(),
      problem: OnboardingProblem.breakupRecovery, // 8
      timing: BreakupTiming.lessThan1Month, // 6
      hurt: HurtMost.missingThem, // 10
      goal: OnboardingGoal.moveOn, // 14  -> 40+6+14+10+8
    );
    expect(ctrl.recoveryScore, 78);
  });

  test('score changes when any single answer changes', () {
    final ctrl = seed(
      makeContainer(),
      problem: OnboardingProblem.breakupRecovery,
      timing: BreakupTiming.lessThan1Month,
      hurt: HurtMost.missingThem,
      goal: OnboardingGoal.moveOn,
    );
    final before = ctrl.recoveryScore;
    ctrl.selectHurtMost(HurtMost.future); // 10 -> 7
    expect(ctrl.recoveryScore, before - 3);
  });

  test('score is clamped to 0..100', () {
    final ctrl = seed(
      makeContainer(),
      problem: OnboardingProblem.breakupRecovery, // 8
      timing: BreakupTiming.moreThanSixMonths, // 24
      hurt: HurtMost.missingThem, // 10
      goal: OnboardingGoal.moveOn, // 14 -> 40+24+14+10+8 = 96
    );
    expect(ctrl.recoveryScore, 96);
    expect(ctrl.recoveryScore, inInclusiveRange(0, 100));
  });

  test('caption tiers track the score', () {
    // 78 -> "making progress" tier (75..86).
    final progressing = seed(
      makeContainer(),
      problem: OnboardingProblem.breakupRecovery,
      timing: BreakupTiming.lessThan1Month,
      hurt: HurtMost.missingThem,
      goal: OnboardingGoal.moveOn,
    );
    expect(progressing.recoveryCaption, "You're making progress 💜");

    // 96 -> "on your way" tier (87+).
    final ahead = seed(
      makeContainer(),
      problem: OnboardingProblem.breakupRecovery,
      timing: BreakupTiming.moreThanSixMonths,
      hurt: HurtMost.missingThem,
      goal: OnboardingGoal.moveOn,
    );
    expect(ahead.recoveryCaption, "You're on your way 💜");
  });

  test('four priorities are derived, one per dimension, in order', () {
    final ctrl = seed(
      makeContainer(),
      problem: OnboardingProblem.overthinking,
      timing: BreakupTiming.moreThanSixMonths,
      hurt: HurtMost.loneliness,
      goal: OnboardingGoal.buildBetterMe,
    );
    expect(ctrl.topPriorities, [
      'Rebuild connection & self-worth', // Q2 pain
      'Build self-love & confidence', // Q3 goal
      'Quiet overthinking', // problem
      'Grow beyond the breakup', // Q1 stage
    ]);
  });
}
