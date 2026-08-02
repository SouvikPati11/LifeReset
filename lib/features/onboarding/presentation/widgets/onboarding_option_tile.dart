import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_sizes.dart';

/// A single-select option row used by the question steps.
///
/// Shows an optional leading emoji chip, a label, and a trailing radio that
/// fills with a check when selected. Selection animates the border and
/// background, matching the design.
class OnboardingOptionTile extends StatelessWidget {
  const OnboardingOptionTile({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.emoji,
    this.leadingIcon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final String? emoji;
  final IconData? leadingIcon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.sm),
      child: Material(
        color: selected
            ? colorScheme.primaryContainer.withValues(alpha: 0.4)
            : colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          child: AnimatedContainer(
            duration: AppConstants.shortAnimation,
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md,
              vertical: AppSizes.md,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(
                color: selected ? colorScheme.primary : colorScheme.outlineVariant,
                width: selected ? 1.6 : 1,
              ),
            ),
            child: Row(
              children: [
                if (emoji != null || leadingIcon != null) ...[
                  _Leading(
                    emoji: emoji,
                    icon: leadingIcon,
                    color: colorScheme.primary,
                    background: colorScheme.surfaceContainerHighest,
                  ),
                  const SizedBox(width: AppSizes.md),
                ],
                Expanded(
                  child: Text(
                    label,
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
                _SelectionIndicator(selected: selected),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Leading extends StatelessWidget {
  const _Leading({
    required this.emoji,
    required this.icon,
    required this.color,
    required this.background,
  });

  final String? emoji;
  final IconData? icon;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      ),
      child: emoji != null
          ? Text(emoji!, style: const TextStyle(fontSize: 18))
          : Icon(icon, size: AppSizes.iconSm, color: color),
    );
  }
}

class _SelectionIndicator extends StatelessWidget {
  const _SelectionIndicator({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AnimatedSwitcher(
      duration: AppConstants.shortAnimation,
      child: selected
          ? Icon(
              Icons.check_circle_rounded,
              key: const ValueKey('selected'),
              color: colorScheme.primary,
            )
          : Icon(
              Icons.circle_outlined,
              key: const ValueKey('unselected'),
              color: colorScheme.outline,
            ),
    );
  }
}
