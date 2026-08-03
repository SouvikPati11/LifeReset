import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/mood_entry.dart';
import '../models/mood_entry_model.dart';

/// Remote data source for mood history.
abstract interface class MoodRemoteDataSource {
  Stream<MoodEntry?> watchTodayMood(String uid);
  Stream<List<MoodEntry>> watchHistory(String uid, {required int days});
  Future<void> saveMood(String uid, String dateId, Map<String, dynamic> data);
}

class FirebaseMoodRemoteDataSource implements MoodRemoteDataSource {
  FirebaseMoodRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _moods(String uid) => _firestore
      .collection(AppConstants.usersCollection)
      .doc(uid)
      .collection('mood_history');

  static String dateId(DateTime date) {
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '${date.year}-$m-$d';
  }

  @override
  Stream<MoodEntry?> watchTodayMood(String uid) {
    return _moods(uid).doc(dateId(DateTime.now())).snapshots().map(
          (doc) => doc.exists ? MoodEntryModel.fromFirestore(doc) : null,
        );
  }

  @override
  Stream<List<MoodEntry>> watchHistory(String uid, {required int days}) {
    final since = DateTime.now().subtract(Duration(days: days));
    final sinceTs =
        Timestamp.fromDate(DateTime(since.year, since.month, since.day));
    return _moods(uid)
        .where('date', isGreaterThanOrEqualTo: sinceTs)
        .orderBy('date')
        .snapshots()
        .map((snap) => snap.docs
            .map(MoodEntryModel.fromFirestore)
            .toList(growable: false));
  }

  @override
  Future<void> saveMood(
      String uid, String dateId, Map<String, dynamic> data) async {
    try {
      await _moods(uid).doc(dateId).set(data, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to save mood.', code: e.code);
    }
  }
}
