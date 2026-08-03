import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/journal_prompt.dart';

/// Maps a `journal_prompts/{id}` document to [JournalPrompt].
class JournalPromptModel {
  const JournalPromptModel._();

  static JournalPrompt fromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return JournalPrompt(
      id: doc.id,
      category: (data['category'] as String?) ?? 'General',
      text: (data['text'] as String?) ?? '',
    );
  }
}
