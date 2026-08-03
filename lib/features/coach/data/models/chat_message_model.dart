import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/chat_message.dart';

/// Maps an AI Coach message document to [ChatMessage].
class ChatMessageModel {
  const ChatMessageModel._();

  static ChatMessage fromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final sender = (data['sender'] as String?) == 'ai'
        ? ChatSender.ai
        : ChatSender.user;
    return ChatMessage(
      id: doc.id,
      conversationId: (data['conversationId'] as String?) ?? '',
      text: (data['message'] as String?) ?? '',
      sender: sender,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ??
          _fromMillis(data['createdAt']),
      pending: doc.metadata.hasPendingWrites,
    );
  }

  static DateTime _fromMillis(Object? millis) {
    if (millis is int) return DateTime.fromMillisecondsSinceEpoch(millis);
    return DateTime.now();
  }

  /// Builds the write payload for a new message.
  ///
  /// `createdAt` is a client millisecond timestamp used purely for ordering, so
  /// optimistic messages appear immediately (a pending server timestamp is null
  /// locally and would otherwise drop the message from an ordered query).
  static Map<String, dynamic> toCreateMap({
    required String conversationId,
    required String text,
    required ChatSender sender,
  }) {
    return {
      'conversationId': conversationId,
      'message': text,
      'sender': sender == ChatSender.ai ? 'ai' : 'user',
      'timestamp': FieldValue.serverTimestamp(),
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    };
  }
}
