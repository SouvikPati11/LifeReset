import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../domain/entities/journal_analytics.dart';
import '../providers/journal_providers.dart';
import '../screens/prompts_screen.dart';
import '../widgets/journal_widgets.dart';

/// Insights tab: healing progress, derived insights, prompts and a daily
/// reflection checklist.
class InsightsTab extends ConsumerWidget {
  const InsightsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final currentDay = ref.watch(currentDayProvider);
    final analytics = ref.watch(moodAnalyticsProvider);
    final stats = ref.watch(journalStatsProvider);
    final recent = ref.watch(recentEntriesProvider).valueOrNull ?? const [];
    final moodToday = ref.watch(todayMoodProvider).valueOrNull != null;
    final now = DateTime.now();
    final journalToday = recent.any((e) =>
        e.createdAt.year == now.year &&
        e.createdAt.month == now.month &&
        e.createdAt.day == now.day);

    const totalDays = 30;
    final percent = (currentDay / totalDays).clamp(0.0, 1.0);

    return ListView(
      padding: const EdgeInsets.all(AppSizes.md),
      children: [
        _JourneyCard(currentDay: currentDay, totalDays: totalDays, percent: percent),
        const SizedBox(height: AppSizes.md),
        Row(
          children: [
            Expanded(
              child: StatCard(
                value: '${stats.totalEntries}',
                label: 'Journal Entries',
              ),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: StatCard(
                value: '${analytics.totalTracked}',
                label: 'Mood Tracked',
              ),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: StatCard(
                value: '${analytics.streak}',
                label: 'Day Streak',
                valueColor: colorScheme.tertiary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.lg),
        Text('Top Insights', style: textTheme.titleMedium),
        const SizedBox(height: AppSizes.sm),
        JCard(
          child: Column(
            children: [
              for (final line in _insights(stats, analytics))
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.xs),
                  child: Row(
                    children: [
                      Icon(Icons.insights_rounded,
                          size: AppSizes.iconSm, color: colorScheme.primary),
                      const SizedBox(width: AppSizes.sm),
                      Expanded(child: Text(line, style: textTheme.bodyMedium)),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.md),
        JCard(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const PromptsScreen()),
          ),
          child: Row(
            children: [
              Icon(Icons.lightbulb_outline_rounded, color: colorScheme.primary),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Need inspiration?', style: textTheme.titleSmall),
                    Text(
                      'Browse writing prompts to get started.',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.lg),
        _DailyReflection(journalToday: journalToday, moodToday: moodToday),
      ],
    );
  }

  List<String> _insights(JournalStats stats, MoodAnalytics analytics) {
    final list = <String>[
      'You have written ${stats.totalEntries} journal entries so far.',
    ];
    if (analytics.averageScore > 0) {
      list.add(
          'Your average mood is ${analytics.averageScore.toStringAsFixed(1)}/10.');
    }
    if (analytics.streak > 0) {
      list.add('You are on a ${analytics.streak}-day mood-tracking streak.');
    }
    return list;
  }
}

class _JourneyCard extends StatelessWidget {
  const _JourneyCard({
    required this.currentDay,
    required this.totalDays,
    required this.percent,
  });

  final int currentDay;
  final int totalDays;
  final double percent;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final end = Color.lerp(colorScheme.primary, Colors.black, 0.35)!;
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [colorScheme.primary, end]),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('30-Day Journey',
              style: textTheme.titleMedium?.copyWith(color: Colors.white)),
          const SizedBox(height: AppSizes.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$currentDay',
                  style: textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  )),
              Padding(
                padding: const EdgeInsets.only(bottom: 6, left: 4),
                child: Text('of $totalDays days',
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    )),
              ),
              const Spacer(),
              Text('${(percent * 100).round()}% Complete',
                  style: textTheme.titleMedium?.copyWith(color: Colors.white)),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusPill),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyReflection extends StatelessWidget {
  const _DailyReflection({required this.journalToday, required this.moodToday});

  final bool journalToday;
  final bool moodToday;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final items = <(String, bool)>[
      ('Write in Journal', journalToday),
      ('Track your Mood', moodToday),
      ("Complete Today's Tasks", false),
      ('Practice Breathing', false),
      ('Talk to AI Coach', false),
    ];
    final done = items.where((i) => i.$2).length;

    return JCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Daily Reflection', style: textTheme.titleMedium),
          Text('Small steps lead to big changes.',
              style: textTheme.bodySmall
                  ?.copyWith(color: colorScheme.onSurfaceVariant)),
          const SizedBox(height: AppSizes.md),
          for (final (label, checked) in items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.xs),
              child: Row(
                children: [
                  Icon(
                    checked
                        ? Icons.check_circle_rounded
                        : Icons.circle_outlined,
                    color: checked ? colorScheme.primary : colorScheme.outline,
                    size: AppSizes.iconMd,
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Text(
                    label,
                    style: textTheme.bodyMedium?.copyWith(
                      decoration: checked ? TextDecoration.lineThrough : null,
                      color: checked ? colorScheme.onSurfaceVariant : null,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: AppSizes.sm),
          Text('$done of ${items.length} completed',
              style: textTheme.labelSmall
                  ?.copyWith(color: colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
