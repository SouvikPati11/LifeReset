import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/ls_kit.dart';
import '../../../home/presentation/widgets/home_style.dart';
import '../../domain/entities/conversation.dart';
import 'message_bubble.dart';

/// A single recent-conversation card.
class ConversationTile extends StatelessWidget {
  const ConversationTile({
    super.key,
    required this.conversation,
    required this.onTap,
  });

  final Conversation conversation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return LsCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSizes.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CoachAvatar(size: 40),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        conversation.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: HomeStyle.ink,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSizes.sm),
                    Text(
                      _timeLabel(conversation.updatedAt),
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: HomeStyle.inkSoft,
                      ),
                    ),
                  ],
                ),
                if (conversation.lastMessage.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    conversation.lastMessage,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: HomeStyle.inkSoft,
                      height: 1.35,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          const Icon(Icons.chevron_right_rounded,
              color: HomeStyle.inkSoft, size: 20),
        ],
      ),
    );
  }

  String _timeLabel(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final that = DateTime(time.year, time.month, time.day);
    final diffDays = today.difference(that).inDays;
    if (diffDays == 0) return DateFormat('h:mm a').format(time);
    if (diffDays == 1) return 'Yesterday';
    if (diffDays < 7) return '$diffDays days ago';
    return DateFormat('MMM d').format(time);
  }
}
