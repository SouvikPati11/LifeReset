import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_sizes.dart';
import '../../authentication/presentation/controllers/auth_controller.dart';
import '../../authentication/presentation/providers/user_providers.dart';
import 'views/analytics_view.dart';
import 'views/dashboard_view.dart';
import 'views/daily_tasks_view.dart';
import 'views/notifications_view.dart';
import 'views/programs_view.dart';
import 'views/prompts_view.dart';
import 'views/quotes_view.dart';
import 'views/reports_view.dart';
import 'views/settings_view.dart';
import 'views/subscriptions_view.dart';
import 'views/users_view.dart';

/// A single admin section entry (drawer label, icon and screen).
class _AdminSection {
  const _AdminSection(this.title, this.icon, this.builder);
  final String title;
  final IconData icon;
  final Widget Function() builder;
}

const List<_AdminSection> _sections = [
  _AdminSection('Dashboard', Icons.dashboard_rounded, DashboardView.new),
  _AdminSection('Users', Icons.people_alt_rounded, UsersView.new),
  _AdminSection('Programs', Icons.self_improvement_rounded, ProgramsView.new),
  _AdminSection('Daily Tasks', Icons.checklist_rounded, DailyTasksView.new),
  _AdminSection('Journal Prompts', Icons.edit_note_rounded, PromptsView.new),
  _AdminSection('Daily Quotes', Icons.format_quote_rounded, QuotesView.new),
  _AdminSection('Notifications', Icons.notifications_rounded, NotificationsView.new),
  _AdminSection('Analytics', Icons.insights_rounded, AnalyticsView.new),
  _AdminSection('Subscriptions', Icons.workspace_premium_rounded, SubscriptionsView.new),
  _AdminSection('Reports', Icons.assessment_rounded, ReportsView.new),
  _AdminSection('Settings', Icons.settings_rounded, SettingsView.new),
];

/// Admin Panel entry point and navigation shell.
///
/// Reached only when the signed-in user's server-side role resolves to
/// `admin` (enforced by the route guard). Hosts every admin section behind a
/// drawer; the selected section is rendered in the body.
class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  int _index = 0;

  void _select(int i) {
    setState(() => _index = i);
    Navigator.pop(context); // close the drawer
  }

  @override
  Widget build(BuildContext context) {
    final section = _sections[_index];
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(section.title)),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSizes.md),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: colorScheme.primaryContainer,
                      child: Icon(Icons.shield_rounded,
                          color: colorScheme.onPrimaryContainer),
                    ),
                    const SizedBox(width: AppSizes.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Administrator', style: textTheme.titleMedium),
                          Text(
                            profile?.email ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
                  children: [
                    for (var i = 0; i < _sections.length; i++)
                      ListTile(
                        leading: Icon(_sections[i].icon),
                        title: Text(_sections[i].title),
                        selected: i == _index,
                        selectedTileColor:
                            colorScheme.primaryContainer.withValues(alpha: 0.3),
                        onTap: () => _select(i),
                      ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.logout_rounded),
                title: const Text('Sign out'),
                onTap: () =>
                    ref.read(authControllerProvider.notifier).signOut(),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(child: section.builder()),
    );
  }
}
