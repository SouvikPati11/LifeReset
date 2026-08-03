import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../domain/entities/mood_type.dart';

/// Distinct color per mood (used by selectors, chips and charts).
Color moodColor(MoodType mood) {
  switch (mood) {
    case MoodType.great:
      return const Color(0xFF2E9E63);
    case MoodType.good:
      return const Color(0xFF2E7D6B);
    case MoodType.okay:
      return const Color(0xFFE0A800);
    case MoodType.anxious:
      return const Color(0xFF7C4DFF);
    case MoodType.sad:
      return const Color(0xFF2E86DE);
    case MoodType.awful:
      return const Color(0xFFC0392B);
  }
}

/// A single selectable mood (emoji chip + label).
class MoodOption extends StatelessWidget {
  const MoodOption({
    super.key,
    required this.mood,
    required this.selected,
    required this.onTap,
    this.compact = false,
  });

  final MoodType mood;
  final bool selected;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = moodColor(mood);
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(
          vertical: compact ? AppSizes.sm : AppSizes.md,
          horizontal: AppSizes.xs,
        ),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(
            color: selected ? color : Theme.of(context).colorScheme.outlineVariant,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(mood.emoji, style: TextStyle(fontSize: compact ? 22 : 26)),
            const SizedBox(height: 4),
            Text(
              mood.label,
              style: textTheme.labelSmall?.copyWith(
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A horizontal row of moods (the journal composer scale).
class MoodSelectorRow extends StatelessWidget {
  const MoodSelectorRow({
    super.key,
    required this.moods,
    required this.selected,
    required this.onSelect,
  });

  final List<MoodType> moods;
  final MoodType? selected;
  final ValueChanged<MoodType> onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < moods.length; i++) ...[
          if (i != 0) const SizedBox(width: AppSizes.sm),
          Expanded(
            child: MoodOption(
              mood: moods[i],
              compact: true,
              selected: selected == moods[i],
              onTap: () => onSelect(moods[i]),
            ),
          ),
        ],
      ],
    );
  }
}

/// A 3-column grid of moods (the Mood Check screen).
class MoodSelectorGrid extends StatelessWidget {
  const MoodSelectorGrid({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  final MoodType? selected;
  final ValueChanged<MoodType> onSelect;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSizes.md,
      crossAxisSpacing: AppSizes.md,
      childAspectRatio: 1.0,
      children: [
        for (final mood in MoodType.values)
          MoodOption(
            mood: mood,
            selected: selected == mood,
            onTap: () => onSelect(mood),
          ),
      ],
    );
  }
}
