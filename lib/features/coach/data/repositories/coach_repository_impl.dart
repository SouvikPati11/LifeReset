import '../../../../core/utils/result.dart';
import '../../../../shared/repositories/base_repository.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/coach_context.dart';
import '../../domain/entities/coach_reply.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message_quota.dart';
import '../../domain/repositories/coach_repository.dart';
import '../datasources/coach_remote_data_source.dart';

/// [CoachRepository] backed by Firestore (history) and a Cloud Function (Gemini).
class CoachRepositoryImpl extends BaseRepository implements CoachRepository {
  CoachRepositoryImpl(this._remote);

  final CoachRemoteDataSource _remote;

  @override
  Stream<List<Conversation>> watchConversations(String uid) =>
      _remote.watchConversations(uid);

  @override
  Stream<List<ChatMessage>> watchMessages(String uid, String conversationId) =>
      _remote.watchMessages(uid, conversationId);

  @override
  Stream<MessageUsage> watchUsage(String uid) => _remote.watchUsage(uid);

  @override
  Future<Result<CoachContext>> getContext(String uid) {
    return guard<CoachContext>(() => _remote.getContext(uid));
  }

  @override
  Future<Result<String>> createConversation(String uid) {
    return guard<String>(() => _remote.createConversation(uid));
  }

  @override
  Future<Result<CoachReply>> sendMessage({
    required String uid,
    required String conversationId,
    required String text,
    required CoachContext context,
    required List<ChatMessage> history,
  }) {
    return guard<CoachReply>(() async {
      await _remote.writeUserMessage(
        uid: uid,
        conversationId: conversationId,
        text: text,
      );
      return _remote.requestReply(
        uid: uid,
        conversationId: conversationId,
        text: text,
        context: context,
        history: history,
      );
    });
  }

  @override
  Future<Result<CoachReply>> retryReply({
    required String uid,
    required String conversationId,
    required String text,
    required CoachContext context,
    required List<ChatMessage> history,
  }) {
    return guard<CoachReply>(
      () => _remote.requestReply(
        uid: uid,
        conversationId: conversationId,
        text: text,
        context: context,
        history: history,
      ),
    );
  }
}
