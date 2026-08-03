import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_sizes.dart';
import '../providers/admin_providers.dart';
import '../widgets/admin_charts.dart';
import '../widgets/admin_widgets.dart';

class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final stats = ref.watch(dashboardStatsProvider).valueOrNull;
    final activity = ref.watch(signupActivityProvider).valueOrNull ?? const [];
    final topPrograms = ref.watch(topProgramsProvider).valueOrNull ?? const [];
    final recent = ref.watch(recentUsersProvider).valueOrNull ?? const [];
    final system = ref.watch(systemStatusProvider).valueOrNull ?? const [];

    return ListView(
      padding: const EdgeInsets.all(AppSizes.md),
      children: [
        Text("Welcome back, Admin 👋", style: textTheme.headlineSmall),
        Text("Here's what's happening with LifeReset today.",
            style: textTheme.bodySmall
                ?.copyWith(color: colorScheme.onSurfaceVariant)),
        const SizedBox(height: AppSizes.md),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSizes.md,
          crossAxisSpacing: AppSizes.md,
          childAspectRatio: 1.5,
          children: [
            MetricTile(
                icon: Icons.people_alt_rounded,
                value: '${stats?.totalUsers ?? 0}',
                label: 'Total Users'),
            MetricTile(
                icon: Icons.bolt_rounded,
                value: '${stats?.activeToday ?? 0}',
                label: 'Active Today',
                color: colorScheme.tertiary),
            MetricTile(
                icon: Icons.person_add_alt_1_rounded,
                value: '${stats?.newSignups ?? 0}',
                label: 'New Signups',
                color: const Color(0xFF2E9E63)),
            MetricTile(
                icon: Icons.workspace_premium_rounded,
                value: '${stats?.premiumUsers ?? 0}',
                label: 'Premium Users',
                color: const Color(0xFFE0A800)),
          ],
        ),
        const SizedBox(height: AppSizes.md),
        ACard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('User Activity Overview', style: textTheme.titleMedium),
              const SizedBox(height: AppSizes.md),
              AdminLineChart(
                values: activity.map((a) => a.count).toList(),
                labels: activity
                    .map((a) => DateFormat('MMM d').format(a.date))
                    .toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.md),
        ACard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Users by Plan', style: textTheme.titleMedium),
              const SizedBox(height: AppSizes.md),
              Row(
                children: [
                  AdminDonut(
                    segments: [
                      (colorScheme.primary, (stats?.premiumUsers ?? 0)),
                      (const Color(0xFFB39DDB), (stats?.freeUsers ?? 0)),
                    ],
                    centerValue: '${stats?.totalUsers ?? 0}',
                    centerLabel: 'Total',
                  ),
                  const SizedBox(width: AppSizes.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _LegendRow(
                            color: const Color(0xFFB39DDB),
                            label: 'Free',
                            value: '${stats?.freeUsers ?? 0}'),
                        const SizedBox(height: AppSizes.sm),
                        _LegendRow(
                            color: colorScheme.primary,
                            label: 'Premium',
                            value: '${stats?.premiumUsers ?? 0}'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.md),
        ACard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Top Recovery Programs', style: textTheme.titleMedium),
              const SizedBox(height: AppSizes.sm),
              if (topPrograms.isEmpty)
                Text('No programs yet.', style: textTheme.bodySmall)
              else
                for (final p in topPrograms)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor:
                              colorScheme.primaryContainer.withValues(alpha: 0.5),
                          child: Icon(programIcon(p.iconKey),
                              size: 16, color: colorScheme.primary),
                        ),
                        const SizedBox(width: AppSizes.sm),
                        Expanded(child: Text(p.name, style: textTheme.bodyMedium)),
                        Text('${p.userCount} users',
                            style: textTheme.labelSmall),
                      ],
                    ),
                  ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.md),
        ACard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Recent Signups', style: textTheme.titleMedium),
              const SizedBox(height: AppSizes.sm),
              if (recent.isEmpty)
                Text('No signups yet.', style: textTheme.bodySmall)
              else
                for (final u in recent)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          child: Text(
                            (u.name.isEmpty ? '?' : u.name[0]).toUpperCase(),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        const SizedBox(width: AppSizes.sm),
                        Expanded(
                            child: Text(u.name.isEmpty ? u.email : u.name,
                                style: textTheme.bodyMedium)),
                        Text(
                          u.createdAt == null
                              ? ''
                              : DateFormat('MMM d').format(u.createdAt!),
                          style: textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.md),
        ACard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('System Status', style: textTheme.titleMedium),
              const SizedBox(height: AppSizes.sm),
              for (final s in system)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(
                        s.healthy
                            ? Icons.check_circle_rounded
                            : Icons.error_rounded,
                        size: 18,
                        color: s.healthy
                            ? const Color(0xFF2E9E63)
                            : colorScheme.error,
                      ),
                      const SizedBox(width: AppSizes.sm),
                      Expanded(child: Text(s.name, style: textTheme.bodyMedium)),
                      Text(s.healthy ? 'Healthy' : 'Down',
                          style: textTheme.labelSmall?.copyWith(
                            color: s.healthy
                                ? const Color(0xFF2E9E63)
                                : colorScheme.error,
                          )),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow(
      {required this.color, required this.label, required this.value});
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSizes.sm),
        Expanded(child: Text(label, style: textTheme.bodyMedium)),
        Text(value, style: textTheme.titleSmall),
      ],
    );
  }
}
