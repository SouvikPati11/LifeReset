import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/daily_task.dart';

/// Maps admin-managed `program_tasks` documents into the Home [DailyTask].
///
/// Today's Plan is ADMIN-CONTROLLED and DAY-BASED: admins author tasks per day
/// in the Admin Panel (`program_tasks` with a `day` field). Home shows the tasks
/// for the user's `currentDay`. This maps the admin fields onto the Home model
/// (`task → title`, `motivation → description`, `estimatedMinutes → duration`)
/// without introducing a second task model or collection.
class DailyTaskModel {
  const DailyTaskModel._();

  static DailyTask fromProgramTaskData(String id, Map<String, dynamic> data) {
    final minutes = (data['estimatedMinutes'] as num?)?.toInt() ?? 0;
    return DailyTask(
      id: id,
      title: (data['task'] as String?)?.trim() ?? '',
      description: (data['motivation'] as String?)?.trim() ?? '',
      duration: minutes > 0 ? '$minutes min' : '',
      order: (data['order'] as num?)?.toInt() ?? 0,
      iconKey: data['iconKey'] as String?,
      // Extra admin context surfaced on the Task Details screen.
      whyThisMatters: (data['aiContext'] as String?)?.trim() ?? '',
      journalPrompt: (data['journalQuestion'] as String?)?.trim() ?? '',
      moodGoal: (data['moodGoal'] as String?)?.trim() ?? '',
    );
  }

  /// Pure filter + sort + map for a single day, extracted so the day-selection
  /// logic is unit-testable without a live Firestore. Keeps only tasks for
  /// [day] whose status is not `inactive`, ordered by `order`.
  @visibleForTesting
  static List<DailyTask> forDay(
    Iterable<({String id, Map<String, dynamic> data})> docs,
    int day,
  ) {
    final tasks = <DailyTask>[];
    for (final doc in docs) {
      final data = doc.data;
      final taskDay = (data['day'] as num?)?.toInt() ?? 1;
      final active = (data['status'] as String?) != 'inactive';
      if (taskDay == day && active) {
        tasks.add(fromProgramTaskData(doc.id, data));
      }
    }
    tasks.sort((a, b) => a.order.compareTo(b.order));
    return tasks;
  }

  /// Maps a `program_tasks` query snapshot to the day's tasks.
  static List<DailyTask> fromSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
    int day,
  ) {
    return forDay(
      snapshot.docs.map((d) => (id: d.id, data: d.data())),
      day,
    );
  }
}
