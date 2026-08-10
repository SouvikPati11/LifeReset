import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../domain/entities/daily_task.dart';
import '../../domain/entities/recovery_program.dart';
import '../../domain/entities/user_stats.dart';
import '../providers/home_providers.dart';
import '../providers/plan_providers.dart';
import '../widgets/home_style.dart';
import 'task_detail_screen.dart';

/// The "Plan" tab: the user's day-by-day recovery roadmap.
///
/// Shares the Home dashboard's visual language ([HomeStyle]) and its data —
/// the admin-authored `program_tasks` (via [planTasksProvider], filtered to the
/// selected day) and the same completion mechanism (`users/{uid}.completedTasks`).
/// A day selector lets the user browse any day; the current day is selected by
/// default. No new data, no AI.
class TodaysPlanScreen extends ConsumerStatefulWidget {
  const TodaysPlanScreen({super.key});

  @override
  ConsumerState<TodaysPlanScreen> createState() => _TodaysPlanScreenState();
}

class _TodaysPlanScreenState extends ConsumerState<TodaysPlanScreen> {
  /// The day the user is browsing. `null` means "follow the current day".
  int? _selectedDay;

  Future<void> _toggle(String taskId, bool completed) async {
    final uid = ref.read(currentUserProvider)?.id;
    if (uid == null) return;
    final result = await ref
        .read(setTaskCompletedUseCaseProvider)
        .call(uid: uid, taskId: taskId, completed: completed);
    result.when(
      success: (_) {},
      failure: (_) {
        if (mounted) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(content: Text('Could not save. Please try again.')),
            );
        }
      },
    );
  }

  void _openDetail(DailyTask task) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TaskDetailScreen(task: task)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(userStatsProvider).valueOrNull ?? UserStats.initial();
    final program = ref.watch(recoveryProgramProvider).valueOrNull ??
        RecoveryProgram.defaultProgram();
    final totalDays = program.totalDays <= 0 ? 30 : program.totalDays;
    final currentDay = stats.currentDay;
    final selectedDay = _selectedDay ?? currentDay;
    final tasksAsync = ref.watch(planTasksProvider(selectedDay));
    final taskCount = tasksAsync.valueOrNull?.length;

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
            _Header(
              showBack: Navigator.of(context).canPop(),
              onToday: () => setState(() => _selectedDay = currentDay),
            ),
            const SizedBox(height: AppSizes.lg),
            _ProgressBanner(currentDay: currentDay, totalDays: totalDays),
            const SizedBox(height: AppSizes.lg),
            const _SectionTitle('Select Day'),
            const SizedBox(height: AppSizes.md),
            _DaySelector(
              totalDays: totalDays,
              selectedDay: selectedDay,
              currentDay: currentDay,
              onSelect: (d) => setState(() => _selectedDay = d),
            ),
            const SizedBox(height: AppSizes.lg),
            Row(
              children: [
                const Expanded(child: _SectionTitle("Today's Tasks")),
                if (taskCount != null)
                  Text(
                    '$taskCount ${taskCount == 1 ? 'task' : 'tasks'}',
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: HomeStyle.primary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSizes.md),
            _AsyncSection<List<DailyTask>>(
              value: tasksAsync,
              skeletonHeight: 220,
              onRetry: () => ref.invalidate(planTasksProvider(selectedDay)),
              builder: (tasks) {
                if (tasks.isEmpty) return const _PlanEmptyState();
                return Column(
                  children: [
                    for (var i = 0; i < tasks.length; i++) ...[
                      if (i != 0) const SizedBox(height: AppSizes.md),
                      _TaskCard(
                        task: tasks[i],
                        completed: stats.isTaskCompleted(tasks[i].id),
                        onToggle: (v) => _toggle(tasks[i].id, v),
                        onOpen: () => _openDetail(tasks[i]),
                      ),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: AppSizes.lg),
            const _EncouragementCard(),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header + banner
// ─────────────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.showBack, required this.onToday});

  final bool showBack;
  final VoidCallback onToday;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (showBack) ...[
          _SquareIconButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.of(context).maybePop(),
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
                'Your daily roadmap to healing and growth.',
                style: TextStyle(fontSize: 14, color: HomeStyle.inkSoft),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSizes.sm),
        _SquareIconButton(icon: Icons.calendar_month_rounded, onTap: onToday),
      ],
    );
  }
}

/// A lavender rounded-square icon button, matching Home's soft control chips.
class _SquareIconButton extends StatelessWidget {
  const _SquareIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: HomeStyle.lavender,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: HomeStyle.primary, size: 22),
        ),
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
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Text(
                '${(percent * 100).round()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
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
                  "Keep going — you're doing great!",
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

// ─────────────────────────────────────────────────────────────────────────────
// Day selector
// ─────────────────────────────────────────────────────────────────────────────

class _DaySelector extends StatelessWidget {
  const _DaySelector({
    required this.totalDays,
    required this.selectedDay,
    required this.currentDay,
    required this.onSelect,
  });

  final int totalDays;
  final int selectedDay;
  final int currentDay;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: totalDays,
        separatorBuilder: (_, __) => const SizedBox(width: AppSizes.sm),
        itemBuilder: (context, i) {
          final day = i + 1;
          return _DayChip(
            day: day,
            selected: day == selectedDay,
            isCurrent: day == currentDay,
            onTap: () => onSelect(day),
          );
        },
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.day,
    required this.selected,
    required this.isCurrent,
    required this.onTap,
  });

  final int day;
  final bool selected;
  final bool isCurrent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? HomeStyle.primary : HomeStyle.card,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        onTap: onTap,
        child: Container(
          width: 62,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(
              color: selected ? HomeStyle.primary : HomeStyle.border,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Day',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white70 : HomeStyle.inkSoft,
                ),
              ),
              Text(
                '$day',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: selected ? Colors.white : HomeStyle.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Task card
// ─────────────────────────────────────────────────────────────────────────────

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.task,
    required this.completed,
    required this.onToggle,
    required this.onOpen,
  });

  final DailyTask task;
  final bool completed;
  final ValueChanged<bool> onToggle;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: completed ? HomeStyle.lavenderLight : HomeStyle.card,
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            border: Border.all(color: HomeStyle.border),
            boxShadow: completed ? null : HomeStyle.softShadow,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: HomeStyle.lavender,
                  shape: BoxShape.circle,
                ),
                child: Icon(taskIcon(task), color: HomeStyle.primary, size: 22),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        color: HomeStyle.ink,
                        decoration:
                            completed ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    if (task.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.description,
                        style: const TextStyle(
                          fontSize: 13,
                          color: HomeStyle.inkSoft,
                          height: 1.35,
                        ),
                      ),
                    ],
                    if (task.duration.isNotEmpty) ...[
                      const SizedBox(height: AppSizes.sm),
                      Row(
                        children: [
                          const Icon(Icons.schedule_rounded,
                              size: 14, color: HomeStyle.primary),
                          const SizedBox(width: 4),
                          Text(
                            task.duration,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: HomeStyle.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              _SquareCheckbox(completed: completed, onToggle: onToggle),
            ],
          ),
        ),
      ),
    );
  }
}

/// The right-aligned square completion checkbox (purple-filled when done).
class _SquareCheckbox extends StatelessWidget {
  const _SquareCheckbox({required this.completed, required this.onToggle});

  final bool completed;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onToggle(!completed),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: completed ? HomeStyle.primary : Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          border: Border.all(
            color: completed ? HomeStyle.primary : HomeStyle.border,
            width: 2,
          ),
        ),
        child: completed
            ? const Icon(Icons.check_rounded, size: 18, color: Colors.white)
            : null,
      ),
    );
  }
}

/// Maps a task's icon key / title keyword to an icon (shared with detail).
IconData taskIcon(DailyTask task) {
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

// ─────────────────────────────────────────────────────────────────────────────
// Encouragement, states, shared bits
// ─────────────────────────────────────────────────────────────────────────────

class _EncouragementCard extends StatelessWidget {
  const _EncouragementCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [HomeStyle.lavenderLight, HomeStyle.lavender],
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: HomeStyle.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                color: HomeStyle.primary, size: 22),
          ),
          const SizedBox(width: AppSizes.md),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Why follow your plan?',
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: HomeStyle.primary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Small daily actions create big changes. Stay consistent '
                  'and trust the process.',
                  style: TextStyle(
                    fontSize: 13,
                    color: HomeStyle.ink,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
            child: const Icon(Icons.event_busy_rounded,
                color: HomeStyle.primary, size: 24),
          ),
          const SizedBox(height: AppSizes.md),
          const Text(
            'No tasks for this day',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w700,
              color: HomeStyle.ink,
            ),
          ),
          const SizedBox(height: AppSizes.xs),
          const Text(
            "Your recovery plan for this day hasn't been added yet.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: HomeStyle.inkSoft, height: 1.35),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: HomeStyle.ink,
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
