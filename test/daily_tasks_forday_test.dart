import 'package:flutter_test/flutter_test.dart';

import 'package:lifereset/features/home/data/models/daily_task_model.dart';

/// A raw `program_tasks` doc (id + data), as the data source maps snapshots.
({String id, Map<String, dynamic> data}) _doc(
  String id,
  Map<String, dynamic> data,
) =>
    (id: id, data: data);

void main() {
  final docs = [
    _doc('d1a', {
      'day': 1,
      'order': 1,
      'task': '10-Minute Walk',
      'motivation': 'Spend some quiet time moving outdoors.',
      'estimatedMinutes': 10,
      'status': 'active',
    }),
    _doc('d1b', {
      'day': 1,
      'order': 0,
      'task': 'Morning Reflection',
      'motivation': 'Take 5 minutes to write how you feel today.',
      'estimatedMinutes': 5,
      'status': 'active',
    }),
    _doc('d1c', {
      'day': 1,
      'order': 2,
      'task': 'Hidden Task',
      'motivation': 'Should not appear.',
      'status': 'inactive',
    }),
    _doc('d2a', {
      'day': 2,
      'order': 0,
      'task': 'Reach Out',
      'motivation': 'Message a friend you trust.',
      'estimatedMinutes': 15,
      'status': 'active',
    }),
  ];

  test('day 1 returns only active day-1 tasks, sorted by order', () {
    final tasks = DailyTaskModel.forDay(docs, 1);

    expect(tasks.map((t) => t.title).toList(),
        ['Morning Reflection', '10-Minute Walk']); // order 0 then 1
    expect(tasks.any((t) => t.title == 'Hidden Task'), isFalse); // inactive
    expect(tasks.first.description, 'Take 5 minutes to write how you feel today.');
    expect(tasks.first.duration, '5 min'); // estimatedMinutes → duration
  });

  test('changing the day surfaces that day\'s tasks', () {
    final day2 = DailyTaskModel.forDay(docs, 2);
    expect(day2.map((t) => t.title).toList(), ['Reach Out']);
    expect(day2.single.duration, '15 min');
  });

  test('a day with no configured tasks returns empty (drives the empty state)',
      () {
    expect(DailyTaskModel.forDay(docs, 15), isEmpty);
  });

  test('missing estimatedMinutes yields no duration label', () {
    final tasks = DailyTaskModel.forDay(
      [
        _doc('x', {'day': 3, 'order': 0, 'task': 'Breathe', 'status': 'active'}),
      ],
      3,
    );
    expect(tasks.single.duration, '');
    expect(tasks.single.title, 'Breathe');
  });
}
