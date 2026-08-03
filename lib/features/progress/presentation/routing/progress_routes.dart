import 'package:go_router/go_router.dart';

import '../../../../routing/app_routes.dart';
import '../screens/progress_screen.dart';

/// The Progress route, exposed as a plug-in list.
///
/// Self-contained: [ProgressScreen] is the entry point. Surface it by pushing
/// [ProgressScreen] (e.g. from the Home "Progress" quick action), or spread
/// [progressRoutes] into the app's `GoRouter` (the `/progress` path is already
/// reserved in [AppRoutes]).
final List<RouteBase> progressRoutes = [
  GoRoute(
    path: AppRoutes.progress,
    name: AppRoutes.progressName,
    builder: (context, state) => const ProgressScreen(),
  ),
];
