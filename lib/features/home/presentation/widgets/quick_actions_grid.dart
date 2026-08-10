import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import 'home_style.dart';

/// The four Quick Action cards laid out as a 2 × 2 grid. Navigation only —
/// tapping calls [onOpen] with the action's title, which the dashboard routes
/// to the matching module screen.
class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key, required this.onOpen});

  /// Called with the action's title when tapped.
  final ValueChanged<String> onOpen;

  static const List<_QuickAction> _actions = [
    _QuickAction('Journal', 'Write your thoughts', Icons.menu_book_rounded,
        Color(0xFF7C3AED)),
    _QuickAction('Mood', 'Track how you feel', Icons.sentiment_satisfied_rounded,
        Color(0xFFF59E0B)),
    _QuickAction('Progress', 'See your journey', Icons.trending_up_rounded,
        Color(0xFF10B981)),
    _QuickAction('AI Coach', 'Get support 24/7', Icons.auto_awesome_rounded,
        Color(0xFF7C3AED)),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _card(0)),
              const SizedBox(width: AppSizes.md),
              Expanded(child: _card(1)),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.md),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _card(2)),
              const SizedBox(width: AppSizes.md),
              Expanded(child: _card(3)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _card(int i) => _QuickActionCard(
        action: _actions[i],
        onTap: () => onOpen(_actions[i].title),
      );
}

class _QuickAction {
  const _QuickAction(this.title, this.subtitle, this.icon, this.tint);

  final String title;
  final String subtitle;
  final IconData icon;
  final Color tint;
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({required this.action, required this.onTap});

  final _QuickAction action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: HomeStyle.card,
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            border: Border.all(color: HomeStyle.border),
            boxShadow: HomeStyle.softShadow,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: action.tint.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(action.icon, size: 22, color: action.tint),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      action.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: HomeStyle.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      action.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: HomeStyle.inkSoft,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
