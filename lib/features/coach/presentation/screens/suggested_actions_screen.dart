import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/ls_kit.dart';
import '../../../home/presentation/widgets/home_style.dart';
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
      backgroundColor: HomeStyle.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            LsHeader(
              title: 'Suggested actions',
              subtitle: 'Tools and support for right now',
              onBack: () => Navigator.of(context).maybePop(),
            ),
            const SizedBox(height: AppSizes.md),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                    AppSizes.lg, 0, AppSizes.lg, AppSizes.xl),
                children: [
                  _QuickActions(onOpen: (t) => _open(context, t)),
                  const SizedBox(height: AppSizes.lg),
                  const LsSectionTitle('Suggestions for you'),
                  const SizedBox(height: AppSizes.md),
                  _AiSuggestions(onOpen: (t) => _open(context, t)),
                  const SizedBox(height: AppSizes.lg),
                  _HumanSupport(
                      onFindSupport: () => _open(context, 'Find Support')),
                  const SizedBox(height: AppSizes.lg),
                  const LsSectionTitle('Conversation info'),
                  const SizedBox(height: AppSizes.md),
                  _ConversationInfo(quota: quota),
                  const SizedBox(height: AppSizes.md),
                  const _Tips(),
                ],
              ),
            ),
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
    ('Breathe', Icons.self_improvement_rounded),
    ('Journal', Icons.menu_book_rounded),
    ('Mood', Icons.mood_rounded),
    ('Tasks', Icons.checklist_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return LsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick actions',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: HomeStyle.ink,
            ),
          ),
          const SizedBox(height: AppSizes.md),
          Row(
            children: [
              for (final (label, icon) in _items)
                Expanded(
                  child: InkWell(
                    onTap: () => onOpen(label),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(vertical: AppSizes.sm),
                      child: Column(
                        children: [
                          LsIconBadge(icon: icon, size: 44),
                          const SizedBox(height: 6),
                          Text(
                            label,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: HomeStyle.inkSoft,
                            ),
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
      'Practice self-compassion',
      "Be kind to yourself. You're doing your best.",
      Icons.favorite_rounded,
    ),
    (
      'Take a mindful break',
      'Step away for a few minutes and breathe.',
      Icons.eco_rounded,
    ),
    (
      'Focus on small wins',
      'Celebrate even the smallest progress.',
      Icons.star_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final (title, subtitle, icon) in _items)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.sm),
            child: LsCard(
              onTap: () => onOpen(title),
              child: Row(
                children: [
                  LsIconBadge(icon: icon, size: 40),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: HomeStyle.ink,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: HomeStyle.inkSoft,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      color: HomeStyle.inkSoft, size: 20),
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
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        gradient: HomeStyle.scoreGradient,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: HomeStyle.softShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Need to talk to a human?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSizes.xs),
                Text(
                  'Sometimes a real person can help.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: AppSizes.md),
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  child: InkWell(
                    onTap: onFindSupport,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: AppSizes.lg, vertical: 10),
                      child: Text(
                        'Find support',
                        style: TextStyle(
                          color: HomeStyle.primaryDeep,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.sm),
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

    return LsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoRow(
              icon: Icons.chat_bubble_outline_rounded,
              label: 'Messages today',
              value: usedLabel),
          _InfoRow(
              icon: Icons.speed_rounded,
              label: 'Daily limit',
              value: '$limitLabel messages'),
          _InfoRow(
              icon: Icons.schedule_rounded,
              label: 'Reset time',
              value: resetLabel),
          _InfoRow(
              icon: Icons.workspace_premium_rounded,
              label: 'Plan',
              value: planLabel),
          if (quota.limit != null) ...[
            const SizedBox(height: AppSizes.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.radiusPill),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 7,
                backgroundColor: HomeStyle.lavender,
                valueColor: const AlwaysStoppedAnimation(HomeStyle.primary),
              ),
            ),
            const SizedBox(height: AppSizes.xs),
            Center(
              child: Text(
                '${quota.remaining} messages remaining today',
                style: const TextStyle(fontSize: 12, color: HomeStyle.inkSoft),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: HomeStyle.primary),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Text(label,
                style: const TextStyle(fontSize: 13.5, color: HomeStyle.ink)),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: HomeStyle.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _Tips extends StatelessWidget {
  const _Tips();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: HomeStyle.lavenderLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: HomeStyle.border),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_rounded, color: HomeStyle.primary, size: 20),
          SizedBox(width: AppSizes.sm),
          Expanded(
            child: Text(
              'Be open and honest. The more you share, the better I can support you.',
              style: TextStyle(
                fontSize: 13,
                color: HomeStyle.primaryDeep,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
