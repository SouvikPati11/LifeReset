import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../../authentication/presentation/providers/user_providers.dart';
import '../../domain/entities/coach_context.dart';
import '../providers/coach_providers.dart';
import '../widgets/coach_banners.dart';
import '../widgets/conversation_tile.dart';
import 'chat_screen.dart';
import 'conversations_list_screen.dart';

/// AI Coach home: welcome, today's context, recent conversations and a New
/// Conversation action. Designed to sit inside the app's bottom-nav shell.
class CoachHomeScreen extends ConsumerWidget {
  const CoachHomeScreen({super.key});

  Future<void> _newConversation(BuildContext context, WidgetRef ref) async {
    final uid = ref.read(currentUserProvider)?.id;
    if (uid == null) return;
    final result = await ref.read(createConversationUseCaseProvider).call(uid);
    if (!context.mounted) return;
    result.when(
      success: (id) {
        _openChat(context, id);
      },
      failure: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not start a conversation.')),
        );
      },
    );
  }

  void _openChat(BuildContext context, String conversationId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatScreen(conversationId: conversationId),
      ),
    );
  }

  void _openHistory(BuildContext context) {
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
      body: SafeArea(
        child: Column(
          children: [
            _Header(onHistory: () => _openHistory(context)),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.md,
                  0,
                  AppSizes.md,
                  AppSizes.md,
                ),
                children: [
                  _WelcomeHero(name: name),
                  const SizedBox(height: AppSizes.md),
                  const SafetyDisclaimer(),
                  const SizedBox(height: AppSizes.lg),
                  _ContextSection(data: coachCtx),
                  const SizedBox(height: AppSizes.lg),
                  _RecentConversations(
                    onViewAll: () => _openHistory(context),
                    onOpen: (id) => _openChat(context, id),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: PrimaryButton(
                label: 'New Conversation',
                icon: Icons.add_rounded,
                onPressed: () => _newConversation(context, ref),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _firstName(String? fullName) {
    final n = (fullName ?? '').trim();
    if (n.isEmpty) return 'there';
    return n.split(' ').first;
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onHistory});

  final VoidCallback onHistory;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.md,
        AppSizes.sm,
        AppSizes.md,
        AppSizes.sm,
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome_rounded, color: colorScheme.primary),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('LifeReset – AI Coach', style: textTheme.titleMedium),
                Text(
                  'Your personal recovery companion',
                  style: textTheme.bodySmall
                      ?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onHistory,
            icon: const Icon(Icons.history_rounded),
          ),
        ],
      ),
    );
  }
}

class _WelcomeHero extends StatelessWidget {
  const _WelcomeHero({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final gradientEnd = Color.lerp(colorScheme.primary, Colors.black, 0.35)!;

    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
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
                  'Hi $name! 👋',
                  style: textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSizes.xs),
                Text(
                  'I’m here to support you every step of your recovery.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: AppSizes.md),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.md,
                    vertical: AppSizes.xs,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                  ),
                  child: Text(
                    'Always here for you',
                    style:
                        textTheme.labelMedium?.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.md),
          const CircleAvatar(
            radius: 36,
            backgroundColor: Colors.white24,
            child: Icon(Icons.smart_toy_rounded, color: Colors.white, size: 40),
          ),
        ],
      ),
    );
  }
}

class _ContextSection extends StatelessWidget {
  const _ContextSection({required this.data});

  final CoachContext data;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final progress = '${(data.progress * 100).round()}% Complete';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Today's Context", style: textTheme.titleMedium),
        Text(
          'Updated just now',
          style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: AppSizes.md),
        Row(
          children: [
            Expanded(
              child: _ContextCard(
                icon: Icons.self_improvement_rounded,
                label: "Today's Task",
                value: data.todayTaskTitle ?? 'No task yet',
                sub: data.todayTaskCompleted ? 'Completed' : 'Not completed yet',
              ),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: _ContextCard(
                icon: Icons.mood_rounded,
                label: 'Mood',
                value: data.moodLabel ?? 'Not set',
                sub: data.moodScore != null ? '${data.moodScore}/10' : '—',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.md),
        Row(
          children: [
            Expanded(
              child: _ContextCard(
                icon: Icons.menu_book_rounded,
                label: 'Journal',
                value: '${data.journalEntriesToday} entries today',
                sub: 'View latest',
              ),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: _ContextCard(
                icon: Icons.trending_up_rounded,
                label: 'Progress',
                value: 'Day ${data.recoveryDay} of ${data.totalDays}',
                sub: progress,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ContextCard extends StatelessWidget {
  const _ContextCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.sub,
  });

  final IconData icon;
  final String label;
  final String value;
  final String sub;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: AppSizes.iconSm, color: colorScheme.primary),
              const SizedBox(width: AppSizes.xs),
              Expanded(
                child: Text(
                  label,
                  style: textTheme.labelMedium
                      ?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.titleSmall,
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: textTheme.bodySmall
                ?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _RecentConversations extends ConsumerWidget {
  const _RecentConversations({required this.onViewAll, required this.onOpen});

  final VoidCallback onViewAll;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final conversationsAsync = ref.watch(conversationsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Recent Conversations', style: textTheme.titleMedium),
            const Spacer(),
            TextButton(onPressed: onViewAll, child: const Text('View All')),
          ],
        ),
        conversationsAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(AppSizes.md),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, __) => Text(
            'Could not load conversations.',
            style: textTheme.bodySmall,
          ),
          data: (conversations) {
            if (conversations.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                child: Text(
                  'No conversations yet. Start one below.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              );
            }
            final recent = conversations.take(5).toList();
            return Column(
              children: [
                for (final c in recent)
                  ConversationTile(
                    conversation: c,
                    onTap: () => onOpen(c.id),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
