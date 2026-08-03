/// Metadata for an AI Coach conversation (`users/{uid}/ai_conversations/{id}`).
class Conversation {
  const Conversation({
    required this.id,
    required this.title,
    required this.lastMessage,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String lastMessage;
  final DateTime updatedAt;
}
