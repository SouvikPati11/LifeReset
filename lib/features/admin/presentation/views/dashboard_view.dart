import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../domain/entities/admin_models.dart';
import '../providers/admin_providers.dart';
import '../widgets/admin_charts.dart';
import '../widgets/admin_widgets.dart';

/// Distinct colours for the recovery-area donut, in enum order.
const List<Color> _problemColors = [
  Color(0xFF7C3AED), // primary
  Color(0xFF9F7AEA), // primary soft
  Color(0xFF10B981), // success / mint
  Color(0xFFF59E0B), // amber
];

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
    final problems =
        ref.watch(problemDistributionProvider).valueOrNull ?? const [];

    return ListView(
      padding: const EdgeInsets.all(AppSizes.md),
      children: [
        Text('Welcome back, Admin 👋', style: textTheme.headlineSmall),
        const SizedBox(height: AppSizes.md),
        LayoutBuilder(
          builder: (context, c) {
            // 4-across on desktop, 2×2 on tablet/mobile, with a fixed tile
            // height so content never overflows at narrow widths.
            final cols = c.maxWidth >= 900 ? 4 : 2;
            final tileW = (c.maxWidth - (cols - 1) * AppSizes.md) / cols;
            const tileH = 156.0;
            return GridView.count(
              crossAxisCount: cols,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppSizes.md,
              crossAxisSpacing: AppSizes.md,
              childAspectRatio: tileW / tileH,
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
            );
          },
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
              Text('Users by Problem Category', style: textTheme.titleMedium),
              const SizedBox(height: 2),
              Text('Distribution across recovery areas',
                  style: textTheme.bodySmall
                      ?.copyWith(color: colorScheme.onSurfaceVariant)),
              const SizedBox(height: AppSizes.md),
              _ProblemDistributionChart(problems: problems),
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

/// Read-only donut + legend of users grouped by onboarding recovery area.
class _ProblemDistributionChart extends StatelessWidget {
  const _ProblemDistributionChart({required this.problems});

  final List<ProblemDistribution> problems;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final total = problems.fold<int>(0, (a, p) => a + p.count);
    if (total == 0) {
      return Text('No user data yet.', style: textTheme.bodySmall);
    }

    final donut = AdminDonut(
      segments: [
        for (var i = 0; i < problems.length; i++)
          (_problemColors[i % _problemColors.length], problems[i].count),
      ],
      centerValue: '$total',
      centerLabel: 'Users',
    );
    final legend = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < problems.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSizes.sm),
          _ProblemLegendRow(
            color: _problemColors[i % _problemColors.length],
            label: problems[i].label,
            count: problems[i].count,
            pct: problems[i].count / total,
          ),
        ],
      ],
    );

    return LayoutBuilder(
      builder: (context, c) {
        // Stack the donut over the legend when the card is very narrow.
        if (c.maxWidth < 360) {
          return Column(
            children: [donut, const SizedBox(height: AppSizes.md), legend],
          );
        }
        return Row(
          children: [
            donut,
            const SizedBox(width: AppSizes.lg),
            Expanded(child: legend),
          ],
        );
      },
    );
  }
}

class _ProblemLegendRow extends StatelessWidget {
  const _ProblemLegendRow({
    required this.color,
    required this.label,
    required this.count,
    required this.pct,
  });

  final Color color;
  final String label;
  final int count;
  final double pct;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSizes.sm),
        Expanded(
          child: Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodyMedium),
        ),
        Text('$count', style: textTheme.titleSmall),
        const SizedBox(width: 6),
        Text('(${(pct * 100).round()}%)',
            style: textTheme.labelSmall
                ?.copyWith(color: colorScheme.onSurfaceVariant)),
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
