import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_sizes.dart';
import '../../authentication/presentation/controllers/auth_controller.dart';
import '../../authentication/presentation/providers/user_providers.dart';
import 'views/admin_users_view.dart';
import 'views/analytics_view.dart';
import 'views/content_pages_view.dart';
import 'views/dashboard_view.dart';
import 'views/daily_tasks_view.dart';
import 'views/faqs_view.dart';
import 'views/notifications_view.dart';
import 'views/problems_view.dart';
import 'views/programs_view.dart';
import 'views/prompts_view.dart';
import 'views/quotes_view.dart';
import 'views/reports_view.dart';
import 'views/roles_permissions_view.dart';
import 'views/settings_view.dart';
import 'views/subscriptions_view.dart';
import 'views/system_logs_view.dart';
import 'views/users_view.dart';
import 'widgets/admin_shell.dart';
import 'widgets/admin_style.dart';

/// The grouped admin navigation, matching the SaaS sidebar layout.
final List<AdminNavGroup> _groups = [
  const AdminNavGroup(null, [
    AdminNavItem('Dashboard', Icons.dashboard_rounded, DashboardView.new,
        subtitle: "Here's what's happening with LifeReset today."),
  ]),
  const AdminNavGroup('MANAGEMENT', [
    AdminNavItem('Users', Icons.people_alt_rounded, UsersView.new,
        subtitle: 'Browse and manage user accounts.'),
    AdminNavItem('Problems', Icons.category_rounded, ProblemsView.new,
        subtitle: 'Recovery-area distribution (read-only).'),
    AdminNavItem('AI Habit Plans', Icons.self_improvement_rounded,
        ProgramsView.new,
        subtitle: 'Recovery programs and their daily plans.'),
    AdminNavItem('Daily Tasks', Icons.checklist_rounded, DailyTasksView.new,
        subtitle: 'Per-day tasks inside each plan.'),
    AdminNavItem('Journal Prompts', Icons.edit_note_rounded, PromptsView.new,
        subtitle: 'Reflective prompts for journaling.'),
    AdminNavItem('Daily Quotes', Icons.format_quote_rounded, QuotesView.new,
        subtitle: 'Motivational quotes shown to users.'),
    AdminNavItem('Notifications', Icons.notifications_rounded,
        NotificationsView.new,
        subtitle: 'Scheduled and broadcast messages.'),
    AdminNavItem('Analytics', Icons.insights_rounded, AnalyticsView.new,
        subtitle: 'Engagement and usage metrics.'),
    AdminNavItem('Subscriptions', Icons.workspace_premium_rounded,
        SubscriptionsView.new,
        subtitle: 'Plans, trials and revenue.'),
    AdminNavItem('Reports', Icons.assessment_rounded, ReportsView.new,
        subtitle: 'Exportable summaries.'),
  ]),
  const AdminNavGroup('CONTENT', [
    AdminNavItem('FAQs', Icons.quiz_rounded, FaqsView.new,
        subtitle: 'Help Center questions and answers.'),
    AdminNavItem('Content Pages', Icons.article_rounded, ContentPagesView.new,
        subtitle: 'Terms of Service and Help Center.'),
  ]),
  const AdminNavGroup('SETTINGS', [
    AdminNavItem('App Settings', Icons.settings_rounded, SettingsView.new,
        subtitle: 'General configuration and support info.'),
    AdminNavItem('Admin Users', Icons.admin_panel_settings_rounded,
        AdminUsersView.new,
        subtitle: 'Manage administrator access.'),
    AdminNavItem('Roles & Permissions', Icons.key_rounded,
        RolesPermissionsView.new,
        subtitle: 'Role-based access control.'),
    AdminNavItem('System Logs', Icons.receipt_long_rounded, SystemLogsView.new,
        subtitle: 'Audit trail of admin actions.'),
  ]),
];

/// A flat, index-addressable view of every section across the groups.
final List<AdminNavItem> _flat = [
  for (final g in _groups) ...g.items,
];

/// Admin Panel entry point and navigation shell.
///
/// Reached only when the signed-in user's server-side role resolves to
/// `admin` (enforced by the route guard). A responsive purple SaaS shell:
/// a permanent sidebar on desktop, an icon rail on tablet, and a drawer on
/// mobile. Every section still renders through its existing view.
class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  int _index = 0;

  void _signOut() => ref.read(authControllerProvider.notifier).signOut();

  @override
  Widget build(BuildContext context) {
    final item = _flat[_index];
    final email = ref.watch(userProfileProvider).valueOrNull?.email ?? '';

    return Theme(
      data: AdminStyle.theme(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final isDesktop = w >= AppSizes.tabletBreakpoint;
          final isTablet =
              w >= AppSizes.mobileBreakpoint && w < AppSizes.tabletBreakpoint;
          final hasDrawer = !isDesktop; // mobile + tablet

          final drawer = hasDrawer
              ? Drawer(
                  backgroundColor: AdminStyle.sidebarBg,
                  child: SafeArea(
                    child: AdminSidebar(
                      groups: _groups,
                      selected: _index,
                      email: email,
                      onSelect: (i) {
                        setState(() => _index = i);
                        Navigator.pop(context);
                      },
                      onSignOut: _signOut,
                    ),
                  ),
                )
              : null;

          return Scaffold(
            backgroundColor: AdminStyle.canvas,
            drawer: drawer,
            body: SafeArea(
              child: Row(
                children: [
                  if (isDesktop)
                    AdminSidebar(
                      groups: _groups,
                      selected: _index,
                      email: email,
                      onSelect: (i) => setState(() => _index = i),
                      onSignOut: _signOut,
                    ),
                  if (isTablet)
                    AdminRail(
                      groups: _groups,
                      selected: _index,
                      onSelect: (i) => setState(() => _index = i),
                      onSignOut: _signOut,
                    ),
                  Expanded(
                    child: Column(
                      children: [
                        Builder(
                          builder: (context) => AdminTopBar(
                            title: item.title,
                            subtitle: item.subtitle,
                            onMenu: hasDrawer
                                ? () => Scaffold.of(context).openDrawer()
                                : null,
                          ),
                        ),
                        Expanded(child: item.builder()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
