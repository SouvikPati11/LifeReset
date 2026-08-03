import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';

/// The four Quick Action cards. Navigation only — the target modules are not
/// built yet, so tapping opens a placeholder via [onOpen].
class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key, required this.onOpen});

  /// Called with the action's title when tapped.
  final ValueChanged<String> onOpen;

  static const List<_QuickAction> _actions = [
    _QuickAction('Journal', 'Write your thoughts', Icons.menu_book_rounded),
    _QuickAction('Mood', 'Track how you feel', Icons.favorite_rounded),
    _QuickAction('Progress', 'See your journey', Icons.trending_up_rounded),
    _QuickAction('AI Coach', 'Get support 24/7', Icons.forum_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < _actions.length; i++) ...[
          if (i != 0) const SizedBox(width: AppSizes.sm),
          Expanded(
            child: _QuickActionCard(
              action: _actions[i],
              onTap: () => onOpen(_actions[i].title),
            ),
          ),
        ],
      ],
    );
  }
}

class _QuickAction {
  const _QuickAction(this.title, this.subtitle, this.icon);

  final String title;
  final String subtitle;
  final IconData icon;
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({required this.action, required this.onTap});

  final _QuickAction action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.xs,
            vertical: AppSizes.md,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(action.icon, size: 20, color: colorScheme.primary),
              ),
              const SizedBox(height: AppSizes.sm),
              Text(
                action.title,
                textAlign: TextAlign.center,
                style: textTheme.labelMedium,
              ),
              const SizedBox(height: 2),
              Text(
                action.subtitle,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
