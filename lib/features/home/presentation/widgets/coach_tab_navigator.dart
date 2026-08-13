import 'package:flutter/material.dart';

import '../../../coach/presentation/screens/coach_home_screen.dart';

/// Hosts the Coach tab inside its own [Navigator].
///
/// Pushing within Coach (conversation history, suggested actions) then renders
/// inside the tab's body, so the app shell's bottom navigation stays visible and
/// the Coach tab stays selected. Mirrors the Plan / Journey tab navigators.
///
/// The AI chat itself is intentionally opened on the root navigator
/// (full-screen) for a roomier, keyboard-safe conversation — see
/// [CoachHomeScreen].
class CoachTabNavigator extends StatefulWidget {
  const CoachTabNavigator({super.key});

  @override
  State<CoachTabNavigator> createState() => _CoachTabNavigatorState();
}

class _CoachTabNavigatorState extends State<CoachTabNavigator> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return NavigatorPopHandler(
      onPopWithResult: (_) {
        final navigator = _navigatorKey.currentState;
        if (navigator != null && navigator.canPop()) navigator.pop();
      },
      child: Navigator(
        key: _navigatorKey,
        onGenerateRoute: (settings) => MaterialPageRoute(
          settings: settings,
          builder: (_) => const CoachHomeScreen(),
        ),
      ),
    );
  }
}
