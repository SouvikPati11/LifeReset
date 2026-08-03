/// Who authored a chat message.
enum ChatSender { user, ai }

/// A single message within an AI Coach conversation.
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.text,
    required this.sender,
    required this.timestamp,
    this.pending = false,
  });

  final String id;
  final String conversationId;
  final String text;
  final ChatSender sender;
  final DateTime timestamp;

  /// True while the write is still syncing to Firestore (optimistic UI).
  final bool pending;

  bool get isUser => sender == ChatSender.user;
}
