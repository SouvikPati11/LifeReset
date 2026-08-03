import '../../../../core/utils/result.dart';
import '../entities/chat_message.dart';
import '../entities/coach_context.dart';
import '../entities/coach_reply.dart';
import '../entities/conversation.dart';
import '../entities/message_quota.dart';

/// Contract for the AI Coach: conversation history (Firestore) and replies
/// (Gemini, exclusively via a Firebase Cloud Function).
abstract interface class CoachRepository {
  /// Streams the user's conversations, most recent first.
  Stream<List<Conversation>> watchConversations(String uid);

  /// Streams the messages of a conversation in chronological order.
  Stream<List<ChatMessage>> watchMessages(String uid, String conversationId);

  /// Streams the raw daily-usage counter (combined with the plan into a
  /// [MessageQuota] in the presentation layer).
  Stream<MessageUsage> watchUsage(String uid);

  /// Assembles the current recovery context for the AI and the home card.
  Future<Result<CoachContext>> getContext(String uid);

  /// Creates a new conversation and returns its id.
  Future<Result<String>> createConversation(String uid);

  /// Persists the user's message, requests a reply through the Cloud Function,
  /// and persists the AI reply. Returns the reply.
  Future<Result<CoachReply>> sendMessage({
    required String uid,
    required String conversationId,
    required String text,
    required CoachContext context,
    required List<ChatMessage> history,
  });

  /// Re-requests a reply for an already-sent user message (retry path).
  Future<Result<CoachReply>> retryReply({
    required String uid,
    required String conversationId,
    required String text,
    required CoachContext context,
    required List<ChatMessage> history,
  });
}
