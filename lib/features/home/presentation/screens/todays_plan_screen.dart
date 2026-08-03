import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/empty_view.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../domain/entities/recovery_program.dart';
import '../../domain/entities/user_stats.dart';
import '../providers/home_providers.dart';
import '../widgets/task_tile.dart';
import '../widgets/todays_plan_card.dart';

/// The full Today's Plan screen: the day's tasks with completion toggles that
/// save immediately.
class TodaysPlanScreen extends ConsumerWidget {
  const TodaysPlanScreen({super.key});

  Future<void> _toggle(
    WidgetRef ref,
    BuildContext context,
    String taskId,
    bool completed,
  ) async {
    final uid = ref.read(currentUserProvider)?.id;
    if (uid == null) return;
    final result = await ref
        .read(setTaskCompletedUseCaseProvider)
        .call(uid: uid, taskId: taskId, completed: completed);
    result.when(
      success: (_) {},
      failure: (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(content: Text('Could not save. Try again.')),
            );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(dailyTasksProvider);
    final stats = ref.watch(userStatsProvider).valueOrNull ?? UserStats.initial();
    final program = ref.watch(recoveryProgramProvider).valueOrNull ??
        RecoveryProgram.defaultProgram();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Today's Plan"),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: AppSizes.sm),
            child: Icon(Icons.calendar_month_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: tasksAsync.when(
          loading: () => const LoadingView(),
          error: (_, __) => ErrorView(
            title: 'Could not load your plan',
            onRetry: () => ref.invalidate(dailyTasksProvider),
          ),
          data: (tasks) {
            final percent = program.totalDays <= 0
                ? 0.0
                : (stats.currentDay / program.totalDays).clamp(0.0, 1.0);

            return ListView(
              padding: const EdgeInsets.all(AppSizes.md),
              children: [
                _ProgressHeader(
                  currentDay: stats.currentDay,
                  totalDays: program.totalDays,
                  percent: percent,
                ),
                const SizedBox(height: AppSizes.md),
                if (tasks.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: AppSizes.xl),
                    child: EmptyView(
                      title: 'No tasks for today',
                      message: 'Your plan for today will appear here.',
                      icon: Icons.checklist_rounded,
                    ),
                  )
                else
                  for (var i = 0; i < tasks.length; i++)
                    TaskTile(
                      task: tasks[i],
                      completed: stats.isTaskCompleted(tasks[i].id),
                      heroTag: i == 0 ? kFeaturedTaskHeroTag : null,
                      onToggle: (value) =>
                          _toggle(ref, context, tasks[i].id, value),
                    ),
                const SizedBox(height: AppSizes.md),
                const _QuoteFooter(),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({
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
    final gradientEnd = Color.lerp(colorScheme.primary, Colors.black, 0.35)!;

    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [colorScheme.primary, gradientEnd],
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Day $currentDay of $totalDays',
                style: textTheme.titleMedium?.copyWith(color: Colors.white),
              ),
              const Spacer(),
              Text(
                '${(percent * 100).round()}%',
                style: textTheme.titleMedium?.copyWith(color: Colors.white),
              ),
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
          const SizedBox(height: AppSizes.sm),
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded,
                  color: Colors.white, size: AppSizes.iconSm),
              const SizedBox(width: AppSizes.xs),
              Text(
                "Keep going, you're doing great!",
                style: textTheme.bodySmall?.copyWith(color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuoteFooter extends StatelessWidget {
  const _QuoteFooter();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Row(
        children: [
          Icon(Icons.format_quote_rounded, color: colorScheme.primary),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Text(
              'Small steps lead to big changes over time.',
              style: textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
