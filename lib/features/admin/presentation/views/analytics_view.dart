import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../providers/admin_providers.dart';
import '../widgets/admin_charts.dart';
import '../widgets/admin_widgets.dart';

class AnalyticsView extends ConsumerWidget {
  const AnalyticsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final analytics = ref.watch(analyticsProvider).valueOrNull;
    final activity = ref.watch(signupActivityProvider).valueOrNull ?? const [];

    return ListView(
      padding: const EdgeInsets.all(AppSizes.md),
      children: [
        Text('Analytics', style: textTheme.titleLarge),
        const SizedBox(height: AppSizes.md),
        MetricGrid(
          tiles: [
            MetricTile(
              icon: Icons.today_rounded,
              value: '${analytics?.dailyActiveUsers ?? 0}',
              label: 'Daily Active Users',
            ),
            MetricTile(
              icon: Icons.calendar_month_rounded,
              value: '${analytics?.monthlyActiveUsers ?? 0}',
              label: 'Monthly Active Users',
              color: colorScheme.tertiary,
            ),
            MetricTile(
              icon: Icons.favorite_rounded,
              value: (analytics?.averageRecoveryScore ?? 0).toStringAsFixed(1),
              label: 'Avg Recovery Score',
              color: const Color(0xFFE0576B),
            ),
            MetricTile(
              icon: Icons.menu_book_rounded,
              value: '${analytics?.journalCount ?? 0}',
              label: 'Journal Entries',
              color: const Color(0xFF2E9E63),
            ),
            MetricTile(
              icon: Icons.smart_toy_rounded,
              value: '${analytics?.aiUsage ?? 0}',
              label: 'AI Conversations',
              color: const Color(0xFF7C4DFF),
            ),
            MetricTile(
              icon: Icons.trending_up_rounded,
              value:
                  '${((analytics?.conversionRate ?? 0) * 100).toStringAsFixed(1)}%',
              label: 'Conversion Rate',
              color: const Color(0xFFE0A800),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.md),
        ACard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Activity Trend', style: textTheme.titleMedium),
              const SizedBox(height: AppSizes.md),
              AdminLineChart(
                values: activity.map((a) => a.count).toList(),
                labels: const [],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
