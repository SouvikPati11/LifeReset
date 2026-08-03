import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/coach_context.dart';
import '../../domain/entities/coach_reply.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message_quota.dart';
import '../models/chat_message_model.dart';
import '../models/conversation_model.dart';

/// Remote data source for the AI Coach: conversation history (Firestore) and
/// replies (Gemini, via the `coachChat` Cloud Function).
abstract interface class CoachRemoteDataSource {
  Stream<List<Conversation>> watchConversations(String uid);
  Stream<List<ChatMessage>> watchMessages(String uid, String conversationId);
  Stream<MessageUsage> watchUsage(String uid);
  Future<CoachContext> getContext(String uid);
  Future<String> createConversation(String uid);
  Future<void> writeUserMessage({
    required String uid,
    required String conversationId,
    required String text,
  });
  Future<CoachReply> requestReply({
    required String uid,
    required String conversationId,
    required String text,
    required CoachContext context,
    required List<ChatMessage> history,
  });
}

class FirebaseCoachRemoteDataSource implements CoachRemoteDataSource {
  FirebaseCoachRemoteDataSource(this._firestore, this._functions);

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  static const int _historyLimit = 10;
  static const int _programDays = 30;

  CollectionReference<Map<String, dynamic>> _conversations(String uid) =>
      _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .collection('ai_conversations');

  CollectionReference<Map<String, dynamic>> _messages(
    String uid,
    String conversationId,
  ) =>
      _conversations(uid).doc(conversationId).collection('messages');

  @override
  Stream<List<Conversation>> watchConversations(String uid) {
    return _conversations(uid)
        .orderBy('updatedAtMs', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map(ConversationModel.fromFirestore)
            .toList(growable: false));
  }

  @override
  Stream<List<ChatMessage>> watchMessages(String uid, String conversationId) {
    return _messages(uid, conversationId)
        .orderBy('createdAt')
        .snapshots()
        .map((snap) => snap.docs
            .map(ChatMessageModel.fromFirestore)
            .toList(growable: false));
  }

  @override
  Stream<MessageUsage> watchUsage(String uid) {
    return _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .collection('private')
        .doc('ai_usage')
        .snapshots()
        .map((doc) {
      final data = doc.data();
      if (data == null) return MessageUsage.initial();
      return MessageUsage(
        used: (data['used'] as num?)?.toInt() ?? 0,
        resetsAt: (data['resetsAt'] as Timestamp?)?.toDate() ??
            MessageUsage.initial().resetsAt,
      );
    });
  }

  @override
  Future<CoachContext> getContext(String uid) async {
    try {
      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();
      final data = userDoc.data() ?? const <String, dynamic>{};

      final completed = (data['completedTasks'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toSet() ??
          <String>{};

      final taskSnap =
          await _firestore.collection('daily_tasks').orderBy('order').limit(1).get();
      String? taskTitle;
      var taskCompleted = false;
      if (taskSnap.docs.isNotEmpty) {
        final taskDoc = taskSnap.docs.first;
        taskTitle = taskDoc.data()['title'] as String?;
        taskCompleted = completed.contains(taskDoc.id);
      }

      return CoachContext(
        recoveryDay: (data['currentDay'] as num?)?.toInt() ?? 1,
        totalDays: _programDays,
        recoveryScore: (data['recoveryScore'] as num?)?.toInt() ?? 0,
        problemType: (data['problem'] as String?) ?? AppConstants.supportedProgram,
        streak: (data['streak'] as num?)?.toInt() ?? 0,
        journalEntriesToday: (data['journalEntriesToday'] as num?)?.toInt() ?? 0,
        todayTaskTitle: taskTitle,
        todayTaskCompleted: taskCompleted,
        moodLabel: data['moodLabel'] as String?,
        moodScore: (data['moodScore'] as num?)?.toInt(),
        previousSummary: (data['aiSummary'] as String?) ?? '',
      );
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to load context.', code: e.code);
    }
  }

  @override
  Future<String> createConversation(String uid) async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final ref = await _conversations(uid).add({
        'title': 'New Conversation',
        'lastMessage': '',
        'createdAtMs': now,
        'updatedAtMs': now,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return ref.id;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to start chat.', code: e.code);
    }
  }

  @override
  Future<void> writeUserMessage({
    required String uid,
    required String conversationId,
    required String text,
  }) async {
    try {
      await _messages(uid, conversationId).add(
        ChatMessageModel.toCreateMap(
          conversationId: conversationId,
          text: text,
          sender: ChatSender.user,
        ),
      );
      final convRef = _conversations(uid).doc(conversationId);
      final convSnap = await convRef.get();
      final currentTitle = convSnap.data()?['title'] as String?;
      final needsTitle =
          currentTitle == null || currentTitle.isEmpty || currentTitle == 'New Conversation';
      await convRef.set({
        'lastMessage': text,
        if (needsTitle) 'title': _title(text),
        'updatedAtMs': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to send message.', code: e.code);
    }
  }

  @override
  Future<CoachReply> requestReply({
    required String uid,
    required String conversationId,
    required String text,
    required CoachContext context,
    required List<ChatMessage> history,
  }) async {
    final recent = history.length > _historyLimit
        ? history.sublist(history.length - _historyLimit)
        : history;

    late final HttpsCallableResult result;
    try {
      result = await _functions.httpsCallable('coachChat').call({
        'message': text,
        'conversationId': conversationId,
        'context': context.toPromptMap(),
        'history': recent
            .map((m) => {
                  'sender': m.sender == ChatSender.ai ? 'ai' : 'user',
                  'message': m.text,
                })
            .toList(),
      });
    } on FirebaseFunctionsException catch (e) {
      throw ServerException(
        e.message ?? 'The coach is unavailable right now.',
        code: e.code,
      );
    }

    final data = Map<String, dynamic>.from(result.data as Map);
    final reply = (data['reply'] as String?)?.trim() ?? '';
    final isCrisis = data['isCrisis'] as bool? ?? false;
    final remaining = (data['remaining'] as num?)?.toInt();

    // Persist the AI reply.
    await _messages(uid, conversationId).add(
      ChatMessageModel.toCreateMap(
        conversationId: conversationId,
        text: reply,
        sender: ChatSender.ai,
      ),
    );
    await _conversations(uid).doc(conversationId).set({
      'lastMessage': reply,
      'updatedAtMs': DateTime.now().millisecondsSinceEpoch,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return CoachReply(text: reply, isCrisis: isCrisis, remaining: remaining);
  }

  String _title(String text) {
    final trimmed = text.trim();
    return trimmed.length <= 40 ? trimmed : '${trimmed.substring(0, 40)}…';
  }
}
