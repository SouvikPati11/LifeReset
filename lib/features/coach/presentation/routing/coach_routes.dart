import 'package:go_router/go_router.dart';

import '../../../../routing/app_routes.dart';
import '../screens/coach_home_screen.dart';

/// The AI Coach route, exposed as a plug-in list.
///
/// The module is self-contained: [CoachHomeScreen] is the entry point and the
/// chat / suggested-actions / conversation-list screens are pushed with the
/// local [Navigator] (with Hero transitions), so no change to the app router is
/// required. To surface it from the shell's Coach tab, drop [CoachHomeScreen]
/// into that tab, or spread [coachRoutes] into the app's `GoRouter`.
final List<RouteBase> coachRoutes = [
  GoRoute(
    path: AppRoutes.coach,
    name: AppRoutes.coachName,
    builder: (context, state) => const CoachHomeScreen(),
  ),
];
