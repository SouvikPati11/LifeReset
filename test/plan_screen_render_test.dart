import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lifereset/features/home/domain/entities/daily_task.dart';
import 'package:lifereset/features/home/domain/entities/recovery_program.dart';
import 'package:lifereset/features/home/domain/entities/user_stats.dart';
import 'package:lifereset/features/home/presentation/providers/home_providers.dart';
import 'package:lifereset/features/home/presentation/providers/plan_providers.dart';
import 'package:lifereset/features/home/presentation/screens/task_detail_screen.dart';
import 'package:lifereset/features/home/presentation/screens/todays_plan_screen.dart';
import 'package:lifereset/features/home/presentation/widgets/plan_tab_navigator.dart';

UserStats _stats({int currentDay = 1}) => UserStats(
      recoveryScore: 42,
      streak: 0,
      currentDay: currentDay,
      completedTaskIds: const {'d1b'},
      scoreHistory: const [],
    );

const _day1 = <DailyTask>[
  DailyTask(
    id: 'd1a',
    title: 'Morning Reflection',
    description: "Take a few minutes to write down how you're feeling today.",
    duration: '5 min',
    order: 0,
    journalPrompt: 'How are you feeling right now?',
    whyThisMatters: 'Writing helps you process emotions.',
    moodGoal: 'Calm',
  ),
  DailyTask(
    id: 'd1b',
    title: 'Take a Short Walk',
    description: 'Give yourself some time outside to relax and breathe.',
    duration: '15 min',
    order: 1,
  ),
];

const _day2 = <DailyTask>[
  DailyTask(
    id: 'd2a',
    title: 'Reach Out',
    description: 'Message a friend you trust.',
    duration: '10 min',
    order: 0,
  ),
];

/// Serves day-specific task lists to the family provider.
List<Override> _overrides({int currentDay = 1}) => [
      userStatsProvider
          .overrideWith((ref) => Stream.value(_stats(currentDay: currentDay))),
      recoveryProgramProvider
          .overrideWith((ref) => RecoveryProgram.defaultProgram()),
      planTasksProvider.overrideWith((ref, day) {
        return switch (day) {
          1 => Stream.value(_day1),
          2 => Stream.value(_day2),
          _ => Stream.value(const <DailyTask>[]),
        };
      }),
    ];

Widget _harness(List<Override> overrides, {Size size = const Size(390, 2600)}) {
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

// The day-keyed family provider subscribes on rebuild, so its Stream.value
// needs a second pump to emit; this drains both rounds + animations.
Future<void> settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 800));
}

Future<void> pumpAt(WidgetTester tester, Size size, Widget app) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  await tester.pumpWidget(app);
  await settle(tester);
}

void main() {
  tearDown(() {
    final view = TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.resetPhysicalSize();
    view.resetDevicePixelRatio();
  });

  testWidgets('renders header, banner, day selector, tasks (no overflow)',
      (t) async {
    await pumpAt(t, const Size(390, 2600), _harness(_overrides()));

    expect(find.text("Today's Plan"), findsWidgets);
    expect(find.text('Your daily roadmap to healing and growth.'),
        findsOneWidget);
    expect(find.text('Day 1 of 30'), findsOneWidget); // banner
    expect(find.text('3%'), findsOneWidget); // 1/30 ≈ 3%, dynamic
    expect(find.text('Select Day'), findsOneWidget);
    expect(find.text('Why follow your plan?'), findsOneWidget);
    // Day 1 tasks from the admin source.
    expect(find.text('Morning Reflection'), findsOneWidget);
    expect(find.text('Take a Short Walk'), findsOneWidget);
    expect(find.text('2 tasks'), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('current day is selected by default (currentDay=5 → Day 5)',
      (t) async {
    await pumpAt(t, const Size(390, 2600), _harness(_overrides(currentDay: 5)));
    expect(find.text('Day 5 of 30'), findsOneWidget);
    // Day 5 has no tasks in this fixture → empty state.
    expect(find.text('No tasks for this day'), findsOneWidget);
  });

  testWidgets('selecting another day loads that day\'s tasks', (t) async {
    await pumpAt(t, const Size(390, 2600), _harness(_overrides()));
    expect(find.text('Morning Reflection'), findsOneWidget); // Day 1

    await t.tap(find.text('2').first); // Day 2 chip
    await settle(t);

    expect(find.text('Reach Out'), findsOneWidget); // Day 2 task
    expect(find.text('Morning Reflection'), findsNothing);
    expect(find.text('1 task'), findsOneWidget);
  });

  testWidgets('empty day shows the admin-managed empty state', (t) async {
    await pumpAt(t, const Size(390, 2600), _harness(_overrides()));
    await t.tap(find.text('3').first); // Day 3 → no tasks
    await settle(t);
    expect(find.text('No tasks for this day'), findsOneWidget);
    expect(
      find.text("Your recovery plan for this day hasn't been added yet."),
      findsOneWidget,
    );
    expect(find.text('Your plan is being prepared'), findsNothing);
  });

  testWidgets('no overflow on small and large phones', (t) async {
    for (final size in const [Size(320, 2600), Size(430, 2600)]) {
      await pumpAt(t, size, _harness(_overrides(), size: size));
      expect(find.text('Select Day'), findsOneWidget);
      expect(t.takeException(), isNull);
    }
  });

  testWidgets('tapping a task opens the Task Details screen', (t) async {
    await pumpAt(t, const Size(390, 2600), _harness(_overrides()));
    await t.tap(find.text('Morning Reflection'));
    await t.pumpAndSettle();

    expect(find.byType(TaskDetailScreen), findsOneWidget);
    expect(find.text('Task Details'), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);
    expect(find.text('Why this matters'), findsOneWidget);
    expect(find.text('Journal Prompt'), findsOneWidget);
    expect(find.text('Mood Goal'), findsOneWidget);
    expect(find.text('Mark as Completed'), findsOneWidget);
  });

  testWidgets('detail button reflects completed state', (t) async {
    // d1b is completed in the fixture.
    await pumpAt(t, const Size(390, 2600), _harness(_overrides()));
    await t.tap(find.text('Take a Short Walk'));
    await t.pumpAndSettle();
    expect(find.text('Completed'), findsOneWidget);
    expect(find.text('Mark as Completed'), findsNothing);
  });

  testWidgets(
      'Task Details opened from Plan keeps the bottom nav (Plan selected)',
      (t) async {
    t.view.devicePixelRatio = 1.0;
    t.view.physicalSize = const Size(390, 2600);
    await t.pumpWidget(_shell(_overrides()));
    await settle(t);

    // Plan list is showing inside the shell, with the bottom nav visible.
    expect(find.byType(TodaysPlanScreen), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Morning Reflection'), findsOneWidget);

    await t.tap(find.text('Morning Reflection'));
    await t.pumpAndSettle();

    // Task Details is now open — and the shell's bottom nav is STILL visible,
    // with Plan still the selected destination.
    expect(find.byType(TaskDetailScreen), findsOneWidget);
    expect(find.text('Task Details'), findsOneWidget);
    expect(find.text('Mark as Completed'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(t.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex, 1);
    expect(t.takeException(), isNull);

    // Back returns to the Plan list; the nav never went away.
    await t.tap(find.byIcon(Icons.arrow_back_rounded));
    await t.pumpAndSettle();
    expect(find.byType(TaskDetailScreen), findsNothing);
    expect(find.byType(TodaysPlanScreen), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}

/// A minimal shell mirroring the app's HomeScreen composition: the Plan tab
/// hosted by [PlanTabNavigator] with the shared bottom navigation as a sibling
/// (Plan selected). Verifies nav persistence without instantiating the other
/// Firebase-backed tabs.
Widget _shell(List<Override> overrides) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      home: MediaQuery(
        data: const MediaQueryData(size: Size(390, 2600)),
        child: Scaffold(
          body: const PlanTabNavigator(),
          bottomNavigationBar: NavigationBar(
            selectedIndex: 1,
            onDestinationSelected: (_) {},
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
              NavigationDestination(
                  icon: Icon(Icons.event_note_outlined), label: 'Plan'),
              NavigationDestination(icon: Icon(Icons.eco_outlined), label: 'Journey'),
              NavigationDestination(icon: Icon(Icons.forum_outlined), label: 'Coach'),
              NavigationDestination(
                  icon: Icon(Icons.person_outline_rounded), label: 'Profile'),
            ],
          ),
        ),
      ),
    ),
  );
}
