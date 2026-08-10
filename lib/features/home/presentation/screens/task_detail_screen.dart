import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../domain/entities/daily_task.dart';
import '../providers/home_providers.dart';
import '../widgets/home_style.dart';

/// A dedicated Task Details screen, opened from the Plan list. Shows the task's
/// admin-authored context (description, why-it-matters, journal prompt, mood
/// goal) and a completion button wired to the existing completion flow
/// (`users/{uid}.completedTasks`). No new data, no AI.
class TaskDetailScreen extends ConsumerWidget {
  const TaskDetailScreen({super.key, required this.task});

  final DailyTask task;

  Future<void> _toggle(WidgetRef ref, BuildContext context, bool completed) async {
    final uid = ref.read(currentUserProvider)?.id;
    if (uid == null) return;
    final result = await ref
        .read(setTaskCompletedUseCaseProvider)
        .call(uid: uid, taskId: task.id, completed: completed);
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
    final completed =
        ref.watch(userStatsProvider).valueOrNull?.isTaskCompleted(task.id) ??
            false;

    return Scaffold(
      backgroundColor: HomeStyle.background,
      body: SafeArea(
        child: Column(
          children: [
            _DetailAppBar(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.lg,
                  AppSizes.md,
                  AppSizes.lg,
                  AppSizes.lg,
                ),
                children: [
                  _TaskHero(task: task),
                  const SizedBox(height: AppSizes.lg),
                  _Section(
                    title: 'Description',
                    body: task.description.isNotEmpty
                        ? task.description
                        : 'Take a moment to complete this activity mindfully.',
                  ),
                  if (task.whyThisMatters.isNotEmpty) ...[
                    const SizedBox(height: AppSizes.lg),
                    _Section(
                        title: 'Why this matters', body: task.whyThisMatters),
                  ],
                  if (task.journalPrompt.isNotEmpty) ...[
                    const SizedBox(height: AppSizes.lg),
                    _LabeledCard(
                      label: 'Journal Prompt',
                      text: task.journalPrompt,
                    ),
                  ],
                  if (task.moodGoal.isNotEmpty) ...[
                    const SizedBox(height: AppSizes.md),
                    _LabeledCard(label: 'Mood Goal', text: task.moodGoal),
                  ],
                ],
              ),
            ),
            _CompleteButton(
              completed: completed,
              onPressed: () => _toggle(ref, context, !completed),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.md,
        AppSizes.sm,
        AppSizes.md,
        AppSizes.sm,
      ),
      child: Row(
        children: [
          _RoundButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.of(context).maybePop(),
          ),
          const Expanded(
            child: Text(
              'Task Details',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: HomeStyle.ink,
              ),
            ),
          ),
          _RoundButton(icon: Icons.more_vert_rounded, onTap: () {}),
        ],
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, color: HomeStyle.ink, size: 22),
        ),
      ),
    );
  }
}

class _TaskHero extends StatelessWidget {
  const _TaskHero({required this.task});

  final DailyTask task;

  IconData get _icon {
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

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 56,
          height: 56,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: HomeStyle.lavender,
            shape: BoxShape.circle,
          ),
          child: Icon(_icon, color: HomeStyle.primary, size: 26),
        ),
        const SizedBox(width: AppSizes.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: HomeStyle.ink,
                  height: 1.15,
                ),
              ),
              if (task.duration.isNotEmpty) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.schedule_rounded,
                        size: 15, color: HomeStyle.primary),
                    const SizedBox(width: 4),
                    Text(
                      task.duration,
                      style: const TextStyle(
                        fontSize: 13.5,
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
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: HomeStyle.primary,
          ),
        ),
        const SizedBox(height: AppSizes.sm),
        Text(
          body,
          style: const TextStyle(
            fontSize: 14.5,
            color: HomeStyle.ink,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

class _LabeledCard extends StatelessWidget {
  const _LabeledCard({required this.label, required this.text});

  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: HomeStyle.insightBg,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: HomeStyle.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: HomeStyle.primary,
            ),
          ),
          const SizedBox(height: AppSizes.xs),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: HomeStyle.ink,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompleteButton extends StatelessWidget {
  const _CompleteButton({required this.completed, required this.onPressed});

  final bool completed;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.lg,
        AppSizes.sm,
        AppSizes.lg,
        AppSizes.md,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: HomeStyle.scoreGradient,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          boxShadow: HomeStyle.softShadow,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            onTap: onPressed,
            child: SizedBox(
              height: 54,
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    completed ? 'Completed' : 'Mark as Completed',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
