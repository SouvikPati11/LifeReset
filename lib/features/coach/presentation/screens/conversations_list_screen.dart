import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/ls_kit.dart';
import '../../../home/presentation/widgets/home_style.dart';
import '../providers/coach_providers.dart';
import '../widgets/conversation_tile.dart';
import 'chat_screen.dart';

/// Full list of the user's AI Coach conversations.
class ConversationsListScreen extends ConsumerWidget {
  const ConversationsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(conversationsProvider);
    return Scaffold(
      backgroundColor: HomeStyle.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            LsHeader(
              title: 'Conversations',
              subtitle: 'Your chat history',
              onBack: () => Navigator.of(context).maybePop(),
            ),
            const SizedBox(height: AppSizes.md),
            Expanded(
              child: conversationsAsync.when(
                loading: () => const LsLoader(),
                error: (_, __) => LsErrorState(
                  title: 'Could not load conversations',
                  onRetry: () => ref.invalidate(conversationsProvider),
                ),
                data: (conversations) {
                  if (conversations.isEmpty) {
                    return const LsEmpty(
                      icon: Icons.forum_rounded,
                      title: 'No conversations yet',
                      message:
                          'Start a chat with your AI Coach to see it here.',
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      AppSizes.lg,
                      0,
                      AppSizes.lg,
                      AppSizes.xl,
                    ),
                    itemCount: conversations.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSizes.sm),
                    itemBuilder: (context, index) => ConversationTile(
                      conversation: conversations[index],
                      // Open the immersive chat full-screen (root navigator).
                      onTap: () => Navigator.of(context, rootNavigator: true)
                          .push(
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            conversationId: conversations[index].id,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
