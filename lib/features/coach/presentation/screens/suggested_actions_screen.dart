import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../domain/entities/message_quota.dart';
import '../providers/coach_providers.dart';
import 'coach_placeholder_screen.dart';

/// The "Suggested Actions" panel: quick tools, supportive suggestions, a human
/// support prompt, and today's conversation/quota info.
class SuggestedActionsScreen extends ConsumerWidget {
  const SuggestedActionsScreen({super.key, required this.conversationId});

  final String conversationId;

  void _open(BuildContext context, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CoachPlaceholderScreen(title: title)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quota = ref.watch(messageQuotaProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Suggested Actions')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.md),
          children: [
            _QuickActions(onOpen: (t) => _open(context, t)),
            const SizedBox(height: AppSizes.lg),
            _AiSuggestions(onOpen: (t) => _open(context, t)),
            const SizedBox(height: AppSizes.lg),
            _HumanSupport(onFindSupport: () => _open(context, 'Find Support')),
            const SizedBox(height: AppSizes.lg),
            _ConversationInfo(quota: quota),
            const SizedBox(height: AppSizes.lg),
            const _Tips(),
          ],
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.onOpen});

  final ValueChanged<String> onOpen;

  static const List<(String, IconData)> _items = [
    ('Breathing Exercise', Icons.self_improvement_rounded),
    ('Write in Journal', Icons.menu_book_rounded),
    ('Mood Check', Icons.mood_rounded),
    ("Today's Tasks", Icons.checklist_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Actions', style: textTheme.titleMedium),
          Text(
            'Helpful tools for your recovery',
            style: textTheme.bodySmall
                ?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSizes.md),
          Row(
            children: [
              for (final (label, icon) in _items)
                Expanded(
                  child: InkWell(
                    onTap: () => onOpen(label),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor:
                                colorScheme.primaryContainer.withValues(alpha: 0.5),
                            child: Icon(icon, color: colorScheme.primary),
                          ),
                          const SizedBox(height: AppSizes.xs),
                          Text(
                            label,
                            textAlign: TextAlign.center,
                            style: textTheme.labelSmall,
                          ),
                        ],
                      ),
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

class _AiSuggestions extends StatelessWidget {
  const _AiSuggestions({required this.onOpen});

  final ValueChanged<String> onOpen;

  static const List<(String, String, IconData)> _items = [
    (
      'Practice Self-Compassion',
      "Be kind to yourself. You're doing your best.",
      Icons.favorite_rounded,
    ),
    (
      'Take a Mindful Break',
      'Step away for a few minutes and breathe.',
      Icons.eco_rounded,
    ),
    (
      'Focus on Small Wins',
      'Celebrate even the smallest progress.',
      Icons.star_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('AI Suggestions', style: textTheme.titleMedium),
        const SizedBox(height: AppSizes.sm),
        for (final (title, subtitle, icon) in _items)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.sm),
            child: _Card(
              onTap: () => onOpen(title),
              child: Row(
                children: [
                  Icon(icon, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: textTheme.titleSmall),
                        Text(
                          subtitle,
                          style: textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _HumanSupport extends StatelessWidget {
  const _HumanSupport({required this.onFindSupport});

  final VoidCallback onFindSupport;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final gradientEnd = Color.lerp(colorScheme.primary, Colors.black, 0.35)!;
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, gradientEnd],
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Need to talk to a human?',
                  style: textTheme.titleMedium?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: AppSizes.xs),
                Text(
                  'Sometimes a real person can help.',
                  style: textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: AppSizes.md),
                FilledButton(
                  onPressed: onFindSupport,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: colorScheme.primary,
                  ),
                  child: const Text('Find Support'),
                ),
              ],
            ),
          ),
          const Icon(Icons.headset_mic_rounded, color: Colors.white70, size: 40),
        ],
      ),
    );
  }
}

class _ConversationInfo extends StatelessWidget {
  const _ConversationInfo({required this.quota});

  final MessageQuota quota;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final limitLabel = quota.limit == null ? 'Unlimited' : '${quota.limit}';
    final usedLabel =
        quota.limit == null ? '${quota.used}' : '${quota.used} / ${quota.limit}';
    final planLabel = quota.isPremium
        ? 'Premium'
        : quota.trialDaysLeft != null
            ? 'Free Trial (${quota.trialDaysLeft} days left)'
            : 'Free Trial';
    final resetLabel = DateFormat('h:mm a').format(quota.resetsAt);
    final progress = quota.limit == null
        ? 0.0
        : (quota.used / quota.limit!).clamp(0.0, 1.0);

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Conversation Info', style: textTheme.titleMedium),
          const SizedBox(height: AppSizes.md),
          _InfoRow(icon: Icons.chat_bubble_outline_rounded, label: 'Messages Today', value: usedLabel),
          _InfoRow(icon: Icons.speed_rounded, label: 'Daily Limit', value: '$limitLabel messages'),
          _InfoRow(icon: Icons.schedule_rounded, label: 'Reset Time', value: resetLabel),
          _InfoRow(icon: Icons.workspace_premium_rounded, label: 'Plan', value: planLabel),
          if (quota.limit != null) ...[
            const SizedBox(height: AppSizes.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.radiusPill),
              child: LinearProgressIndicator(value: progress, minHeight: 6),
            ),
            const SizedBox(height: AppSizes.xs),
            Center(
              child: Text(
                '${quota.remaining} messages remaining today',
                style: textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.xs),
      child: Row(
        children: [
          Icon(icon, size: AppSizes.iconSm, color: colorScheme.primary),
          const SizedBox(width: AppSizes.sm),
          Expanded(child: Text(label, style: textTheme.bodyMedium)),
          Text(value, style: textTheme.titleSmall),
        ],
      ),
    );
  }
}

class _Tips extends StatelessWidget {
  const _Tips();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline_rounded, color: colorScheme.primary),
              const SizedBox(width: AppSizes.sm),
              Text('Tips', style: textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            'Be open and honest. The more you share, the better I can support you.',
            style: textTheme.bodyMedium
                ?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final decorated = Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: child,
    );
    if (onTap == null) return decorated;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      child: decorated,
    );
  }
}
