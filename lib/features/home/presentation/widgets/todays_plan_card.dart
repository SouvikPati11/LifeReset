import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../domain/entities/daily_task.dart';
import '../../domain/entities/recovery_program.dart';
import '../../domain/entities/user_stats.dart';
import '../providers/home_providers.dart';

/// Hero tag shared between the card's featured task icon and the plan screen.
const String kFeaturedTaskHeroTag = 'featured-task-icon';

/// The "Today's Plan" summary card: the next task, a Start action, and the
/// day/percent progress. Tapping through opens the full plan.
class TodaysPlanCard extends ConsumerWidget {
  const TodaysPlanCard({super.key, required this.onOpenPlan});

  final VoidCallback onOpenPlan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final stats = ref.watch(userStatsProvider).valueOrNull ?? UserStats.initial();
    final tasks = ref.watch(dailyTasksProvider).valueOrNull ?? const <DailyTask>[];
    final program = ref.watch(recoveryProgramProvider).valueOrNull ??
        RecoveryProgram.defaultProgram();

    final featured = _featuredTask(tasks, stats);
    final percent = program.totalDays <= 0
        ? 0.0
        : (stats.currentDay / program.totalDays).clamp(0.0, 1.0);

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
          Row(
            children: [
              Text("Today's Plan", style: textTheme.titleMedium),
              const Spacer(),
              TextButton(onPressed: onOpenPlan, child: const Text('View All')),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          if (featured == null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
              child: Text(
                'No tasks for today yet.',
                style: textTheme.bodyMedium
                    ?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            )
          else
            _FeaturedTask(task: featured, onStart: onOpenPlan),
          const Divider(height: AppSizes.xl),
          Row(
            children: [
              Text(
                'Day ${stats.currentDay} of ${program.totalDays}',
                style: textTheme.titleSmall,
              ),
              const Spacer(),
              Text(
                '${(percent * 100).round()}% Complete',
                style: textTheme.bodySmall
                    ?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusPill),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: percent),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 8,
                backgroundColor: colorScheme.surfaceContainerHighest,
              ),
            ),
          ),
        ],
      ),
    );
  }

  DailyTask? _featuredTask(List<DailyTask> tasks, UserStats stats) {
    if (tasks.isEmpty) return null;
    return tasks.firstWhere(
      (t) => !stats.isTaskCompleted(t.id),
      orElse: () => tasks.first,
    );
  }
}

class _FeaturedTask extends StatelessWidget {
  const _FeaturedTask({required this.task, required this.onStart});

  final DailyTask task;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Hero(
          tag: kFeaturedTaskHeroTag,
          child: Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: Colors.white),
          ),
        ),
        const SizedBox(width: AppSizes.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(task.title, style: textTheme.titleSmall),
              if (task.description.isNotEmpty)
                Text(
                  task.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall
                      ?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
            ],
          ),
        ),
        const SizedBox(width: AppSizes.sm),
        FilledButton(onPressed: onStart, child: const Text('Start')),
      ],
    );
  }
}
