import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/app_routes.dart';
import '../providers/auth_providers.dart';
import '../providers/user_providers.dart';
import '../screens/auth_routes.dart';

/// The GoRouter redirect that enforces the authentication flow.
///
/// Precedence, evaluated on every navigation and whenever auth state or the
/// user's profile changes:
///  1. Auth state still resolving → stay on the splash screen.
///  2. Signed out → allow only the auth routes, else go to login.
///  3. Signed in but email unverified → force the verify-email screen.
///  4. Verified but role still loading → stay on splash.
///  5. Verified → route to the admin dashboard or user app based on the
///     server-side role, and keep each area within its role boundary.
///
/// SECURITY: the admin decision comes from [userProfileProvider] (the Firestore
/// document), never from client-held state. Final enforcement lives in
/// Firestore Security Rules.
class AuthGuard {
  const AuthGuard(this._ref);

  final Ref _ref;

  String? redirect(BuildContext context, GoRouterState state) {
    final authState = _ref.read(authStateChangesProvider);
    final location = state.matchedLocation;
    final atSplash = location == AppRoutes.splash;
    final atAuthRoute = location.startsWith('/auth');

    // 1. Wait for the first auth event on the splash screen.
    if (authState.isLoading && !authState.hasValue) {
      return atSplash ? null : AppRoutes.splash;
    }

    final user = authState.valueOrNull;

    // 2. Signed out.
    if (user == null) {
      return atAuthRoute ? null : AuthRoutePaths.login;
    }

    // 3. Signed in but email not verified — block the app.
    if (!user.isEmailVerified) {
      return location == AuthRoutePaths.verifyEmail
          ? null
          : AuthRoutePaths.verifyEmail;
    }

    // 4. Verified — resolve the role from the Firestore profile.
    final profileState = _ref.read(userProfileProvider);
    if (profileState.isLoading && !profileState.hasValue) {
      return atSplash ? null : AppRoutes.splash;
    }
    final isAdmin = profileState.valueOrNull?.isAdmin ?? false;
    final home = isAdmin ? AppRoutes.admin : AppRoutes.home;

    // 5. Coming from splash / auth / verify → land on the right dashboard.
    if (atSplash || atAuthRoute) {
      return home;
    }

    // 6. Keep each role inside its own area.
    final atAdmin = location.startsWith(AppRoutes.admin);
    if (atAdmin && !isAdmin) return AppRoutes.home;
    final atUserApp = location.startsWith(AppRoutes.home);
    if (atUserApp && isAdmin) return AppRoutes.admin;

    return null;
  }
}
