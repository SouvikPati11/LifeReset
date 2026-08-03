import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'views/home_dashboard_view.dart';
import 'widgets/coming_soon_view.dart';

/// The user app shell: a Material 3 bottom-navigation host.
///
/// Only the Home tab is fully implemented (the recovery dashboard); the other
/// tabs are placeholders until their modules are built. Tabs are kept in an
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
          ComingSoonView(title: 'Plan', icon: Icons.event_note_rounded),
          ComingSoonView(title: 'Journey', icon: Icons.eco_rounded),
          ComingSoonView(title: 'Coach', icon: Icons.forum_rounded),
          ComingSoonView(title: 'Profile', icon: Icons.person_rounded),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: _destinations,
      ),
    );
  }
}
