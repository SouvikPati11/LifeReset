import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/conversation.dart';

/// Maps a conversation document to [Conversation].
class ConversationModel {
  const ConversationModel._();

  static Conversation fromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return Conversation(
      id: doc.id,
      title: (data['title'] as String?) ?? 'New Conversation',
      lastMessage: (data['lastMessage'] as String?) ?? '',
      updatedAt:
          (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
