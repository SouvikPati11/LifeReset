import 'package:go_router/go_router.dart';

import '../../../../routing/app_routes.dart';
import '../screens/journal_home_screen.dart';

/// The Journal & Mood route, exposed as a plug-in list.
///
/// The module is self-contained: [JournalHomeScreen] is the entry point and the
/// composer / detail / mood-check / prompts screens are pushed with the local
/// [Navigator]. To surface it, drop [JournalHomeScreen] into the shell's
/// "Journey" tab, or spread [journalRoutes] into the app's `GoRouter`.
final List<RouteBase> journalRoutes = [
  GoRoute(
    path: AppRoutes.journal,
    name: AppRoutes.journalName,
    builder: (context, state) => const JournalHomeScreen(),
  ),
];
