import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/app_routes.dart';
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
    final authRedirect = _authGuard.redirect(context, state);
    final location = state.matchedLocation;
    final onOnboarding = location.startsWith(AppRoutes.onboarding);

    final user = _ref.read(authStateChangesProvider).valueOrNull;
    final profileState = _ref.read(userProfileProvider);
    final onboardingState = _ref.read(onboardingStatusProvider);

    final isAdmin = profileState.valueOrNull?.isAdmin ?? false;

    // Gate every verified, non-admin user — whether or not the profile document
    // object has loaded yet. The onboarding decision comes from the
    // `onboardingCompleted` flag (reliably `false` for a new user), NOT from
    // the presence of the profile object: a brand-new user's `users/{uid}` doc
    // may not exist at this instant, which previously made the gate fall
    // through to the auth guard and leak the user straight to Home.
    final isGateable = user != null && user.isEmailVerified && !isAdmin;

    if (!isGateable) {
      // Not our concern — defer entirely to the auth guard.
      return authRedirect;
    }

    // Hold on the splash screen until BOTH the profile (needed for the admin
    // check) and the onboarding flag resolve, so we never leak the user to Home
    // while the profile doc is still absent/loading, and never briefly treat a
    // still-loading admin as a non-admin.
    if (!profileState.hasValue || !onboardingState.hasValue) {
      final atSplash = location == AppRoutes.splash;
      return (onOnboarding || atSplash) ? null : AppRoutes.splash;
    }
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
}
