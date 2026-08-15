import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../providers/admin_providers.dart';
import '../widgets/admin_charts.dart';
import '../widgets/admin_widgets.dart';

/// Colour per mood, warmest (great) to coolest (awful).
const Map<String, Color> _moodColors = {
  'great': Color(0xFF10B981),
  'good': Color(0xFF7C3AED),
  'okay': Color(0xFF9F7AEA),
  'anxious': Color(0xFFF59E0B),
  'sad': Color(0xFF6366F1),
  'awful': Color(0xFFE0576B),
};

/// Read-only analytics for user daily mood check-ins (`mood_history`).
class DailyTrackingView extends ConsumerWidget {
  const DailyTrackingView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final t = ref.watch(trackingAnalyticsProvider).valueOrNull;
    final moods = t?.moods ?? const [];
    final moodTotal = moods.fold<int>(0, (a, m) => a + m.count);

    return ListView(
      padding: const EdgeInsets.all(AppSizes.md),
      children: [
        MetricGrid(
          tiles: [
            MetricTile(
                icon: Icons.mood_rounded,
                value: '${t?.totalCheckIns ?? 0}',
                label: 'Total Check-ins'),
            MetricTile(
                icon: Icons.today_rounded,
                value: '${t?.checkInsToday ?? 0}',
                label: 'Check-ins Today',
                color: colorScheme.tertiary),
            MetricTile(
                icon: Icons.date_range_rounded,
                value: '${t?.checkIns7d ?? 0}',
                label: 'Last 7 Days',
                color: const Color(0xFF2E9E63)),
          ],
        ),
        const SizedBox(height: AppSizes.md),
        ACard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Mood Distribution', style: textTheme.titleMedium),
              const SizedBox(height: 2),
              Text('Across all recorded check-ins',
                  style: textTheme.bodySmall
                      ?.copyWith(color: colorScheme.onSurfaceVariant)),
              const SizedBox(height: AppSizes.md),
              if (moodTotal == 0)
                Text('No check-ins yet.', style: textTheme.bodySmall)
              else
                StatBars(
                  items: [
                    for (final m in moods)
                      (
                        '${m.emoji} ${m.label}',
                        m.count,
                        _moodColors[m.key] ?? colorScheme.primary
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
