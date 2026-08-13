import 'package:flutter/material.dart';

import '../../../profile/presentation/screens/profile_home_screen.dart';

/// Hosts the Profile tab inside its own [Navigator].
///
/// Pushing within Profile (personal information, settings, subscription,
/// payment methods, notifications) then renders inside the tab's body, so the
/// app shell's bottom navigation stays visible and the Profile tab stays
/// selected. Mirrors the Plan / Journey tab navigators.
class ProfileTabNavigator extends StatefulWidget {
  const ProfileTabNavigator({super.key});

  @override
  State<ProfileTabNavigator> createState() => _ProfileTabNavigatorState();
}

class _ProfileTabNavigatorState extends State<ProfileTabNavigator> {
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
          builder: (_) => const ProfileHomeScreen(),
        ),
      ),
    );
  }
}
