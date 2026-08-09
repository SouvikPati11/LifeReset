import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/app_routes.dart';
import '../../../authentication/domain/entities/auth_user.dart';
import '../../../authentication/domain/entities/user_profile.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../../authentication/presentation/providers/user_providers.dart';
import '../../../authentication/presentation/routing/auth_guard.dart';
import '../providers/onboarding_providers.dart';
import '../screens/onboarding_flow_screen.dart';

/// The onboarding route (a single hosted wizard).
final List<RouteBase> onboardingRoutes = [
  GoRoute(
    path: AppRoutes.onboarding,
    name: AppRoutes.onboardingName,
    builder: (context, state) => const OnboardingFlowScreen(),
  ),
];

/// Router redirect that layers the onboarding gate on top of the (unchanged)
/// [AuthGuard].
///
/// The auth guard decides the auth flow (login / verify / role-based home).
/// This wrapper adds one rule: a verified, non-admin user who has not completed
/// onboarding is sent through `/onboarding` before reaching the user app, and a
/// user who has completed it is never shown the flow again.
class OnboardingAwareRedirect {
  OnboardingAwareRedirect(Ref ref)
      : _ref = ref,
        _authGuard = AuthGuard(ref);

  final Ref _ref;
  final AuthGuard _authGuard;

  String? redirect(BuildContext context, GoRouterState state) {
    return resolveOnboardingRedirect(
      location: state.matchedLocation,
      authRedirect: _authGuard.redirect(context, state),
      user: _ref.read(authStateChangesProvider).valueOrNull,
      profileState: _ref.read(userProfileProvider),
      onboardingState: _ref.read(onboardingStatusProvider),
    );
  }
}

/// The pure onboarding-gate decision, extracted so the startup routing states
/// can be unit-tested without a live router / Firebase.
///
/// [authRedirect] is the destination the [AuthGuard] already chose (or `null`
/// to stay). This layer only adds the onboarding rule on top of it.
@visibleForTesting
String? resolveOnboardingRedirect({
  required String location,
  required String? authRedirect,
  required AuthUser? user,
  required AsyncValue<UserProfile?> profileState,
  required AsyncValue<bool> onboardingState,
}) {
  final onOnboarding = location.startsWith(AppRoutes.onboarding);
  final isAdmin = profileState.valueOrNull?.isAdmin ?? false;

  // Gate every verified, non-admin user — whether or not the profile document
  // object has loaded yet. The onboarding decision comes from the
  // `onboardingCompleted` flag (reliably `false` for a new user), NOT from the
  // presence of the profile object.
  final isGateable = user != null && user.isEmailVerified && !isAdmin;

  if (!isGateable) {
    // Not our concern — defer entirely to the auth guard.
    return authRedirect;
  }

  // Hold on splash ONLY while the profile / onboarding streams are genuinely
  // loading with no value yet. We must NOT hold on `!hasValue` alone: an
  // `AsyncError` (e.g. a cold-start Firestore token/permission race) also has
  // no value, and waiting for a value it will never produce pins the app on
  // the splash screen forever. Treating "loading" (not "error") as the wait
  // condition — matching AuthGuard — lets an error fall through to a safe
  // decision below, and the Firestore listener recovers on its own retry.
  final profileLoading = profileState.isLoading && !profileState.hasValue;
  final onboardingLoading =
      onboardingState.isLoading && !onboardingState.hasValue;
  if (profileLoading || onboardingLoading) {
    final atSplash = location == AppRoutes.splash;
    return (onOnboarding || atSplash) ? null : AppRoutes.splash;
  }

  // Resolved (data or error). An errored onboarding flag falls back to
  // `false` → onboarding, which self-corrects to Home once the stream recovers.
  final completed = onboardingState.valueOrNull ?? false;

  if (!completed) {
    // Needs onboarding: intercept any push toward the user app, and hold the
    // user on the flow.
    if (authRedirect == AppRoutes.home) return AppRoutes.onboarding;
    if (authRedirect != null) return authRedirect; // still in auth flow
    if (!onOnboarding && location.startsWith(AppRoutes.home)) {
      return AppRoutes.onboarding;
    }
    return null;
  }

  // Completed: never show onboarding again.
  if (onOnboarding) return AppRoutes.home;
  return authRedirect;
}
