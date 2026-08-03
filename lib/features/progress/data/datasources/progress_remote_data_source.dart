import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/progress_models.dart';

/// Firestore data source for the Progress feature (reads of the user's own
/// `users/{uid}` document and its `mood_history` / `journal_entries`
/// subcollections).
class ProgressRemoteDataSource {
  ProgressRemoteDataSource(this._db);

  final FirebaseFirestore _db;

  /// mood value → (0–10 score, emoji). Kept local so this module is
  /// self-contained.
  static const Map<String, (int, String)> _moodScale = {
    'awful': (1, '😣'),
    'sad': (3, '😢'),
    'anxious': (4, '😰'),
    'okay': (6, '😐'),
    'good': (8, '🙂'),
    'great': (10, '😄'),
  };

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _db.collection(AppConstants.usersCollection).doc(uid);

  Stream<ProgressStats> watchStats(String uid) {
    return _userDoc(uid).snapshots().map((doc) {
      final data = doc.data() ?? const <String, dynamic>{};

      final completed = (data['completedTasks'] as List<dynamic>?)?.length ?? 0;

      final history = (data['scoreHistory'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(_sampleFromMap)
              .whereType<RecoverySample>()
              .toList() ??
          <RecoverySample>[];
      history.sort((a, b) => a.date.compareTo(b.date));

      return ProgressStats(
        recoveryScore: (data['recoveryScore'] as num?)?.toInt() ?? 0,
        streak: (data['streak'] as num?)?.toInt() ?? 0,
        currentDay: (data['currentDay'] as num?)?.toInt() ?? 1,
        completedTasks: completed,
        scoreHistory: history,
      );
    });
  }

  Stream<List<MoodSample>> watchMoodHistory(String uid, {int days = 14}) {
    return _userDoc(uid)
        .collection('mood_history')
        .orderBy('date', descending: true)
        .limit(days)
        .snapshots()
        .map((snap) {
      final list = snap.docs.map((d) {
        final data = d.data();
        final moodValue = (data['mood'] as String?) ?? 'okay';
        final scale = _moodScale[moodValue] ?? const (6, '😐');
        final date = (data['date'] as Timestamp?)?.toDate() ??
            DateTime.tryParse(d.id) ??
            DateTime.now();
        return MoodSample(date: date, score: scale.$1, emoji: scale.$2);
      }).toList();
      // Oldest → newest for charting.
      list.sort((a, b) => a.date.compareTo(b.date));
      return list;
    });
  }

  Future<int> journalCount(String uid) async {
    try {
      final snap = await _userDoc(uid).collection('journal_entries').count().get();
      return snap.count ?? 0;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to load journal count.',
          code: e.code);
    }
  }

  RecoverySample? _sampleFromMap(Map<String, dynamic> map) {
    final raw = map['date'];
    final DateTime? date = switch (raw) {
      Timestamp t => t.toDate(),
      String s => DateTime.tryParse(s),
      _ => null,
    };
    if (date == null) return null;
    return RecoverySample(date: date, score: (map['score'] as num?)?.toInt() ?? 0);
  }
}
