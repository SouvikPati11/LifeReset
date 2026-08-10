import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../coach/presentation/screens/coach_home_screen.dart';
import '../../journal/presentation/screens/journal_home_screen.dart';
import '../../profile/presentation/screens/profile_home_screen.dart';
import 'screens/todays_plan_screen.dart';
import 'views/home_dashboard_view.dart';
import 'widgets/home_style.dart';

/// The user app shell: a Material 3 bottom-navigation host.
///
/// Each tab hosts its module's entry screen. Tabs are kept in an
/// [IndexedStack] so each tab preserves its state and scroll position.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _index = 0;

  static const List<NavigationDestination> _destinations = [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home_rounded),
      label: 'Home',
    ),
    NavigationDestination(
      icon: Icon(Icons.event_note_outlined),
      selectedIcon: Icon(Icons.event_note_rounded),
      label: 'Plan',
    ),
    NavigationDestination(
      icon: Icon(Icons.eco_outlined),
      selectedIcon: Icon(Icons.eco_rounded),
      label: 'Journey',
    ),
    NavigationDestination(
      icon: Icon(Icons.forum_outlined),
      selectedIcon: Icon(Icons.forum_rounded),
      label: 'Coach',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline_rounded),
      selectedIcon: Icon(Icons.person_rounded),
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          HomeDashboardView(),
          TodaysPlanScreen(),
          JournalHomeScreen(),
          CoachHomeScreen(),
          ProfileHomeScreen(),
        ],
      ),
      bottomNavigationBar: _wellnessNav(
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (value) => setState(() => _index = value),
          destinations: _destinations,
        ),
      ),
    );
  }

  /// Applies the calm wellness palette (purple active state on a light surface)
  /// to the shared bottom navigation without touching the global app theme.
  Widget _wellnessNav({required Widget child}) {
    return NavigationBarTheme(
      data: NavigationBarThemeData(
        backgroundColor: HomeStyle.card,
        indicatorColor: HomeStyle.lavender,
        surfaceTintColor: Colors.transparent,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? HomeStyle.primary
                : HomeStyle.inkSoft,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: states.contains(WidgetState.selected)
                ? HomeStyle.primary
                : HomeStyle.inkSoft,
          ),
        ),
      ),
      child: child,
    );
  }
}
