import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../providers/admin_providers.dart';
import '../widgets/admin_charts.dart';
import '../widgets/admin_widgets.dart';

/// Colours for the four recovery-score bands, low → high.
const List<Color> _bandColors = [
  Color(0xFFE0576B),
  Color(0xFFF59E0B),
  Color(0xFF9F7AEA),
  Color(0xFF10B981),
];

/// Read-only recovery-progress analytics across all users. Reuses the existing
/// `users/{uid}` recovery fields and `journal_entries` — no new data.
class ProgressView extends ConsumerWidget {
  const ProgressView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final p = ref.watch(progressAnalyticsProvider).valueOrNull;
    final buckets = p?.scoreBuckets ?? const [];
    final bucketTotal = buckets.fold<int>(0, (a, b) => a + b.count);

    return ListView(
      padding: const EdgeInsets.all(AppSizes.md),
      children: [
        MetricGrid(
          tiles: [
            MetricTile(
                icon: Icons.favorite_rounded,
                value: (p?.averageRecoveryScore ?? 0).toStringAsFixed(1),
                label: 'Avg Recovery Score',
                color: const Color(0xFFE0576B)),
            MetricTile(
                icon: Icons.local_fire_department_rounded,
                value: (p?.averageStreak ?? 0).toStringAsFixed(1),
                label: 'Avg Streak (days)',
                color: const Color(0xFFF59E0B)),
            MetricTile(
                icon: Icons.calendar_today_rounded,
                value: (p?.averageDay ?? 0).toStringAsFixed(1),
                label: 'Avg Program Day',
                color: colorScheme.primary),
            MetricTile(
                icon: Icons.menu_book_rounded,
                value: '${p?.journalEntries ?? 0}',
                label: 'Journal Entries',
                color: const Color(0xFF2E9E63)),
          ],
        ),
        const SizedBox(height: AppSizes.md),
        ACard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Recovery Score Distribution',
                  style: textTheme.titleMedium),
              const SizedBox(height: 2),
              Text('How many users sit in each score band',
                  style: textTheme.bodySmall
                      ?.copyWith(color: colorScheme.onSurfaceVariant)),
              const SizedBox(height: AppSizes.md),
              if (bucketTotal == 0)
                Text('No user data yet.', style: textTheme.bodySmall)
              else
                StatBars(
                  items: [
                    for (var i = 0; i < buckets.length; i++)
                      (
                        buckets[i].label,
                        buckets[i].count,
                        _bandColors[i % _bandColors.length]
                      ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}
