import 'package:flutter/material.dart';

import '../../../journal/presentation/screens/journal_home_screen.dart';

/// Hosts the Journey tab inside its own [Navigator].
///
/// Pushing within Journey (journal detail, new journal, mood check, prompts)
/// then renders inside the tab's body, so the app shell's bottom navigation
/// stays visible and the Journey tab stays selected. Mirrors the Plan tab's
/// navigator; reuses the existing [JournalHomeScreen] as the tab root.
class JourneyTabNavigator extends StatefulWidget {
  const JourneyTabNavigator({super.key});

  @override
  State<JourneyTabNavigator> createState() => _JourneyTabNavigatorState();
}

class _JourneyTabNavigatorState extends State<JourneyTabNavigator> {
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
          builder: (_) => const JournalHomeScreen(),
        ),
      ),
    );
  }
}
