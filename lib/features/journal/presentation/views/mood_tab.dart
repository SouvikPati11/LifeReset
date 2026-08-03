import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../domain/entities/journal_analytics.dart';
import '../../domain/entities/mood_entry.dart';
import '../../domain/entities/mood_type.dart';
import '../providers/journal_providers.dart';
import '../screens/mood_check_screen.dart';
import '../widgets/journal_widgets.dart';
import '../widgets/mood_calendar.dart';
import '../widgets/mood_charts.dart';
import '../widgets/mood_widgets.dart';

/// Mood tab: analytics (trend, distribution, average), calendar and streak.
class MoodTab extends ConsumerStatefulWidget {
  const MoodTab({super.key});

  @override
  ConsumerState<MoodTab> createState() => _MoodTabState();
}

class _MoodTabState extends ConsumerState<MoodTab> {
  int _period = 0; // 0 = Week, 1 = Month, 2 = 30 Days
  static const _windows = [7, 30, 30];
  static const _labels = ['Week', 'Month', '30 Days'];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final history = ref.watch(moodHistoryProvider).valueOrNull ?? const [];
    final windowDays = _windows[_period];
    final since = DateTime.now().subtract(Duration(days: windowDays));
    final windowed =
        history.where((e) => e.date.isAfter(since)).toList(growable: false);
    final analytics = MoodAnalytics.fromHistory(windowed);

    return ListView(
      padding: const EdgeInsets.all(AppSizes.md),
      children: [
        FilledButton.tonalIcon(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const MoodCheckScreen()),
          ),
          icon: const Icon(Icons.add_reaction_outlined),
          label: const Text('Check in on your mood'),
        ),
        const SizedBox(height: AppSizes.lg),
        _PeriodSelector(
          labels: _labels,
          selected: _period,
          onSelect: (i) => setState(() => _period = i),
        ),
        const SizedBox(height: AppSizes.md),
        JCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Mood Trend', style: textTheme.titleMedium),
              const SizedBox(height: AppSizes.md),
              MoodTrendChart(points: analytics.trend),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.md),
        JCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Mood Distribution', style: textTheme.titleMedium),
              const SizedBox(height: AppSizes.md),
              Row(
                children: [
                  MoodDistributionDonut(
                    distribution: analytics.distribution,
                    averageScore: analytics.averageScore,
                  ),
                  const SizedBox(width: AppSizes.lg),
                  Expanded(child: _Legend(distribution: analytics.distribution)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.md),
        _MoodInsight(history: history),
        const SizedBox(height: AppSizes.md),
        JCard(
          child: MoodCalendar(moodByDay: _moodByDay(history)),
        ),
        const SizedBox(height: AppSizes.md),
        JCard(
          child: Row(
            children: [
              const Text('🔥', style: TextStyle(fontSize: 28)),
              const SizedBox(width: AppSizes.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Current Streak', style: textTheme.labelMedium),
                  Text('${ref.watch(moodAnalyticsProvider).streak} Days',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      )),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Map<DateTime, MoodType> _moodByDay(List<MoodEntry> history) {
    return {
      for (final e in history)
        DateTime(e.date.year, e.date.month, e.date.day): e.mood,
    };
  }
}

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({
    required this.labels,
    required this.selected,
    required this.onSelect,
  });

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onSelect(i),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
                  decoration: BoxDecoration(
                    color: selected == i ? colorScheme.primary : null,
                    borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                  ),
                  child: Text(
                    labels[i],
                    textAlign: TextAlign.center,
                    style: textTheme.labelMedium?.copyWith(
                      color: selected == i
                          ? Colors.white
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.distribution});

  final Map<MoodType, int> distribution;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final total = distribution.values.fold<int>(0, (a, b) => a + b);
    if (total == 0) {
      return Text('No data yet', style: textTheme.bodySmall);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final mood in MoodType.values)
          if ((distribution[mood] ?? 0) > 0)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: moodColor(mood),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(child: Text(mood.label, style: textTheme.bodySmall)),
                  Text(
                    '${(((distribution[mood] ?? 0) / total) * 100).round()}%',
                    style: textTheme.labelSmall,
                  ),
                ],
              ),
            ),
      ],
    );
  }
}

class _MoodInsight extends StatelessWidget {
  const _MoodInsight({required this.history});

  final List<MoodEntry> history;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final message = _insight();
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome_rounded, color: colorScheme.primary),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mood Insights', style: textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(message, style: textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _insight() {
    final now = DateTime.now();
    double avg(Iterable<MoodEntry> xs) {
      final list = xs.toList();
      if (list.isEmpty) return 0;
      return list.map((e) => e.mood.score).reduce((a, b) => a + b) / list.length;
    }

    final thisWeek =
        history.where((e) => e.date.isAfter(now.subtract(const Duration(days: 7))));
    final prevWeek = history.where((e) =>
        e.date.isAfter(now.subtract(const Duration(days: 14))) &&
        e.date.isBefore(now.subtract(const Duration(days: 7))));

    final a = avg(thisWeek);
    final b = avg(prevWeek);
    if (a > 0 && b > 0) {
      final change = ((a - b) / b * 100).round();
      if (change > 0) {
        return 'Your mood has improved by $change% this week! '
            "You're healing and becoming stronger.";
      }
      if (change < 0) {
        return 'This week has been tougher. Be gentle with yourself — recovery '
            "isn't linear.";
      }
    }
    return 'Keep tracking your mood to reveal your trends over time.';
  }
}
