import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lifereset/features/onboarding/data/datasources/onboarding_draft_local_data_source.dart';
import 'package:lifereset/features/onboarding/domain/entities/onboarding_answers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const store = OnboardingDraftLocalDataSource();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('save + load round-trips a partial draft, scoped per uid', () async {
    await store.save(
      'u1',
      const OnboardingDraft(
        problem: OnboardingProblem.breakupRecovery,
        breakupTiming: BreakupTiming.lessThan1Month,
      ),
    );

    final loaded = await store.load('u1');
    expect(loaded, isNotNull);
    expect(loaded!.problem, OnboardingProblem.breakupRecovery);
    expect(loaded.breakupTiming, BreakupTiming.lessThan1Month);
    expect(loaded.hurtMost, isNull);
    expect(loaded.goal, isNull);

    // A different user must not see u1's draft.
    expect(await store.load('u2'), isNull);
  });

  test('load returns null when nothing is saved', () async {
    expect(await store.load('nobody'), isNull);
  });

  test('clear removes the saved draft', () async {
    await store.save('u1', const OnboardingDraft(goal: OnboardingGoal.moveOn));
    expect(await store.load('u1'), isNotNull);

    await store.clear('u1');
    expect(await store.load('u1'), isNull);
  });
}
