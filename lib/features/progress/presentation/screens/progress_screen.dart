import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../domain/entities/progress_models.dart';
import '../providers/progress_providers.dart';
import '../widgets/progress_widgets.dart';

/// The user's personal recovery analytics.
class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final stats = ref.watch(progressStatsProvider).valueOrNull ??
        ProgressStats.empty();
    final moods = ref.watch(moodHistoryProvider).valueOrNull ?? const [];
    final journalCount = ref.watch(journalCountProvider).valueOrNull ?? 0;
    final avgMood = ref.watch(averageMoodProvider);

    final recentScores = stats.scoreHistory.length > 7
        ? stats.scoreHistory.sublist(stats.scoreHistory.length - 7)
        : stats.scoreHistory;
    final milestones = buildMilestones(stats: stats, journalCount: journalCount);

    return Scaffold(
      appBar: AppBar(title: const Text('Your Progress')),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.md),
        children: [
          // Recovery score hero.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSizes.lg),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary,
                  Color.lerp(colorScheme.primary, Colors.black, 0.35)!,
                ],
              ),
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            ),
            child: Column(
              children: [
                Text('Recovery Score',
                    style: textTheme.labelLarge?.copyWith(color: Colors.white70)),
                const SizedBox(height: AppSizes.xs),
                Text('${stats.recoveryScore}',
                    style: textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    )),
                if (stats.scoreDelta != 0)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        stats.scoreDelta > 0
                            ? Icons.arrow_upward_rounded
                            : Icons.arrow_downward_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                      Text(
                        '${stats.scoreDelta.abs()} points',
                        style: textTheme.labelSmall?.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                const SizedBox(height: AppSizes.md),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Day ${stats.currentDay} of ${stats.totalDays}',
                      style: textTheme.bodySmall?.copyWith(color: Colors.white)),
                ),
                const SizedBox(height: AppSizes.xs),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                  child: LinearProgressIndicator(
                    value: stats.programProgress,
                    minHeight: 8,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.md),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSizes.md,
            crossAxisSpacing: AppSizes.md,
            childAspectRatio: 1.6,
            children: [
              ProgressStatTile(
                icon: Icons.local_fire_department_rounded,
                value: '${stats.streak}',
                label: 'Day Streak',
                color: const Color(0xFFF5A623),
              ),
              ProgressStatTile(
                icon: Icons.check_circle_rounded,
                value: '${stats.completedTasks}',
                label: 'Tasks Done',
                color: const Color(0xFF2E9E63),
              ),
              ProgressStatTile(
                icon: Icons.menu_book_rounded,
                value: '$journalCount',
                label: 'Journal Entries',
                color: const Color(0xFF3D9BE9),
              ),
              ProgressStatTile(
                icon: Icons.favorite_rounded,
                value: avgMood == 0 ? '—' : '${avgMood.toStringAsFixed(1)}/10',
                label: 'Avg Mood',
                color: const Color(0xFFE0576B),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          PSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Recovery Score Trend', style: textTheme.titleMedium),
                const SizedBox(height: AppSizes.md),
                ProgressLineChart(
                  values: recentScores.map((s) => s.score).toList(),
                  labels: recentScores
                      .map((s) => DateFormat('E').format(s.date).substring(0, 1))
                      .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.md),
          PSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mood Trend', style: textTheme.titleMedium),
                const SizedBox(height: AppSizes.md),
                ProgressLineChart(
                  values: moods.map((m) => m.score).toList(),
                  labels: moods.map((m) => m.emoji).toList(),
                  color: const Color(0xFFE0576B),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.md),
          PSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Milestones', style: textTheme.titleMedium),
                const SizedBox(height: AppSizes.xs),
                for (final m in milestones) MilestoneTile(milestone: m),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
