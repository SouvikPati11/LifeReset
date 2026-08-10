import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lifereset/core/errors/failures.dart';
import 'package:lifereset/core/utils/result.dart';
import 'package:lifereset/features/authentication/domain/entities/auth_user.dart';
import 'package:lifereset/features/authentication/domain/entities/user_profile.dart';
import 'package:lifereset/features/authentication/domain/repositories/user_repository.dart';
import 'package:lifereset/features/authentication/presentation/providers/auth_providers.dart';
import 'package:lifereset/features/authentication/presentation/providers/user_providers.dart';
import 'package:lifereset/features/onboarding/domain/entities/onboarding_answers.dart';
import 'package:lifereset/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:lifereset/features/onboarding/presentation/controllers/onboarding_controller.dart';
import 'package:lifereset/features/onboarding/presentation/providers/onboarding_providers.dart';
import 'package:lifereset/features/onboarding/presentation/steps/subscription_step.dart';

/// Records the order of calls so we can assert profile creation happens BEFORE
/// the completion write (the fix for the "stuck on Subscription" bug).
class _FakeUserRepository implements UserRepository {
  _FakeUserRepository({required this.ensureResult, required this.log});

  final Result<void> ensureResult;
  final List<String> log;

  @override
  Future<Result<void>> ensureProfile(AuthUser user) async {
    log.add('ensureProfile');
    return ensureResult;
  }

  @override
  Stream<UserProfile?> watchProfile(String uid) => const Stream.empty();

  @override
  Future<Result<UserProfile?>> getProfile(String uid) async =>
      const Success(null);
}

class _FakeOnboardingRepository implements OnboardingRepository {
  _FakeOnboardingRepository({required this.completeResult, required this.log});

  final Result<void> completeResult;
  final List<String> log;

  @override
  Future<Result<void>> completeOnboarding({
    required String uid,
    required OnboardingAnswers answers,
  }) async {
    log.add('completeOnboarding');
    return completeResult;
  }

  @override
  Stream<bool> watchCompleted(String uid) => Stream.value(false);
}

ProviderContainer _container({
  required List<String> log,
  required Result<void> ensureResult,
  required Result<void> completeResult,
}) {
  const user = AuthUser(
    id: 'u1',
    email: 'a@b.com',
    isEmailVerified: true,
  );
  return ProviderContainer(
    overrides: [
      currentUserProvider.overrideWithValue(user),
      userRepositoryProvider.overrideWithValue(
        _FakeUserRepository(ensureResult: ensureResult, log: log),
      ),
      onboardingRepositoryProvider.overrideWithValue(
        _FakeOnboardingRepository(completeResult: completeResult, log: log),
      ),
    ],
  );
}

/// Fills in all four answers so `hasAllAnswers` is true.
void _answerAll(OnboardingController controller) {
  controller
    ..selectTiming(BreakupTiming.lessThan1Month)
    ..selectHurtMost(HurtMost.missingThem)
    ..selectGoal(OnboardingGoal.moveOn);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('ensures the profile document BEFORE the completion write', () async {
    final log = <String>[];
    final container = _container(
      log: log,
      ensureResult: const Success(null),
      completeResult: const Success(null),
    );
    addTearDown(container.dispose);

    final controller = container.read(onboardingControllerProvider.notifier);
    _answerAll(controller);

    final ok = await controller.complete();

    expect(ok, isTrue);
    // The profile must be guaranteed first so the merge write is a valid update.
    expect(log, ['ensureProfile', 'completeOnboarding']);
  });

  test('does NOT write completion when profile creation fails', () async {
    final log = <String>[];
    final container = _container(
      log: log,
      ensureResult: const FailureResult(ServerFailure('permission-denied')),
      completeResult: const Success(null),
    );
    addTearDown(container.dispose);

    final controller = container.read(onboardingControllerProvider.notifier);
    _answerAll(controller);

    final ok = await controller.complete();

    expect(ok, isFalse);
    // Completion write is never attempted if the profile can't be ensured.
    expect(log, ['ensureProfile']);
  });

  test('surfaces the real failure (not a generic message) on write error',
      () async {
    final log = <String>[];
    final container = _container(
      log: log,
      ensureResult: const Success(null),
      completeResult: const FailureResult(
        ServerFailure('Missing or insufficient permissions.',
            code: 'permission-denied'),
      ),
    );
    addTearDown(container.dispose);

    final controller = container.read(onboardingControllerProvider.notifier);
    _answerAll(controller);

    final ok = await controller.complete();

    expect(ok, isFalse);
    final submission =
        container.read(onboardingControllerProvider).submission;
    final failure = submission.whenOrNull(error: (e, _) => e);
    expect(failure, isA<ServerFailure>());
    expect((failure as ServerFailure).message,
        'Missing or insufficient permissions.');
    expect(failure.code, 'permission-denied');
  });

  test('returns false without writing when answers are incomplete', () async {
    final log = <String>[];
    final container = _container(
      log: log,
      ensureResult: const Success(null),
      completeResult: const Success(null),
    );
    addTearDown(container.dispose);

    final controller = container.read(onboardingControllerProvider.notifier);
    controller.selectTiming(BreakupTiming.lessThan1Month); // only one answer

    final ok = await controller.complete();

    expect(ok, isFalse);
    expect(log, isEmpty);
  });

  testWidgets('tapping "Skip" drives the same secure completion path',
      (tester) async {
    final log = <String>[];
    final container = _container(
      log: log,
      ensureResult: const Success(null),
      completeResult: const Success(null),
    );
    addTearDown(container.dispose);

    // Answer everything so the completion is allowed to run.
    _answerAll(container.read(onboardingControllerProvider.notifier));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: SubscriptionStep())),
      ),
    );

    expect(find.text('Skip'), findsOneWidget);
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    // Skip must persist completion through ensureProfile + the completion write
    // (never a local-only flag), same as Start Free Trial. subscription is never
    // written, so it stays `free`.
    expect(log, ['ensureProfile', 'completeOnboarding']);
  });
}
