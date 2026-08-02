import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/admin/presentation/admin_dashboard_screen.dart';
import '../features/authentication/presentation/providers/auth_providers.dart';
import '../features/authentication/presentation/providers/user_providers.dart';
import '../features/authentication/presentation/screens/auth_routes.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/onboarding/presentation/providers/onboarding_providers.dart';
import '../features/onboarding/presentation/routing/onboarding_routes.dart';
import '../features/onboarding/presentation/splash_screen.dart';
import 'app_routes.dart';

/// Provides the application's [GoRouter].
///
/// [OnboardingAwareRedirect] composes the authentication guard with the
/// onboarding gate via `redirect` (auto-login, email verification, role-based
/// routing, and show-onboarding-once), and the router is refreshed whenever the
/// auth state, the user's Firestore profile, or the onboarding status changes.
final routerProvider = Provider<GoRouter>((ref) {
  // Auth guard + onboarding gate, composed so onboarding shows exactly once.
  final guard = OnboardingAwareRedirect(ref);

  // Re-run the redirect whenever auth state, profile, or onboarding status
  // changes.
  final refresh = ValueNotifier<int>(0);
  ref
    ..listen(authStateChangesProvider, (_, __) => refresh.value++)
    ..listen(userProfileProvider, (_, __) => refresh.value++)
    ..listen(onboardingStatusProvider, (_, __) => refresh.value++)
    ..onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    refreshListenable: refresh,
    redirect: guard.redirect,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: AppRoutes.splashName,
        builder: (context, state) => const SplashScreen(),
      ),
      ...authRoutes,
      ...onboardingRoutes,
      GoRoute(
        path: AppRoutes.home,
        name: AppRoutes.homeName,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.admin,
        name: AppRoutes.adminName,
        builder: (context, state) => const AdminDashboardScreen(),
      ),
    ],
    errorBuilder: (context, state) => _RouteErrorScreen(error: state.error),
  );
});

class _RouteErrorScreen extends StatelessWidget {
  const _RouteErrorScreen({required this.error});

  final Exception? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            error?.toString() ?? 'Page not found',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ),
    );
  }
}
