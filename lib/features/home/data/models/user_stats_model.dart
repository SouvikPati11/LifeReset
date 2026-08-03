import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/user_stats.dart';

/// Maps the `users/{uid}` document to [UserStats], applying defaults for any
/// missing fields so new accounts render correctly.
class UserStatsModel {
  const UserStatsModel._();

  static UserStats fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};

    final completed = (data['completedTasks'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toSet() ??
        <String>{};

    final history = (data['scoreHistory'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .map(_pointFromMap)
            .whereType<ScorePoint>()
            .toList() ??
        <ScorePoint>[];
    history.sort((a, b) => a.date.compareTo(b.date));

    return UserStats(
      recoveryScore:
          (data['recoveryScore'] as num?)?.toInt() ?? UserStats.defaultRecoveryScore,
      streak: (data['streak'] as num?)?.toInt() ?? 0,
      currentDay: (data['currentDay'] as num?)?.toInt() ?? 1,
      completedTaskIds: completed,
      scoreHistory: history,
    );
  }

  static ScorePoint? _pointFromMap(Map<String, dynamic> map) {
    final rawDate = map['date'];
    final DateTime? date = switch (rawDate) {
      Timestamp t => t.toDate(),
      String s => DateTime.tryParse(s),
      _ => null,
    };
    if (date == null) return null;
    return ScorePoint(
      date: date,
      score: (map['score'] as num?)?.toInt() ?? 0,
    );
  }
}
