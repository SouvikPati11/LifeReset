import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/daily_task.dart';

/// Maps a `daily_tasks/{id}` document to [DailyTask].
class DailyTaskModel {
  const DailyTaskModel._();

  static DailyTask fromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return DailyTask(
      id: doc.id,
      title: (data['title'] as String?) ?? '',
      description: (data['description'] as String?) ?? '',
      duration: (data['duration'] as String?) ?? '',
      order: (data['order'] as num?)?.toInt() ?? 0,
      iconKey: data['iconKey'] as String?,
    );
  }
}
