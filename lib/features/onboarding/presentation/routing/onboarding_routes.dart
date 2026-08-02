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
    final profile = _ref.read(userProfileProvider).valueOrNull;
    final onboardingState = _ref.read(onboardingStatusProvider);

    // Only verified, non-admin users with a loaded profile are gated.
    final isGateable = user != null &&
        user.isEmailVerified &&
        profile != null &&
        !profile.isAdmin;

    if (!isGateable) {
      // Not our concern — defer entirely to the auth guard.
      return authRedirect;
    }

    // Wait for the onboarding flag before deciding, holding on the splash
    // screen to avoid a flash of the wrong screen.
    if (onboardingState.isLoading && !onboardingState.hasValue) {
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
