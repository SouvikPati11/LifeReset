import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/journal_entry.dart';
import '../../domain/repositories/journal_repository.dart';
import '../models/journal_entry_model.dart';

/// Remote data source for journal entries. AI insights reuse the existing AI
/// Coach backend (the `coachChat` Cloud Function) — no new AI system.
abstract interface class JournalRemoteDataSource {
  Stream<List<JournalEntry>> watchRecentEntries(String uid, {required int limit});
  Future<int> countEntries(String uid);
  Future<JournalPage> fetchPage(String uid, {DateTime? before, required int limit});
  Future<JournalEntry?> getEntry(String uid, String entryId);
  Stream<JournalEntry?> watchEntry(String uid, String entryId);
  Future<String> createEntry(String uid, Map<String, dynamic> data);
  Future<void> updateEntry(String uid, String entryId, Map<String, dynamic> data);
  Future<void> deleteEntry(String uid, String entryId);
  Future<String> generateInsight(String uid,
      {required String entryId, required String content});
}

class FirebaseJournalRemoteDataSource implements JournalRemoteDataSource {
  FirebaseJournalRemoteDataSource(this._firestore, this._functions);

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  CollectionReference<Map<String, dynamic>> _entries(String uid) => _firestore
      .collection(AppConstants.usersCollection)
      .doc(uid)
      .collection('journal_entries');

  @override
  Stream<List<JournalEntry>> watchRecentEntries(String uid, {required int limit}) {
    return _entries(uid)
        .orderBy('createdAtMs', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs
            .map(JournalEntryModel.fromFirestore)
            .toList(growable: false));
  }

  @override
  Future<int> countEntries(String uid) async {
    try {
      final snap = await _entries(uid).count().get();
      return snap.count ?? 0;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to count entries.', code: e.code);
    }
  }

  @override
  Future<JournalPage> fetchPage(String uid,
      {DateTime? before, required int limit}) async {
    try {
      Query<Map<String, dynamic>> query =
          _entries(uid).orderBy('createdAtMs', descending: true);
      if (before != null) {
        query = query.where('createdAtMs',
            isLessThan: before.millisecondsSinceEpoch);
      }
      final snap = await query.limit(limit + 1).get();
      final hasMore = snap.docs.length > limit;
      final docs = hasMore ? snap.docs.take(limit) : snap.docs;
      return JournalPage(
        entries: docs.map(JournalEntryModel.fromFirestore).toList(growable: false),
        hasMore: hasMore,
      );
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to load entries.', code: e.code);
    }
  }

  @override
  Future<JournalEntry?> getEntry(String uid, String entryId) async {
    try {
      final doc = await _entries(uid).doc(entryId).get();
      return doc.exists ? JournalEntryModel.fromFirestore(doc) : null;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to load entry.', code: e.code);
    }
  }

  @override
  Stream<JournalEntry?> watchEntry(String uid, String entryId) {
    return _entries(uid).doc(entryId).snapshots().map(
          (doc) => doc.exists ? JournalEntryModel.fromFirestore(doc) : null,
        );
  }

  @override
  Future<String> createEntry(String uid, Map<String, dynamic> data) async {
    try {
      final ref = await _entries(uid).add(data);
      return ref.id;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to save entry.', code: e.code);
    }
  }

  @override
  Future<void> updateEntry(
      String uid, String entryId, Map<String, dynamic> data) async {
    try {
      await _entries(uid).doc(entryId).update(data);
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to update entry.', code: e.code);
    }
  }

  @override
  Future<void> deleteEntry(String uid, String entryId) async {
    try {
      await _entries(uid).doc(entryId).delete();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to delete entry.', code: e.code);
    }
  }

  @override
  Future<String> generateInsight(String uid,
      {required String entryId, required String content}) async {
    final message =
        'Please read my journal entry and reply with a short, warm, encouraging '
        'insight (maximum 2 short paragraphs). Journal entry:\n\n$content';
    try {
      final result = await _functions.httpsCallable('coachChat').call({
        'message': message,
        'conversationId': 'journal-$entryId',
        'context': const <String, dynamic>{'source': 'journal'},
        'history': const <dynamic>[],
      });
      final data = Map<String, dynamic>.from(result.data as Map);
      final insight = _trimToTwoParagraphs((data['reply'] as String?) ?? '');
      await _entries(uid).doc(entryId).update({'aiInsight': insight});
      return insight;
    } on FirebaseFunctionsException catch (e) {
      throw ServerException(
        e.message ?? 'Could not generate insight.',
        code: e.code,
      );
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Could not save insight.', code: e.code);
    }
  }

  String _trimToTwoParagraphs(String text) {
    final paragraphs = text
        .trim()
        .split(RegExp(r'\n\s*\n'))
        .where((p) => p.trim().isNotEmpty)
        .toList();
    if (paragraphs.length <= 2) return text.trim();
    return paragraphs.take(2).join('\n\n');
  }
}
