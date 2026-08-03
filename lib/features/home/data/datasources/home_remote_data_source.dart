import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/daily_quote.dart';
import '../../domain/entities/daily_task.dart';
import '../../domain/entities/recovery_program.dart';
import '../../domain/entities/user_stats.dart';
import '../models/daily_quote_model.dart';
import '../models/daily_task_model.dart';
import '../models/recovery_program_model.dart';
import '../models/user_stats_model.dart';

/// Remote data source for the Home Dashboard (Cloud Firestore).
abstract interface class HomeRemoteDataSource {
  Stream<UserStats> watchUserStats(String uid);
  Stream<List<DailyTask>> watchDailyTasks();
  Future<DailyQuote> getTodaysQuote();
  Future<RecoveryProgram> getProgram();
  Future<void> setTaskCompleted({
    required String uid,
    required String taskId,
    required bool completed,
  });
}

class FirestoreHomeRemoteDataSource implements HomeRemoteDataSource {
  FirestoreHomeRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  static const String _programsCollection = 'programs';
  static const String _dailyTasksCollection = 'daily_tasks';
  static const String _quotesCollection = 'quotes';

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _firestore.collection(AppConstants.usersCollection).doc(uid);

  @override
  Stream<UserStats> watchUserStats(String uid) {
    return _userDoc(uid).snapshots().map(UserStatsModel.fromFirestore);
  }

  @override
  Stream<List<DailyTask>> watchDailyTasks() {
    return _firestore
        .collection(_dailyTasksCollection)
        .orderBy('order')
        .snapshots()
        .map((snap) =>
            snap.docs.map(DailyTaskModel.fromFirestore).toList(growable: false));
  }

  @override
  Future<DailyQuote> getTodaysQuote() async {
    try {
      final doc = await _firestore
          .collection(_quotesCollection)
          .doc(_todayId())
          .get();
      return doc.exists ? DailyQuoteModel.fromFirestore(doc) : DailyQuote.fallback;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to load quote.', code: e.code);
    }
  }

  @override
  Future<RecoveryProgram> getProgram() async {
    try {
      final doc = await _firestore
          .collection(_programsCollection)
          .doc(AppConstants.supportedProgram)
          .get();
      return doc.exists
          ? RecoveryProgramModel.fromFirestore(doc)
          : RecoveryProgram.defaultProgram();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to load program.', code: e.code);
    }
  }

  @override
  Future<void> setTaskCompleted({
    required String uid,
    required String taskId,
    required bool completed,
  }) async {
    try {
      await _userDoc(uid).set({
        'completedTasks': completed
            ? FieldValue.arrayUnion([taskId])
            : FieldValue.arrayRemove([taskId]),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to save task.', code: e.code);
    }
  }

  /// Document id for today's quote, formatted as `yyyy-MM-dd`.
  String _todayId() {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '${now.year}-$month-$day';
  }
}
