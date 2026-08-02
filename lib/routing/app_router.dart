import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/onboarding/presentation/splash_screen.dart';
import 'app_routes.dart';

/// Provides the application's [GoRouter].
///
/// In this foundation build only the splash route is registered. Feature
/// modules will add their own routes here (or via typed route extensions) as
/// they are implemented, and authentication/onboarding redirects will be wired
/// through GoRouter's `redirect` callback once those flows exist.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: AppRoutes.splashName,
        builder: (context, state) => const SplashScreen(),
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
