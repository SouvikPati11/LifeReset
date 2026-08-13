import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/ls_kit.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../../authentication/presentation/providers/user_providers.dart';
import '../../../home/presentation/widgets/home_style.dart';
import '../../domain/entities/coach_context.dart';
import '../providers/coach_providers.dart';
import '../widgets/coach_banners.dart';
import '../widgets/conversation_tile.dart';
import '../widgets/message_bubble.dart';
import 'chat_screen.dart';
import 'conversations_list_screen.dart';

/// AI Coach home — a supportive companion surface: a warm greeting hero with a
/// start action, suggested conversation topics, and recent conversations.
/// Deliberately conversational (not a dashboard of stat cards).
class CoachHomeScreen extends ConsumerWidget {
  const CoachHomeScreen({super.key});

  /// Natural first-message openers for each suggested topic. Tapping a topic
  /// creates a conversation and pre-fills the composer (the user taps send, so
  /// the real AI flow is preserved — nothing is auto-generated).
  static const List<(String, IconData, String)> _topics = [
    ('Stress', Icons.spa_rounded,
        "I've been feeling stressed and could use some support."),
    ('Motivation', Icons.bolt_rounded,
        "I'm struggling to stay motivated. Can you help?"),
    ('Sleep', Icons.nightlight_round,
        "I've been having trouble sleeping lately."),
    ('Relationships', Icons.favorite_rounded,
        "I want to talk about a relationship that's on my mind."),
    ('Confidence', Icons.self_improvement_rounded,
        "I've been feeling low on confidence."),
  ];

  Future<void> _startConversation(
    BuildContext context,
    WidgetRef ref, {
    String? draft,
  }) async {
    final uid = ref.read(currentUserProvider)?.id;
    if (uid == null) return;
    final result = await ref.read(createConversationUseCaseProvider).call(uid);
    if (!context.mounted) return;
    result.when(
      success: (id) => _openChat(context, id, draft: draft),
      failure: (_) => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not start a conversation.')),
      ),
    );
  }

  void _openChat(BuildContext context, String conversationId, {String? draft}) {
    // The immersive chat opens full-screen on the root navigator (bottom nav
    // hidden) for a roomier, keyboard-safe conversation.
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) =>
            ChatScreen(conversationId: conversationId, initialDraft: draft),
      ),
    );
  }

  void _openHistory(BuildContext context) {
    // History stays inside the Coach tab so the bottom nav remains visible.
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ConversationsListScreen()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = _firstName(ref.watch(userProfileProvider).valueOrNull?.name);
    final coachCtx =
        ref.watch(coachContextProvider).valueOrNull ?? CoachContext.initial();

    return Scaffold(
      backgroundColor: HomeStyle.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            LsHeader(
              title: 'Coach',
              subtitle: 'Your personal recovery companion',
              trailing: LsSquareButton(
                icon: Icons.history_rounded,
                onTap: () => _openHistory(context),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.lg,
                  0,
                  AppSizes.lg,
                  AppSizes.xl,
                ),
                children: [
                  _GreetingHero(
                    name: name,
                    onStart: () => _startConversation(context, ref),
                  ),
                  if (_hasContext(coachCtx)) ...[
                    const SizedBox(height: AppSizes.md),
                    _ContextStrip(data: coachCtx),
                  ],
                  const SizedBox(height: AppSizes.lg),
                  const LsSectionTitle('Suggested topics'),
                  const SizedBox(height: AppSizes.md),
                  Wrap(
                    spacing: AppSizes.sm,
                    runSpacing: AppSizes.sm,
                    children: [
                      for (final (label, icon, draft) in _topics)
                        LsChip(
                          label: label,
                          icon: icon,
                          onTap: () =>
                              _startConversation(context, ref, draft: draft),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.lg),
                  _RecentConversations(
                    onViewAll: () => _openHistory(context),
                    onOpen: (id) => _openChat(context, id),
                    onStart: () => _startConversation(context, ref),
                  ),
                  const SizedBox(height: AppSizes.lg),
                  const SafetyDisclaimer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _hasContext(CoachContext c) =>
      c.todayTaskTitle != null || c.moodLabel != null || c.streak > 0;

  String _firstName(String? fullName) {
    final n = (fullName ?? '').trim();
    if (n.isEmpty) return 'there';
    return n.split(' ').first;
  }
}

class _GreetingHero extends StatelessWidget {
  const _GreetingHero({required this.name, required this.onStart});

  final String name;
  final VoidCallback onStart;

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    if (h < 21) return 'Good evening';
    return 'Hello';
  }

  @override
  Widget build(BuildContext context) {
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
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome_rounded,
                    color: Colors.white, size: 24),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$_greeting, $name',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'What would you like to work through?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.lg),
          _StartButton(onTap: onStart),
        ],
      ),
    );
  }
}

/// A white-on-gradient "Start a conversation" button.
class _StartButton extends StatelessWidget {
  const _StartButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 14, horizontal: AppSizes.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.chat_bubble_rounded,
                  color: HomeStyle.primary, size: 18),
              SizedBox(width: AppSizes.sm),
              Flexible(
                child: Text(
                  'Start a conversation',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: HomeStyle.primaryDeep,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A slim, single-line strip of today's real context (no dashboard grid).
class _ContextStrip extends StatelessWidget {
  const _ContextStrip({required this.data});

  final CoachContext data;

  @override
  Widget build(BuildContext context) {
    final items = <(IconData, String)>[
      (Icons.local_fire_department_rounded, 'Day ${data.recoveryDay}'),
      if (data.streak > 0)
        (Icons.bolt_rounded, '${data.streak}-day streak'),
      if (data.moodLabel != null)
        (Icons.mood_rounded, data.moodLabel!),
    ];

    return LsCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm + 2,
      ),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i != 0)
              Container(
                width: 1,
                height: 18,
                margin: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
                color: HomeStyle.border,
              ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(items[i].$1, size: 15, color: HomeStyle.primary),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      items[i].$2,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: HomeStyle.ink,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RecentConversations extends ConsumerWidget {
  const _RecentConversations({
    required this.onViewAll,
    required this.onOpen,
    required this.onStart,
  });

  final VoidCallback onViewAll;
  final ValueChanged<String> onOpen;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(conversationsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        conversationsAsync.when(
          loading: () => const _SectionShell(
            child: Padding(
              padding: EdgeInsets.all(AppSizes.lg),
              child: LsLoader(),
            ),
          ),
          error: (_, __) => const _SectionShell(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: AppSizes.md),
              child: Text(
                'Could not load conversations.',
                style: TextStyle(fontSize: 13, color: HomeStyle.inkSoft),
              ),
            ),
          ),
          data: (conversations) {
            if (conversations.isEmpty) {
              return _EmptyRecent(onStart: onStart);
            }
            final recent = conversations.take(5).toList();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LsSectionTitle(
                  'Recent conversations',
                  trailing: TextButton(
                    onPressed: onViewAll,
                    style: TextButton.styleFrom(
                      foregroundColor: HomeStyle.primary,
                      padding:
                          const EdgeInsets.symmetric(horizontal: AppSizes.sm),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('View all',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: AppSizes.md),
                for (final c in recent)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.sm),
                    child: ConversationTile(
                      conversation: c,
                      onTap: () => onOpen(c.id),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _SectionShell extends StatelessWidget {
  const _SectionShell({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const LsSectionTitle('Recent conversations'),
        const SizedBox(height: AppSizes.md),
        child,
      ],
    );
  }
}

class _EmptyRecent extends StatelessWidget {
  const _EmptyRecent({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return LsCard(
      child: Column(
        children: [
          const CoachAvatar(size: 52),
          const SizedBox(height: AppSizes.md),
          const Text(
            'No conversations yet',
            style: TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w700,
              color: HomeStyle.ink,
            ),
          ),
          const SizedBox(height: AppSizes.xs),
          const Text(
            'Start a chat and pick up right where you left off, any time.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: HomeStyle.inkSoft, height: 1.4),
          ),
          const SizedBox(height: AppSizes.md),
          LsButton(
            label: 'New conversation',
            icon: Icons.add_rounded,
            onPressed: onStart,
          ),
        ],
      ),
    );
  }
}
