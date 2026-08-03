import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../domain/entities/journal_entry.dart';
import 'mood_widgets.dart';

/// A rounded surface used across the journal UI.
class JCard extends StatelessWidget {
  const JCard({super.key, required this.child, this.padding, this.onTap});

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final content = Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: child,
    );
    if (onTap == null) return content;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      child: content,
    );
  }
}

/// A compact labelled statistic (e.g. "5 Journal Entries").
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.value,
    required this.label,
    this.valueColor,
  });

  final String value;
  final String label;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return JCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.sm,
        vertical: AppSizes.md,
      ),
      child: Column(
        children: [
          Text(
            value,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: valueColor ?? colorScheme.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: textTheme.labelSmall
                ?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

/// A small tag pill.
class TagChip extends StatelessWidget {
  const TagChip({super.key, required this.label, this.selected = false, this.onTap});

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusPill),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.xs,
        ),
        decoration: BoxDecoration(
          color: selected
              ? colorScheme.primary
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppSizes.radiusPill),
        ),
        child: Text(
          label,
          style: textTheme.labelMedium?.copyWith(
            color: selected ? Colors.white : colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

/// A journal entry row (mood, title, preview, time).
class JournalEntryTile extends StatelessWidget {
  const JournalEntryTile({super.key, required this.entry, required this.onTap});

  final JournalEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final mood = entry.mood;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: (mood == null ? colorScheme.primary : moodColor(mood))
                    .withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Text(
                mood?.emoji ?? '📝',
                style: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.title.isEmpty ? 'Untitled' : entry.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleSmall,
                        ),
                      ),
                      const SizedBox(width: AppSizes.sm),
                      Text(
                        _relative(entry.createdAt),
                        style: textTheme.labelSmall
                            ?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                  if (entry.content.isNotEmpty)
                    Text(
                      entry.content,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall
                          ?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _relative(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return DateFormat('MMM d').format(time);
  }
}
