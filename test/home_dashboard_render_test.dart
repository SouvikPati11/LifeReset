import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lifereset/features/home/domain/entities/daily_quote.dart';
import 'package:lifereset/features/home/domain/entities/daily_task.dart';
import 'package:lifereset/features/home/domain/entities/recovery_program.dart';
import 'package:lifereset/features/home/domain/entities/user_stats.dart';
import 'package:lifereset/features/home/presentation/providers/home_providers.dart';
import 'package:lifereset/features/home/presentation/views/home_dashboard_view.dart';
import 'package:lifereset/features/home/presentation/widgets/home_style.dart';
import 'package:lifereset/features/authentication/domain/entities/user_profile.dart';
import 'package:lifereset/features/authentication/presentation/providers/user_providers.dart';

UserStats _populatedStats() {
  final now = DateTime(2026, 8, 10);
  return UserStats(
    recoveryScore: 78,
    streak: 3,
    currentDay: 7,
    completedTaskIds: const {'t3'},
    scoreHistory: [
      for (var i = 6; i >= 0; i--)
        ScorePoint(date: now.subtract(Duration(days: i)), score: 62 + (6 - i) * 3),
    ],
  );
}

const _tasks = <DailyTask>[
  DailyTask(
    id: 't1',
    title: 'Morning Reflection',
    description: 'Take 5 minutes to check in with yourself.',
    duration: '5 min',
    order: 0,
    iconKey: 'morning',
  ),
  DailyTask(
    id: 't2',
    title: 'Let It Out',
    description: "Write down one thought you've been holding onto.",
    duration: '10 min',
    order: 1,
    iconKey: 'journal',
  ),
  DailyTask(
    id: 't3',
    title: 'Self-Care Moment',
    description: 'Do one small thing for you.',
    duration: 'Daily',
    order: 2,
    iconKey: 'self-care',
  ),
];

const _profile = UserProfile(id: 'u1', name: 'Souvik Pati', email: 'a@b.com');

/// Data overrides so the dashboard renders without Firebase. Each argument lets
/// a test swap one section into a loading/error/empty state.
List<Override> _overrides({
  Stream<UserStats>? stats,
  List<DailyTask> tasks = _tasks,
}) =>
    [
      userProfileProvider.overrideWith((ref) => Stream.value(_profile)),
      userStatsProvider
          .overrideWith((ref) => stats ?? Stream.value(_populatedStats())),
      dailyTasksProvider.overrideWith((ref) => Stream.value(tasks)),
      dailyQuoteProvider.overrideWith(
        (ref) => const DailyQuote(
          text: 'Healing happens one small step at a time.',
          author: 'LifeReset',
        ),
      ),
      recoveryProgramProvider
          .overrideWith((ref) => RecoveryProgram.defaultProgram()),
      homeFocusProvider.overrideWith(
        (ref) => Stream.value(HomeFocus.fromProblem('breakup_recovery')),
      ),
    ];

Widget _harness(List<Override> overrides, {Size size = const Size(390, 2400)}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(size: size),
        child: const Scaffold(body: HomeDashboardView()),
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
    await tester.pump(const Duration(milliseconds: 800)); // settle ring/bars
  }

  testWidgets('populated Home renders every section (no overflow)', (t) async {
    await pumpAt(t, const Size(390, 2400), _harness(_overrides()));

    expect(find.text("Let's take one small step forward today."), findsOneWidget);
    expect(find.text('YOUR RECOVERY SCORE'), findsOneWidget);
    expect(find.text('78%'), findsOneWidget);
    expect(find.text("You're making progress 💜"), findsOneWidget);
    expect(find.text('Your Recovery Journey'), findsOneWidget);
    expect(find.text('Day 7 of 30'), findsOneWidget);
    expect(find.text('YOUR FOCUS'), findsOneWidget);
    expect(find.text('Healing & Moving Forward'), findsOneWidget);
    expect(find.text("Today's Plan"), findsOneWidget);
    expect(find.text('Morning Reflection'), findsOneWidget);
    expect(find.text('Self-Care Moment'), findsOneWidget);
    expect(find.text('DAILY INSIGHT'), findsOneWidget);
    expect(find.text('Quick Actions'), findsOneWidget);
    expect(find.text('Journal'), findsOneWidget);
    expect(find.text('AI Coach'), findsOneWidget);

    expect(t.takeException(), isNull); // no layout overflow
  });

  testWidgets('renders on small and large phones without overflow', (t) async {
    for (final size in const [Size(320, 2400), Size(430, 2400)]) {
      await pumpAt(t, size, _harness(_overrides(), size: size));
      expect(find.text('YOUR RECOVERY SCORE'), findsOneWidget);
      expect(find.text('Quick Actions'), findsOneWidget);
      expect(t.takeException(), isNull);
    }
  });

  testWidgets('populated plan shows the admin day header "Day N • M tasks"',
      (t) async {
    await pumpAt(t, const Size(390, 2400), _harness(_overrides()));
    expect(find.text('Day 7 • 3 tasks'), findsOneWidget);
  });

  testWidgets('empty plan shows "No tasks for today yet.", not AI wording',
      (t) async {
    await pumpAt(t, const Size(390, 2400), _harness(_overrides(tasks: const [])));
    expect(find.text('No tasks for today yet.'), findsOneWidget);
    expect(find.text('Your plan is being prepared'), findsNothing);
  });

  testWidgets('missing/Unknown quote author falls back to LifeReset', (t) async {
    await pumpAt(
      t,
      const Size(390, 2400),
      _harness([
        userProfileProvider.overrideWith((ref) => Stream.value(_profile)),
        userStatsProvider
            .overrideWith((ref) => Stream.value(_populatedStats())),
        dailyTasksProvider.overrideWith((ref) => Stream.value(_tasks)),
        dailyQuoteProvider.overrideWith(
          (ref) => const DailyQuote(text: 'Keep going.', author: 'Unknown'),
        ),
        recoveryProgramProvider
            .overrideWith((ref) => RecoveryProgram.defaultProgram()),
        homeFocusProvider.overrideWith(
          (ref) => Stream.value(HomeFocus.fromProblem('breakup_recovery')),
        ),
      ]),
    );
    expect(find.text('— LifeReset'), findsOneWidget);
    expect(find.text('— Unknown'), findsNothing);
  });

  testWidgets('long user name wraps gracefully without overflow', (t) async {
    await pumpAt(
      t,
      const Size(320, 2400),
      _harness([
        userProfileProvider.overrideWith(
          (ref) => Stream.value(const UserProfile(
            id: 'u1',
            name: 'Bartholomew Featherstonehaugh',
            email: 'a@b.com',
          )),
        ),
        userStatsProvider
            .overrideWith((ref) => Stream.value(_populatedStats())),
        dailyTasksProvider.overrideWith((ref) => Stream.value(_tasks)),
        dailyQuoteProvider.overrideWith(
          (ref) => const DailyQuote(text: 'Keep going.', author: 'LifeReset'),
        ),
        recoveryProgramProvider
            .overrideWith((ref) => RecoveryProgram.defaultProgram()),
        homeFocusProvider.overrideWith(
          (ref) => Stream.value(HomeFocus.fromProblem('breakup_recovery')),
        ),
      ], size: const Size(320, 2400)),
    );
    expect(find.textContaining('Bartholomew'), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('errored stats shows a retry card; other sections still render',
      (t) async {
    await pumpAt(
      t,
      const Size(390, 2400),
      _harness(_overrides(stats: Stream<UserStats>.error(Exception('x')))),
    );
    expect(find.text("Couldn't refresh your recovery data."), findsWidgets);
    expect(find.text('Try again'), findsWidgets);
    // Sections that don't depend on stats keep working.
    expect(find.text('YOUR FOCUS'), findsOneWidget);
    expect(find.text('Morning Reflection'), findsOneWidget);
  });

  testWidgets('loading stats shows a skeleton, not a blank screen', (t) async {
    final never = Completer<UserStats>();
    await pumpAt(
      t,
      const Size(390, 2400),
      _harness(_overrides(stats: Stream<UserStats>.fromFuture(never.future))),
    );
    expect(find.byType(CircularProgressIndicator), findsWidgets);
    expect(find.text('Quick Actions'), findsOneWidget);
  });

  testWidgets('capture a screenshot of the populated Home', (t) async {
    final key = GlobalKey();
    await pumpAt(
      t,
      const Size(390, 2400),
      ProviderScope(
        overrides: _overrides(),
        child: MaterialApp(
          home: RepaintBoundary(
            key: key,
            child: const MediaQuery(
              data: MediaQueryData(size: Size(390, 2400)),
              child: Scaffold(body: HomeDashboardView()),
            ),
          ),
        ),
      ),
    );
    await t.runAsync(() async {
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 2.0);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      final dir = Directory('build/home_preview')..createSync(recursive: true);
      File('${dir.path}/home_dashboard.png')
          .writeAsBytesSync(bytes!.buffer.asUint8List());
    });
    expect(find.byType(HomeDashboardView), findsOneWidget);
  });
}
