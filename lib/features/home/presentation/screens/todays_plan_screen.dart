import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../domain/entities/daily_quote.dart';
import '../../domain/entities/daily_task.dart';
import '../../domain/entities/recovery_program.dart';
import '../../domain/entities/user_stats.dart';
import '../providers/home_providers.dart';
import '../widgets/home_style.dart';

/// The full "Plan" tab: the user's current-day, admin-authored recovery tasks
/// with completion toggles that save immediately.
///
/// Shares the Home dashboard's visual language ([HomeStyle]) and its data
/// providers — the same day-based `program_tasks` source and the same
/// completion mechanism (`users/{uid}.completedTasks`). No new data, no AI.
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
              const SnackBar(content: Text('Could not save. Please try again.')),
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
      backgroundColor: HomeStyle.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.lg,
            AppSizes.md,
            AppSizes.lg,
            AppSizes.xl,
          ),
          children: [
            _Header(showBack: Navigator.of(context).canPop()),
            const SizedBox(height: AppSizes.lg),
            _ProgressBanner(
              currentDay: stats.currentDay,
              totalDays: program.totalDays <= 0 ? 30 : program.totalDays,
            ),
            const SizedBox(height: AppSizes.lg),
            _AsyncSection<List<DailyTask>>(
              value: tasksAsync,
              skeletonHeight: 260,
              onRetry: () => ref.invalidate(dailyTasksProvider),
              builder: (tasks) {
                if (tasks.isEmpty) return const _PlanEmptyState();
                final done =
                    tasks.where((t) => stats.isTaskCompleted(t.id)).length;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DayHeader(
                      day: stats.currentDay,
                      total: tasks.length,
                      done: done,
                    ),
                    const SizedBox(height: AppSizes.sm),
                    for (var i = 0; i < tasks.length; i++) ...[
                      if (i != 0) const SizedBox(height: AppSizes.sm),
                      _PlanTaskRow(
                        task: tasks[i],
                        completed: stats.isTaskCompleted(tasks[i].id),
                        onToggle: (v) => _toggle(ref, context, tasks[i].id, v),
                      ),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: AppSizes.lg),
            const _InsightCard(),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header + progress banner
// ─────────────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.showBack});

  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (showBack) ...[
          _CircleButton(
            onTap: () => Navigator.of(context).maybePop(),
            child: const Icon(Icons.arrow_back_rounded,
                color: HomeStyle.ink, size: 22),
          ),
          const SizedBox(width: AppSizes.md),
        ],
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Today's Plan",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: HomeStyle.ink,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Small steps, one day at a time.',
                style: TextStyle(fontSize: 14, color: HomeStyle.inkSoft),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: HomeStyle.card,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(width: 44, height: 44, child: Center(child: child)),
      ),
    );
  }
}

class _ProgressBanner extends StatelessWidget {
  const _ProgressBanner({required this.currentDay, required this.totalDays});

  final int currentDay;
  final int totalDays;

  @override
  Widget build(BuildContext context) {
    final percent = (currentDay / totalDays).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        gradient: HomeStyle.scoreGradient,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: HomeStyle.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Day $currentDay of $totalDays',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Text(
                '${(percent * 100).round()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusPill),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: percent),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 9,
                backgroundColor: Colors.white.withValues(alpha: 0.25),
                valueColor: const AlwaysStoppedAnimation(Colors.white),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.md),
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded,
                  color: Colors.white, size: 18),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Text(
                  "Keep going — you're doing great.",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.95),
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.day, required this.total, required this.done});

  final int day;
  final int total;
  final int done;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            "Today's Plan",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: HomeStyle.ink,
            ),
          ),
        ),
        const SizedBox(width: AppSizes.sm),
        Text(
          'Day $day • $done/$total done',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: HomeStyle.primary,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Task row (Home-consistent)
// ─────────────────────────────────────────────────────────────────────────────

class _PlanTaskRow extends StatelessWidget {
  const _PlanTaskRow({
    required this.task,
    required this.completed,
    required this.onToggle,
  });

  final DailyTask task;
  final bool completed;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: completed ? 0.6 : 1,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: HomeStyle.card,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: HomeStyle.border),
        ),
        child: Row(
          children: [
            _CheckDot(completed: completed, onToggle: onToggle),
            const SizedBox(width: AppSizes.md),
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: HomeStyle.lavenderLight,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Icon(_iconFor(task), color: HomeStyle.primary, size: 20),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: HomeStyle.ink,
                      decoration:
                          completed ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (task.description.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      task.description,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: HomeStyle.inkSoft,
                        height: 1.3,
                      ),
                    ),
                  ],
                  if (task.duration.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.schedule_rounded,
                            size: 13, color: HomeStyle.inkSoft),
                        const SizedBox(width: 4),
                        Text(
                          task.duration,
                          style: const TextStyle(
                            fontSize: 12,
                            color: HomeStyle.inkSoft,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(DailyTask task) {
    final key = (task.iconKey ?? task.title).toLowerCase();
    if (key.contains('breath') || key.contains('calm')) {
      return Icons.self_improvement_rounded;
    }
    if (key.contains('journal') || key.contains('write') || key.contains('let')) {
      return Icons.edit_note_rounded;
    }
    if (key.contains('reflect') || key.contains('morning')) {
      return Icons.wb_sunny_rounded;
    }
    if (key.contains('walk')) return Icons.directions_walk_rounded;
    if (key.contains('read')) return Icons.menu_book_rounded;
    if (key.contains('care') || key.contains('self')) {
      return Icons.volunteer_activism_rounded;
    }
    if (key.contains('mood')) return Icons.mood_rounded;
    return Icons.spa_rounded;
  }
}

class _CheckDot extends StatelessWidget {
  const _CheckDot({required this.completed, required this.onToggle});

  final bool completed;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onToggle(!completed),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 26,
        height: 26,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: completed ? HomeStyle.success : Colors.transparent,
          border: Border.all(
            color: completed ? HomeStyle.success : HomeStyle.primarySoft,
            width: 2,
          ),
        ),
        child: completed
            ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
            : null,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Daily insight, states
// ─────────────────────────────────────────────────────────────────────────────

class _InsightCard extends ConsumerWidget {
  const _InsightCard();

  static String _author(String? author) {
    final a = (author ?? '').trim();
    if (a.isEmpty || a.toLowerCase() == 'unknown') return 'LifeReset';
    return a;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quote = ref.watch(dailyQuoteProvider).valueOrNull ?? DailyQuote.fallback;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: HomeStyle.insightBg,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: HomeStyle.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded,
                  size: 16, color: HomeStyle.primary),
              const SizedBox(width: 6),
              Text(
                'DAILY INSIGHT',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: HomeStyle.primaryDeep.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          Text(
            '“${quote.text}”',
            style: const TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w600,
              color: HomeStyle.ink,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            '— ${_author(quote.author)}',
            style: const TextStyle(
              fontSize: 13,
              color: HomeStyle.inkSoft,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Graceful empty state — no admin tasks configured for the current day. Does
/// not imply AI generation.
class _PlanEmptyState extends StatelessWidget {
  const _PlanEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.lg,
        vertical: AppSizes.xl,
      ),
      decoration: BoxDecoration(
        color: HomeStyle.lavenderLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: HomeStyle.border),
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: HomeStyle.lavender,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.event_available_rounded,
                color: HomeStyle.primary, size: 24),
          ),
          const SizedBox(height: AppSizes.md),
          const Text(
            'No tasks for today yet.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w700,
              color: HomeStyle.ink,
            ),
          ),
          const SizedBox(height: AppSizes.xs),
          const Text(
            'Check back soon — new recovery activities are added regularly.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: HomeStyle.inkSoft, height: 1.35),
          ),
        ],
      ),
    );
  }
}

class _AsyncSection<T> extends StatelessWidget {
  const _AsyncSection({
    required this.value,
    required this.builder,
    required this.skeletonHeight,
    required this.onRetry,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) builder;
  final double skeletonHeight;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (value.hasValue) return builder(value.requireValue);
    if (value.isLoading) return _SkeletonCard(height: skeletonHeight);
    return _SectionErrorCard(onRetry: onRetry);
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: HomeStyle.lavenderLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: HomeStyle.border),
      ),
      child: const Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.4,
            valueColor: AlwaysStoppedAnimation(HomeStyle.primarySoft),
          ),
        ),
      ),
    );
  }
}

class _SectionErrorCard extends StatelessWidget {
  const _SectionErrorCard({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: HomeStyle.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: HomeStyle.border),
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_rounded, color: HomeStyle.inkSoft),
          const SizedBox(height: AppSizes.sm),
          const Text(
            "Couldn't load your plan.",
            textAlign: TextAlign.center,
            style: TextStyle(color: HomeStyle.ink, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSizes.sm),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(foregroundColor: HomeStyle.primary),
            child: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}
