import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../home/presentation/widgets/home_style.dart';
import '../../domain/entities/chat_message.dart';
import 'markdown_text.dart';

/// The AI Coach avatar (a purple gradient disc) shown beside AI messages and the
/// typing indicator.
class CoachAvatar extends StatelessWidget {
  const CoachAvatar({super.key, this.size = 34});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        gradient: HomeStyle.scoreGradient,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.auto_awesome_rounded,
        size: size * 0.52,
        color: Colors.white,
      ),
    );
  }
}

/// A single chat bubble. User messages are trailing purple-gradient bubbles with
/// white text; AI messages are leading white cards with an avatar and Markdown.
/// Long-press copies the text.
class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final time = DateFormat('h:mm a').format(message.timestamp);

    final bubble = Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * 0.76,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm + 2,
      ),
      decoration: BoxDecoration(
        gradient: isUser ? HomeStyle.scoreGradient : null,
        color: isUser ? null : HomeStyle.card,
        border: isUser ? null : Border.all(color: HomeStyle.border),
        boxShadow: HomeStyle.softShadow,
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
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14.5,
                height: 1.4,
              ),
            )
          else
            MarkdownText(
              data: message.text,
              style: const TextStyle(
                color: HomeStyle.ink,
                fontSize: 14.5,
                height: 1.45,
              ),
            ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                time,
                style: TextStyle(
                  fontSize: 10.5,
                  color: isUser
                      ? Colors.white.withValues(alpha: 0.85)
                      : HomeStyle.inkSoft,
                ),
              ),
              if (isUser) ...[
                const SizedBox(width: 4),
                Icon(
                  message.pending ? Icons.check_rounded : Icons.done_all_rounded,
                  size: 14,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ],
            ],
          ),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.xs + 1),
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

/// Animated "AI Coach is typing…" indicator (three pulsing dots).
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.xs + 1),
      child: Row(
        children: [
          const CoachAvatar(),
          const SizedBox(width: AppSizes.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md,
              vertical: AppSizes.sm + 2,
            ),
            decoration: BoxDecoration(
              color: HomeStyle.card,
              border: Border.all(color: HomeStyle.border),
              boxShadow: HomeStyle.softShadow,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppSizes.radiusLg),
                topRight: Radius.circular(AppSizes.radiusLg),
                bottomLeft: Radius.circular(AppSizes.xs),
                bottomRight: Radius.circular(AppSizes.radiusLg),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < 3; i++)
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) {
                      final t = (_controller.value + i * 0.2) % 1.0;
                      final opacity =
                          0.3 + 0.7 * (1 - (t - 0.5).abs() * 2).clamp(0.0, 1.0);
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Opacity(
                          opacity: opacity,
                          child: const CircleAvatar(
                            radius: 3.5,
                            backgroundColor: HomeStyle.primary,
                          ),
                        ),
                      );
                    },
                  ),
                const SizedBox(width: AppSizes.sm),
                const Text(
                  'AI Coach is typing…',
                  style: TextStyle(fontSize: 12.5, color: HomeStyle.inkSoft),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
