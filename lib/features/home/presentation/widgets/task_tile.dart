import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../domain/entities/daily_task.dart';

/// Maps a task's [DailyTask.iconKey] (or a keyword in its title) to an icon.
IconData taskIcon(DailyTask task) {
  final key = (task.iconKey ?? task.title).toLowerCase();
  if (key.contains('breath')) return Icons.self_improvement_rounded;
  if (key.contains('journal') || key.contains('write')) {
    return Icons.edit_note_rounded;
  }
  if (key.contains('walk')) return Icons.directions_walk_rounded;
  if (key.contains('read')) return Icons.menu_book_rounded;
  if (key.contains('sleep') || key.contains('social')) {
    return Icons.nightlight_round;
  }
  if (key.contains('mood')) return Icons.mood_rounded;
  return Icons.spa_rounded;
}

/// A task row in the Today's Plan list, with a completion toggle.
class TaskTile extends StatelessWidget {
  const TaskTile({
    super.key,
    required this.task,
    required this.completed,
    required this.onToggle,
    this.heroTag,
  });

  final DailyTask task;
  final bool completed;
  final ValueChanged<bool> onToggle;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final icon = Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Icon(taskIcon(task), color: colorScheme.primary),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.xs),
      child: Row(
        children: [
          heroTag != null ? Hero(tag: heroTag!, child: icon) : icon,
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: textTheme.titleSmall?.copyWith(
                    decoration:
                        completed ? TextDecoration.lineThrough : null,
                    color: completed ? colorScheme.onSurfaceVariant : null,
                  ),
                ),
                if (task.duration.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.schedule_rounded,
                          size: 14, color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        task.duration,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          _CompletionToggle(completed: completed, onToggle: onToggle),
        ],
      ),
    );
  }
}

class _CompletionToggle extends StatelessWidget {
  const _CompletionToggle({required this.completed, required this.onToggle});

  final bool completed;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return IconButton(
      onPressed: () => onToggle(!completed),
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: completed
            ? Icon(Icons.check_circle_rounded,
                key: const ValueKey('done'), color: colorScheme.primary)
            : Icon(Icons.circle_outlined,
                key: const ValueKey('todo'), color: colorScheme.outline),
      ),
    );
  }
}
