import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/journal_prompt.dart';
import '../models/journal_prompt_model.dart';

/// Remote data source for journal writing prompts (shared content).
abstract interface class PromptsRemoteDataSource {
  Future<List<JournalPrompt>> getPrompts();
}

class FirebasePromptsRemoteDataSource implements PromptsRemoteDataSource {
  FirebasePromptsRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Future<List<JournalPrompt>> getPrompts() async {
    try {
      final snap = await _firestore.collection('journal_prompts').get();
      return snap.docs
          .map(JournalPromptModel.fromFirestore)
          .toList(growable: false);
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to load prompts.', code: e.code);
    }
  }
}
