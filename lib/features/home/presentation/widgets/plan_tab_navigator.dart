import 'package:flutter/material.dart';

import '../screens/todays_plan_screen.dart';

/// Hosts the Plan tab inside its own [Navigator].
///
/// Pushing within the Plan section (e.g. opening Task Details) then renders
/// inside the tab's body, so the app shell's bottom navigation stays visible
/// and the Plan tab stays selected. Reuses the existing [TodaysPlanScreen] as
/// the tab root — no bottom-navigation redesign, no change to other tabs.
class PlanTabNavigator extends StatefulWidget {
  const PlanTabNavigator({super.key});

  @override
  State<PlanTabNavigator> createState() => _PlanTabNavigatorState();
}

class _PlanTabNavigatorState extends State<PlanTabNavigator> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    // Route the system back button to this nested navigator first, so Task
    // Details pops back to the Plan list instead of exiting the shell.
    return NavigatorPopHandler(
      onPopWithResult: (_) {
        final navigator = _navigatorKey.currentState;
        if (navigator != null && navigator.canPop()) navigator.pop();
      },
      child: Navigator(
        key: _navigatorKey,
        onGenerateRoute: (settings) => MaterialPageRoute(
          settings: settings,
          builder: (_) => const TodaysPlanScreen(),
        ),
      ),
    );
  }
}
