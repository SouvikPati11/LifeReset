import 'package:go_router/go_router.dart';

import '../../../../routing/app_routes.dart';
import 'forgot_password_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'verify_email_screen.dart';

/// Route paths and names owned by the authentication feature.
///
/// [login] reuses the shared [AppRoutes.login] constant; the register and
/// password-reset paths are declared here since they are internal to this
/// module.
class AuthRoutePaths {
  const AuthRoutePaths._();

  static const String login = AppRoutes.login;
  static const String loginName = AppRoutes.loginName;

  static const String register = '/auth/register';
  static const String registerName = 'register';

  static const String forgotPassword = '/auth/forgot-password';
  static const String forgotPasswordName = 'forgot-password';

  static const String verifyEmail = '/auth/verify-email';
  static const String verifyEmailName = 'verify-email';
}

/// The authentication routes, exposed as a list so the app router can spread
/// them into its `routes` without this module reaching into shared routing:
///
/// ```dart
/// GoRouter(routes: [
///   ...authRoutes,
///   // other feature routes
/// ]);
/// ```
final List<RouteBase> authRoutes = [
  GoRoute(
    path: AuthRoutePaths.login,
    name: AuthRoutePaths.loginName,
    builder: (context, state) => const LoginScreen(),
  ),
  GoRoute(
    path: AuthRoutePaths.register,
    name: AuthRoutePaths.registerName,
    builder: (context, state) => const RegisterScreen(),
  ),
  GoRoute(
    path: AuthRoutePaths.forgotPassword,
    name: AuthRoutePaths.forgotPasswordName,
    builder: (context, state) => const ForgotPasswordScreen(),
  ),
  GoRoute(
    path: AuthRoutePaths.verifyEmail,
    name: AuthRoutePaths.verifyEmailName,
    builder: (context, state) => const VerifyEmailScreen(),
  ),
];
