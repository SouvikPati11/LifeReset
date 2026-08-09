import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lifereset/features/authentication/domain/entities/auth_user.dart';
import 'package:lifereset/features/authentication/domain/entities/user_profile.dart';
import 'package:lifereset/features/onboarding/presentation/routing/onboarding_routes.dart';
import 'package:lifereset/routing/app_routes.dart';

/// Startup / session-restoration routing states for the onboarding gate.
void main() {
  const verified = AuthUser(id: 'u1', email: 'a@b.com', isEmailVerified: true);
  const unverified = AuthUser(id: 'u1', email: 'a@b.com', isEmailVerified: false);
  const userProfile = UserProfile(id: 'u1', name: 'A', email: 'a@b.com');
  const adminProfile = UserProfile(
    id: 'u1',
    name: 'A',
    email: 'a@b.com',
    role: UserRole.admin,
  );

  // Loading / resolved AsyncValues used across the cases.
  const loadingProfile = AsyncLoading<UserProfile?>();
  const loadingOnboarding = AsyncLoading<bool>();

  String? resolve({
    String location = AppRoutes.splash,
    String? authRedirect,
    AuthUser? user,
    AsyncValue<UserProfile?> profileState = const AsyncData(null),
    AsyncValue<bool> onboardingState = const AsyncData(false),
  }) {
    return resolveOnboardingRedirect(
      location: location,
      authRedirect: authRedirect,
      user: user,
      profileState: profileState,
      onboardingState: onboardingState,
    );
  }

  test('logged out → defers to auth guard (login)', () {
    expect(
      resolve(
          location: AppRoutes.splash,
          authRedirect: AuthRoutePathsHelper.login,
          user: null),
      AuthRoutePathsHelper.login,
    );
  });

  test('unverified → defers to auth guard', () {
    expect(
      resolve(authRedirect: '/auth/verify-email', user: unverified),
      '/auth/verify-email',
    );
  });

  test('auth resolved but profile/onboarding still loading → hold on splash',
      () {
    expect(
      resolve(
        location: AppRoutes.splash,
        authRedirect: AppRoutes.splash,
        user: verified,
        profileState: loadingProfile,
        onboardingState: loadingOnboarding,
      ),
      isNull, // already at splash → stay
    );
    expect(
      resolve(
        location: AppRoutes.home,
        authRedirect: AppRoutes.home,
        user: verified,
        profileState: loadingProfile,
        onboardingState: loadingOnboarding,
      ),
      AppRoutes.splash, // elsewhere → go to splash to wait
    );
  });

  test('verified + onboarding NOT completed → onboarding', () {
    expect(
      resolve(
        location: AppRoutes.splash,
        authRedirect: AppRoutes.home,
        user: verified,
        profileState: const AsyncData(userProfile),
        onboardingState: const AsyncData(false),
      ),
      AppRoutes.onboarding,
    );
  });

  test('verified + onboarding completed → home (no onboarding again)', () {
    expect(
      resolve(
        location: AppRoutes.splash,
        authRedirect: AppRoutes.home,
        user: verified,
        profileState: const AsyncData(userProfile),
        onboardingState: const AsyncData(true),
      ),
      AppRoutes.home,
    );
    // Already on /home → stay.
    expect(
      resolve(
        location: AppRoutes.home,
        authRedirect: null,
        user: verified,
        profileState: const AsyncData(userProfile),
        onboardingState: const AsyncData(true),
      ),
      isNull,
    );
  });

  test('completed user re-opening onto /onboarding is bounced to home', () {
    expect(
      resolve(
        location: AppRoutes.onboarding,
        authRedirect: null,
        user: verified,
        profileState: const AsyncData(userProfile),
        onboardingState: const AsyncData(true),
      ),
      AppRoutes.home,
    );
  });

  test('admin → deferred to auth guard (admin dashboard), never onboarding',
      () {
    expect(
      resolve(
        location: AppRoutes.splash,
        authRedirect: AppRoutes.admin,
        user: verified,
        profileState: const AsyncData(adminProfile),
        onboardingState: const AsyncData(false),
      ),
      AppRoutes.admin,
    );
  });

  group('resolved-with-error never pins the app on splash (the stuck bug)', () {
    const err = AsyncError<UserProfile?>('boom', StackTrace.empty);
    const onbErr = AsyncError<bool>('boom', StackTrace.empty);

    test('profile stream error → NOT held on splash, routes to onboarding', () {
      final result = resolve(
        location: AppRoutes.splash,
        authRedirect: AppRoutes.home,
        user: verified,
        profileState: err, // error, not loading
        onboardingState: const AsyncData(false),
      );
      expect(result, isNot(AppRoutes.splash));
      expect(result, AppRoutes.onboarding);
    });

    test('onboarding stream error → NOT held on splash', () {
      final result = resolve(
        location: AppRoutes.home,
        authRedirect: null,
        user: verified,
        profileState: const AsyncData(userProfile),
        onboardingState: onbErr,
      );
      expect(result, isNot(AppRoutes.splash));
      // Falls back to not-completed → onboarding (self-corrects on retry).
      expect(result, AppRoutes.onboarding);
    });
  });
}

/// Small indirection so the test doesn't import the auth route-paths class
/// (kept local to auth); `/auth/login` is the login path.
class AuthRoutePathsHelper {
  static const String login = '/auth/login';
}
