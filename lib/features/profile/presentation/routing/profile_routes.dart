import 'package:go_router/go_router.dart';

import '../../../../routing/app_routes.dart';
import '../screens/profile_home_screen.dart';

/// The Profile & Subscription route, exposed as a plug-in list.
///
/// Self-contained: [ProfileHomeScreen] is the entry point and the edit /
/// subscription / choose-plan / payment / settings screens are pushed with the
/// local [Navigator]. Drop [ProfileHomeScreen] into the shell's Profile tab, or
/// spread [profileRoutes] into the app's `GoRouter`.
final List<RouteBase> profileRoutes = [
  GoRoute(
    path: AppRoutes.profile,
    name: AppRoutes.profileName,
    builder: (context, state) => const ProfileHomeScreen(),
  ),
];
