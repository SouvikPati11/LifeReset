import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../domain/entities/chat_message.dart';
import 'markdown_text.dart';

/// The AI Coach avatar used beside AI messages and the typing indicator.
class CoachAvatar extends StatelessWidget {
  const CoachAvatar({super.key, this.size = 32});

  final double size;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.smart_toy_rounded,
        size: size * 0.6,
        color: colorScheme.primary,
      ),
    );
  }
}

/// A single chat bubble. User messages are trailing/filled; AI messages are
/// leading with an avatar and Markdown rendering. Long-press copies the text.
class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isUser = message.isUser;
    final time = DateFormat('h:mm a').format(message.timestamp);

    final bubble = Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * 0.75,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm,
      ),
      decoration: BoxDecoration(
        color: isUser ? colorScheme.primary : colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(AppSizes.radiusLg),
          topRight: const Radius.circular(AppSizes.radiusLg),
          bottomLeft: Radius.circular(isUser ? AppSizes.radiusLg : AppSizes.xs),
          bottomRight: Radius.circular(isUser ? AppSizes.xs : AppSizes.radiusLg),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (isUser)
            Text(
              message.text,
              style: textTheme.bodyMedium?.copyWith(color: Colors.white),
            )
          else
            MarkdownText(
              data: message.text,
              style: textTheme.bodyMedium,
            ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                time,
                style: textTheme.labelSmall?.copyWith(
                  color: isUser
                      ? Colors.white.withValues(alpha: 0.8)
                      : colorScheme.onSurfaceVariant,
                ),
              ),
              if (isUser) ...[
                const SizedBox(width: 4),
                Icon(
                  message.pending ? Icons.check_rounded : Icons.done_all_rounded,
                  size: 14,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ],
            ],
          ),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.xs),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            const CoachAvatar(),
            const SizedBox(width: AppSizes.sm),
          ],
          Flexible(
            child: GestureDetector(
              onLongPress: () => _copy(context),
              child: bubble,
            ),
          ),
        ],
      ),
    );
  }

  void _copy(BuildContext context) {
    Clipboard.setData(ClipboardData(text: message.text));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Message copied')));
  }
}

/// Animated "AI Coach is typing…" indicator.
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.xs),
      child: Row(
        children: [
          const CoachAvatar(),
          const SizedBox(width: AppSizes.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md,
              vertical: AppSizes.sm,
            ),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < 3; i++)
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) {
                      final t = (_controller.value + i * 0.2) % 1.0;
                      final opacity = 0.3 + 0.7 * (1 - (t - 0.5).abs() * 2).clamp(0.0, 1.0);
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Opacity(
                          opacity: opacity,
                          child: CircleAvatar(
                            radius: 3,
                            backgroundColor: colorScheme.primary,
                          ),
                        ),
                      );
                    },
                  ),
                const SizedBox(width: AppSizes.sm),
                Text('AI Coach is typing…', style: textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
