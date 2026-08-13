import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/ls_kit.dart';
import '../../../home/presentation/widgets/home_style.dart';
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
  const ChatScreen({
    super.key,
    required this.conversationId,
    this.initialDraft,
  });

  final String conversationId;

  /// Optional text to pre-fill the composer with (e.g. a suggested topic). The
  /// user still taps send — no message is sent automatically.
  final String? initialDraft;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();

  String get _cid => widget.conversationId;

  @override
  void initState() {
    super.initState();
    if (widget.initialDraft != null && widget.initialDraft!.isNotEmpty) {
      _input.text = widget.initialDraft!;
    }
  }

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
      backgroundColor: HomeStyle.background,
      body: SafeArea(
        child: Column(
          children: [
            _ChatHeader(
              onBack: () => Navigator.of(context).maybePop(),
              onMore: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SuggestedActionsScreen(conversationId: _cid),
                ),
              ),
            ),
            if (chatState.crisisActive)
              CrisisBanner(onDismiss: controller.dismissCrisis),
            if (chatState.limitReached) const LimitBanner(),
            Expanded(
              child: messagesAsync.when(
                loading: () => const LsLoader(),
                error: (_, __) => const LsErrorState(
                  title: 'Could not load chat',
                  message: 'Please go back and try again.',
                ),
                data: (messages) => _MessageList(
                  scrollController: _scroll,
                  messages: messages,
                  isTyping: chatState.isTyping,
                  failedText: chatState.failedText,
                  onRetry: controller.retry,
                ),
              ),
            ),
            _Composer(
              input: _input,
              enabled: !chatState.isTyping && !chatState.limitReached,
              sending: chatState.isTyping,
              onSend: controller.send,
              onQuickAction: _openTool,
            ),
          ],
        ),
      ),
    );
  }
}

/// A clean chat header with the Coach identity and an online status dot.
class _ChatHeader extends StatelessWidget {
  const _ChatHeader({required this.onBack, required this.onMore});

  final VoidCallback onBack;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.sm,
        AppSizes.sm,
        AppSizes.sm,
        AppSizes.sm,
      ),
      decoration: const BoxDecoration(
        color: HomeStyle.card,
        border: Border(bottom: BorderSide(color: HomeStyle.border)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded, color: HomeStyle.ink),
            tooltip: 'Back',
          ),
          const CoachAvatar(size: 38),
          const SizedBox(width: AppSizes.sm),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'AI Coach',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: HomeStyle.ink,
                  ),
                ),
                Row(
                  children: [
                    _OnlineDot(),
                    SizedBox(width: 4),
                    Text('Online',
                        style:
                            TextStyle(fontSize: 11.5, color: HomeStyle.inkSoft)),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onMore,
            icon: const Icon(Icons.tune_rounded, color: HomeStyle.primary),
            tooltip: 'Suggested actions',
          ),
        ],
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.input,
    required this.enabled,
    required this.sending,
    required this.onSend,
    required this.onQuickAction,
  });

  final TextEditingController input;
  final bool enabled;
  final bool sending;
  final ValueChanged<String> onSend;
  final ValueChanged<String> onQuickAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: HomeStyle.card,
        border: Border(top: BorderSide(color: HomeStyle.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.md,
            AppSizes.sm,
            AppSizes.md,
            AppSizes.sm,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ChatInputBar(
                controller: input,
                enabled: enabled,
                sending: sending,
                onSend: onSend,
                onQuickAction: onQuickAction,
              ),
              const SizedBox(height: AppSizes.xs),
              const Text(
                'AI Coach can make mistakes. Always trust your judgment.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10.5, color: HomeStyle.inkSoft),
              ),
            ],
          ),
        ),
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
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.md),
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: HomeStyle.lavenderLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: HomeStyle.border),
      ),
      child: const Row(
        children: [
          CoachAvatar(size: 30),
          SizedBox(width: AppSizes.sm),
          Expanded(
            child: Text(
              "This is a safe space. Share anything you're feeling — I'm here to listen.",
              style: TextStyle(
                fontSize: 12.5,
                color: HomeStyle.ink,
                height: 1.4,
              ),
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
    return const Padding(
      padding: EdgeInsets.only(bottom: AppSizes.sm),
      child: Center(
        child: Text(
          'Today',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: HomeStyle.inkSoft,
          ),
        ),
      ),
    );
  }
}

class _RetryRow extends StatelessWidget {
  const _RetryRow({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 18, color: Color(0xFFB91C1C)),
          const SizedBox(width: AppSizes.xs),
          const Text(
            "Couldn't get a reply.",
            style: TextStyle(fontSize: 12.5, color: HomeStyle.inkSoft),
          ),
          TextButton.icon(
            onPressed: onRetry,
            style: TextButton.styleFrom(foregroundColor: HomeStyle.primary),
            icon: const Icon(Icons.refresh_rounded, size: 18),
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
        color: HomeStyle.success,
        shape: BoxShape.circle,
      ),
    );
  }
}
