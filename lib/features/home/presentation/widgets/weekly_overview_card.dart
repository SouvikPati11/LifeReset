import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../domain/entities/user_stats.dart';
import '../providers/home_providers.dart';
import 'charts.dart';

/// The Weekly Overview card: recovery-score history as a bar chart.
class WeeklyOverviewCard extends ConsumerWidget {
  const WeeklyOverviewCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final history =
        (ref.watch(userStatsProvider).valueOrNull ?? UserStats.initial())
            .scoreHistory;

    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Weekly Overview', style: textTheme.titleSmall),
          const SizedBox(height: AppSizes.md),
          WeeklyBarChart(
            points: history,
            barColor: colorScheme.primary,
            height: 120,
          ),
        ],
      ),
    );
  }
}
