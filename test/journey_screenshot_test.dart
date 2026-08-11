import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lifereset/features/home/domain/entities/daily_task.dart';
import 'package:lifereset/features/home/domain/entities/user_stats.dart';
import 'package:lifereset/features/home/presentation/providers/home_providers.dart';
import 'package:lifereset/features/journal/domain/entities/journal_entry.dart';
import 'package:lifereset/features/journal/domain/entities/mood_entry.dart';
import 'package:lifereset/features/journal/domain/entities/mood_type.dart';
import 'package:lifereset/features/journal/presentation/controllers/journal_history_controller.dart';
import 'package:lifereset/features/journal/presentation/providers/journal_providers.dart';
import 'package:lifereset/features/journal/presentation/screens/journal_home_screen.dart';

class _FakeHistory extends JournalHistoryController {
  _FakeHistory(this._entries);
  final List<JournalEntry> _entries;
  @override
  Future<JournalHistoryState> build() async =>
      JournalHistoryState(entries: _entries, hasMore: false);
}

JournalEntry _entry(String id, String content, {MoodType? mood, int hoursAgo = 2}) =>
    JournalEntry(
      id: id,
      title: '',
      content: content,
      mood: mood,
      tags: const [],
      createdAt: DateTime.now().subtract(Duration(hours: hoursAgo)),
      updatedAt: DateTime.now().subtract(Duration(hours: hoursAgo)),
    );

MoodEntry _mood(MoodType m, {int daysAgo = 0}) {
  final d = DateTime.now().subtract(Duration(days: daysAgo));
  return MoodEntry(
    id: '${d.year}-${d.month}-${d.day}-$daysAgo',
    date: d,
    mood: m,
    note: '',
    factors: const [],
    createdAt: d,
  );
}

void main() {
  final now = DateTime(2026, 8, 10);
  final recent = [
    _entry('e1', 'Today I felt more calm and focused. I noticed the cravings '
        'fade after my morning walk.', mood: MoodType.good, hoursAgo: 3),
    _entry('e2', 'A harder afternoon, but I reached out to a friend instead of '
        'isolating.', mood: MoodType.okay, hoursAgo: 26),
    _entry('e3', 'Grateful for a full night of sleep.', mood: MoodType.great,
        hoursAgo: 50),
  ];
  final moodHistory = [
    _mood(MoodType.good),
    _mood(MoodType.okay, daysAgo: 1),
    _mood(MoodType.great, daysAgo: 2),
    _mood(MoodType.sad, daysAgo: 3),
    _mood(MoodType.good, daysAgo: 4),
    _mood(MoodType.okay, daysAgo: 6),
    _mood(MoodType.good, daysAgo: 8),
    _mood(MoodType.sad, daysAgo: 9),
  ];

  List<Override> overrides() => [
        userStatsProvider.overrideWith((ref) => Stream.value(UserStats(
              recoveryScore: 68,
              streak: 4,
              currentDay: 12,
              completedTaskIds: const {'t1', 't2'},
              scoreHistory: [
                for (var i = 6; i >= 0; i--)
                  ScorePoint(
                      date: now.subtract(Duration(days: i)),
                      score: 52 + (6 - i) * 3),
              ],
            ))),
        dailyTasksProvider.overrideWith((ref) => Stream.value(const <DailyTask>[
              DailyTask(
                  id: 't1',
                  title: 'Morning walk',
                  description: '',
                  duration: '10 min',
                  order: 0),
              DailyTask(
                  id: 't2',
                  title: 'Journal',
                  description: '',
                  duration: '5 min',
                  order: 1),
              DailyTask(
                  id: 't3',
                  title: 'Call a friend',
                  description: '',
                  duration: 'Daily',
                  order: 2),
            ])),
        recentEntriesProvider.overrideWith((ref) => Stream.value(recent)),
        moodHistoryProvider.overrideWith((ref) => Stream.value(moodHistory)),
        todayMoodProvider.overrideWith((ref) => Stream.value(_mood(MoodType.good))),
        journalHistoryControllerProvider.overrideWith(() => _FakeHistory(recent)),
      ];

  Future<void> shoot(WidgetTester t, String tab, String file) async {
    final key = GlobalKey();
    const size = Size(390, 1500);
    t.view.devicePixelRatio = 1.0;
    t.view.physicalSize = size;
    addTearDown(() {
      t.view.resetPhysicalSize();
      t.view.resetDevicePixelRatio();
    });
    await t.pumpWidget(ProviderScope(
      overrides: overrides(),
      child: MaterialApp(
        home: RepaintBoundary(
          key: key,
          child: const MediaQuery(
            data: MediaQueryData(size: size),
            child: JournalHomeScreen(),
          ),
        ),
      ),
    ));
    await t.pump();
    await t.pump(const Duration(milliseconds: 400));
    await t.pump(const Duration(milliseconds: 500));
    if (tab != 'Overview') {
      await t.tap(find.widgetWithText(AnimatedContainer, tab));
      await t.pump();
      await t.pump(const Duration(milliseconds: 400));
      await t.pump(const Duration(milliseconds: 600));
    }
    await t.runAsync(() async {
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 2.0);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      final dir = Directory('build/journey_preview')..createSync(recursive: true);
      File('${dir.path}/$file')
          .writeAsBytesSync(bytes!.buffer.asUint8List());
    });
  }

  testWidgets('screenshot Overview (dashboard)', (t) async {
    await shoot(t, 'Overview', 'journey_overview.png');
  });
  testWidgets('screenshot Journal (diary timeline)', (t) async {
    await shoot(t, 'Journal', 'journey_journal.png');
  });
  testWidgets('screenshot Mood (tracker)', (t) async {
    await shoot(t, 'Mood', 'journey_mood.png');
  });
  testWidgets('screenshot Insights (analytics)', (t) async {
    await shoot(t, 'Insights', 'journey_insights.png');
  });
}
