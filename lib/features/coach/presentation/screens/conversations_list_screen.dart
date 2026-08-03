import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/empty_view.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_view.dart';
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
      appBar: AppBar(title: const Text('Conversations')),
      body: SafeArea(
        child: conversationsAsync.when(
          loading: () => const LoadingView(),
          error: (_, __) => ErrorView(
            title: 'Could not load conversations',
            onRetry: () => ref.invalidate(conversationsProvider),
          ),
          data: (conversations) {
            if (conversations.isEmpty) {
              return const EmptyView(
                title: 'No conversations yet',
                message: 'Start a chat with your AI Coach to see it here.',
                icon: Icons.forum_outlined,
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(AppSizes.md),
              itemCount: conversations.length,
              itemBuilder: (context, index) => ConversationTile(
                conversation: conversations[index],
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(
                      conversationId: conversations[index].id,
                    ),
                  ),
                ),
              ),
              separatorBuilder: (_, __) => const Divider(height: 1),
            );
          },
        ),
      ),
    );
  }
}
