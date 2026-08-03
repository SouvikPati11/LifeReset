import '../../../../core/utils/result.dart';
import '../entities/chat_message.dart';
import '../entities/coach_context.dart';
import '../entities/coach_reply.dart';
import '../entities/conversation.dart';
import '../entities/message_quota.dart';
import '../repositories/coach_repository.dart';

/// Streams the user's AI Coach conversations.
class WatchConversations {
  const WatchConversations(this._repo);
  final CoachRepository _repo;
  Stream<List<Conversation>> call(String uid) => _repo.watchConversations(uid);
}

/// Streams the messages of a conversation.
class WatchMessages {
  const WatchMessages(this._repo);
  final CoachRepository _repo;
  Stream<List<ChatMessage>> call(String uid, String conversationId) =>
      _repo.watchMessages(uid, conversationId);
}

/// Streams the raw daily-usage counter.
class WatchUsage {
  const WatchUsage(this._repo);
  final CoachRepository _repo;
  Stream<MessageUsage> call(String uid) => _repo.watchUsage(uid);
}

/// Reads the current recovery context.
class GetCoachContext {
  const GetCoachContext(this._repo);
  final CoachRepository _repo;
  Future<Result<CoachContext>> call(String uid) => _repo.getContext(uid);
}

/// Creates a new conversation, returning its id.
class CreateConversation {
  const CreateConversation(this._repo);
  final CoachRepository _repo;
  Future<Result<String>> call(String uid) => _repo.createConversation(uid);
}

/// Sends a user message and returns the AI reply.
class SendCoachMessage {
  const SendCoachMessage(this._repo);
  final CoachRepository _repo;
  Future<Result<CoachReply>> call({
    required String uid,
    required String conversationId,
    required String text,
    required CoachContext context,
    required List<ChatMessage> history,
  }) =>
      _repo.sendMessage(
        uid: uid,
        conversationId: conversationId,
        text: text,
        context: context,
        history: history,
      );
}

/// Retries the AI reply for an already-sent message.
class RetryCoachReply {
  const RetryCoachReply(this._repo);
  final CoachRepository _repo;
  Future<Result<CoachReply>> call({
    required String uid,
    required String conversationId,
    required String text,
    required CoachContext context,
    required List<ChatMessage> history,
  }) =>
      _repo.retryReply(
        uid: uid,
        conversationId: conversationId,
        text: text,
        context: context,
        history: history,
      );
}
