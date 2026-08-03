import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../domain/entities/chat_message.dart';
import '../controllers/chat_controller.dart';
import '../providers/coach_providers.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/coach_banners.dart';
import '../widgets/message_bubble.dart';
import 'coach_placeholder_screen.dart';
import 'suggested_actions_screen.dart';

/// The AI Coach chat interface for a single conversation.
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.conversationId});

  final String conversationId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();

  String get _cid => widget.conversationId;

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _openTool(String title) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CoachPlaceholderScreen(title: title)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(messagesProvider(_cid));
    final chatState = ref.watch(chatControllerProvider(_cid));
    final controller = ref.read(chatControllerProvider(_cid).notifier);

    ref.listen(messagesProvider(_cid), (_, __) => _scrollToEnd());
    ref.listen(chatControllerProvider(_cid), (_, __) => _scrollToEnd());

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            const CoachAvatar(size: 36),
            const SizedBox(width: AppSizes.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('AI Coach', style: Theme.of(context).textTheme.titleMedium),
                Row(
                  children: [
                    const _OnlineDot(),
                    const SizedBox(width: 4),
                    Text('Online',
                        style: Theme.of(context).textTheme.labelSmall),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz_rounded),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    SuggestedActionsScreen(conversationId: _cid),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (chatState.crisisActive)
            CrisisBanner(onDismiss: controller.dismissCrisis),
          if (chatState.limitReached) const LimitBanner(),
          Expanded(
            child: messagesAsync.when(
              loading: () => const LoadingView(),
              error: (_, __) => const Center(child: Text('Could not load chat')),
              data: (messages) => _MessageList(
                scrollController: _scroll,
                messages: messages,
                isTyping: chatState.isTyping,
                failedText: chatState.failedText,
                onRetry: controller.retry,
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.md,
                AppSizes.sm,
                AppSizes.md,
                AppSizes.sm,
              ),
              child: Column(
                children: [
                  ChatInputBar(
                    controller: _input,
                    enabled: !chatState.isTyping && !chatState.limitReached,
                    onSend: controller.send,
                    onQuickAction: _openTool,
                  ),
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    'AI Coach can make mistakes. Always trust your judgment.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageList extends StatelessWidget {
  const _MessageList({
    required this.scrollController,
    required this.messages,
    required this.isTyping,
    required this.failedText,
    required this.onRetry,
  });

  final ScrollController scrollController;
  final List<ChatMessage> messages;
  final bool isTyping;
  final String? failedText;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(AppSizes.md),
      children: [
        const _IntroBubble(),
        const _TodayDivider(),
        for (final message in messages) MessageBubble(message: message),
        if (isTyping) const TypingIndicator(),
        if (failedText != null) _RetryRow(onRetry: onRetry),
      ],
    );
  }
}

class _IntroBubble extends StatelessWidget {
  const _IntroBubble();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.md),
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Row(
        children: [
          const CoachAvatar(size: 28),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Text(
              "This is a safe space. Share anything you're feeling. I'm here to listen.",
              style: textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayDivider extends StatelessWidget {
  const _TodayDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.sm),
      child: Center(
        child: Text('Today', style: Theme.of(context).textTheme.labelSmall),
      ),
    );
  }
}

class _RetryRow extends StatelessWidget {
  const _RetryRow({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded,
              size: AppSizes.iconSm, color: colorScheme.error),
          const SizedBox(width: AppSizes.xs),
          Text(
            "Couldn't get a reply.",
            style: Theme.of(context).textTheme.bodySmall,
          ),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: AppSizes.iconSm),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _OnlineDot extends StatelessWidget {
  const _OnlineDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: Color(0xFF2E9E63),
        shape: BoxShape.circle,
      ),
    );
  }
}
