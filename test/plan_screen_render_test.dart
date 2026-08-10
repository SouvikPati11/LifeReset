import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lifereset/features/home/domain/entities/daily_quote.dart';
import 'package:lifereset/features/home/domain/entities/daily_task.dart';
import 'package:lifereset/features/home/domain/entities/recovery_program.dart';
import 'package:lifereset/features/home/domain/entities/user_stats.dart';
import 'package:lifereset/features/home/presentation/providers/home_providers.dart';
import 'package:lifereset/features/home/presentation/screens/todays_plan_screen.dart';

UserStats _stats() => const UserStats(
      recoveryScore: 42,
      streak: 0,
      currentDay: 1,
      completedTaskIds: {'t2'},
      scoreHistory: [],
    );

const _tasks = <DailyTask>[
  DailyTask(
    id: 't1',
    title: 'Morning Reflection',
    description: 'Take 5 minutes to write how you feel today.',
    duration: '5 min',
    order: 0,
  ),
  DailyTask(
    id: 't2',
    title: '10-Minute Walk',
    description: 'Spend some quiet time moving outdoors.',
    duration: '10 min',
    order: 1,
  ),
];

List<Override> _overrides({
  Stream<List<DailyTask>>? tasks,
  DailyQuote quote = const DailyQuote(text: 'Keep going.', author: 'LifeReset'),
}) =>
    [
      userStatsProvider.overrideWith((ref) => Stream.value(_stats())),
      dailyTasksProvider.overrideWith((ref) => tasks ?? Stream.value(_tasks)),
      recoveryProgramProvider
          .overrideWith((ref) => RecoveryProgram.defaultProgram()),
      dailyQuoteProvider.overrideWith((ref) => quote),
    ];

Widget _harness(List<Override> overrides, {Size size = const Size(390, 2200)}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(size: size),
        child: const TodaysPlanScreen(),
      ),
    ),
  );
}

void main() {
  tearDown(() {
    final view = TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.resetPhysicalSize();
    view.resetDevicePixelRatio();
  });

  Future<void> pumpAt(WidgetTester tester, Size size, Widget app) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = size;
    await tester.pumpWidget(app);
    await tester.pump(const Duration(milliseconds: 800));
  }

  testWidgets('renders day banner, all tasks and done count (no overflow)',
      (t) async {
    await pumpAt(t, const Size(390, 2200), _harness(_overrides()));

    expect(find.text('Day 1 of 30'), findsOneWidget); // progress banner
    expect(find.text('Day 1 • 1/2 done'), findsOneWidget); // completed count
    expect(find.text('Morning Reflection'), findsOneWidget);
    expect(find.text('10-Minute Walk'), findsOneWidget); // all tasks, not just 3
    expect(find.text('5 min'), findsOneWidget);
    expect(find.text('DAILY INSIGHT'), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('renders without overflow on small and large phones', (t) async {
    for (final size in const [Size(320, 2200), Size(430, 2200)]) {
      await pumpAt(t, size, _harness(_overrides(), size: size));
      expect(find.text('Morning Reflection'), findsOneWidget);
      expect(t.takeException(), isNull);
    }
  });

  testWidgets('empty day shows "No tasks for today yet."', (t) async {
    await pumpAt(
      t,
      const Size(390, 2200),
      _harness(_overrides(tasks: Stream.value(const []))),
    );
    expect(find.text('No tasks for today yet.'), findsOneWidget);
  });

  testWidgets('error shows a retry card', (t) async {
    await pumpAt(
      t,
      const Size(390, 2200),
      _harness(_overrides(tasks: Stream<List<DailyTask>>.error(Exception('x')))),
    );
    expect(find.text("Couldn't load your plan."), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });

  testWidgets('loading shows a skeleton, not a blank screen', (t) async {
    final never = Completer<List<DailyTask>>();
    await pumpAt(
      t,
      const Size(390, 2200),
      _harness(_overrides(
          tasks: Stream<List<DailyTask>>.fromFuture(never.future))),
    );
    expect(find.byType(CircularProgressIndicator), findsWidgets);
  });

  testWidgets('missing/Unknown quote author falls back to LifeReset', (t) async {
    await pumpAt(
      t,
      const Size(390, 2200),
      _harness(_overrides(
          quote: const DailyQuote(text: 'Keep going.', author: 'Unknown'))),
    );
    expect(find.text('— LifeReset'), findsOneWidget);
    expect(find.text('— Unknown'), findsNothing);
  });
}
