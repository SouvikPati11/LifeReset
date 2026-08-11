import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lifereset/core/utils/result.dart';
import 'package:lifereset/features/authentication/domain/entities/auth_user.dart';
import 'package:lifereset/features/authentication/presentation/providers/auth_providers.dart';
import 'package:lifereset/features/home/domain/entities/daily_task.dart';
import 'package:lifereset/features/home/domain/entities/user_stats.dart';
import 'package:lifereset/features/home/presentation/providers/home_providers.dart';
import 'package:lifereset/features/home/presentation/widgets/journey_tab_navigator.dart';
import 'package:lifereset/features/journal/domain/entities/journal_entry.dart';
import 'package:lifereset/features/journal/domain/entities/mood_entry.dart';
import 'package:lifereset/features/journal/domain/entities/mood_type.dart';
import 'package:lifereset/features/journal/domain/repositories/mood_repository.dart';
import 'package:lifereset/features/journal/presentation/controllers/journal_history_controller.dart';
import 'package:lifereset/features/journal/presentation/providers/journal_providers.dart';
import 'package:lifereset/features/journal/presentation/screens/journal_entry_detail_screen.dart';
import 'package:lifereset/features/journal/presentation/screens/journal_home_screen.dart';

// ── Fixtures ────────────────────────────────────────────────────────────────

UserStats _userStats({int score = 55, int day = 3}) {
  final now = DateTime(2026, 8, 10);
  return UserStats(
    recoveryScore: score,
    streak: 2,
    currentDay: day,
    completedTaskIds: const {},
    scoreHistory: [
      for (var i = 3; i >= 0; i--)
        ScorePoint(date: now.subtract(Duration(days: i)), score: 47 + (3 - i) * 3),
    ],
  );
}

JournalEntry _entry(String id, String content, {MoodType? mood}) => JournalEntry(
      id: id,
      title: '',
      content: content,
      mood: mood,
      tags: const [],
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
    );

MoodEntry _mood(MoodType m, {int daysAgo = 0}) {
  final d = DateTime.now().subtract(Duration(days: daysAgo));
  return MoodEntry(
    id: '${d.year}-${d.month}-${d.day}',
    date: d,
    mood: m,
    note: '',
    factors: const [],
    createdAt: d,
  );
}

class _FakeHistory extends JournalHistoryController {
  _FakeHistory(this._entries);
  final List<JournalEntry> _entries;
  @override
  Future<JournalHistoryState> build() async =>
      JournalHistoryState(entries: _entries, hasMore: false);
}

List<Override> _overrides({
  List<JournalEntry> recent = const [],
  List<JournalEntry> history = const [],
  List<MoodEntry> moodHistory = const [],
  MoodEntry? todayMood,
}) =>
    [
      userStatsProvider.overrideWith((ref) => Stream.value(_userStats())),
      dailyTasksProvider.overrideWith((ref) => Stream.value(const <DailyTask>[])),
      recentEntriesProvider.overrideWith((ref) => Stream.value(recent)),
      moodHistoryProvider.overrideWith((ref) => Stream.value(moodHistory)),
      todayMoodProvider.overrideWith((ref) => Stream.value(todayMood)),
      journalHistoryControllerProvider.overrideWith(() => _FakeHistory(history)),
    ];

Widget _host(List<Override> overrides, {Size size = const Size(390, 2600)}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(size: size),
        child: const JournalHomeScreen(),
      ),
    ),
  );
}

/// Taps a Journey segment by name. The segmented control wraps each label in an
/// [AnimatedContainer], so this never collides with same-named body text (e.g.
/// the Overview "Mood" metric label).
Future<void> _tapTab(WidgetTester t, String name) async {
  await t.tap(find.widgetWithText(AnimatedContainer, name));
  await _settle(t);
}

Future<void> _settle(WidgetTester t) async {
  await t.pump();
  await t.pump(const Duration(milliseconds: 400));
  await t.pump(const Duration(milliseconds: 400));
}

Future<void> _pump(WidgetTester t, Widget app,
    {Size size = const Size(390, 2600)}) async {
  t.view.devicePixelRatio = 1.0;
  t.view.physicalSize = size;
  await t.pumpWidget(app);
  await _settle(t);
}

void main() {
  tearDown(() {
    final v = TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    v.resetPhysicalSize();
    v.resetDevicePixelRatio();
  });

  testWidgets('Overview renders real recovery score, day and weekly counts',
      (t) async {
    await _pump(
      t,
      _host(_overrides(
        recent: [_entry('e1', 'Today I felt more calm and focused.')],
        moodHistory: [_mood(MoodType.good), _mood(MoodType.okay, daysAgo: 1)],
        todayMood: _mood(MoodType.good),
      )),
    );

    expect(find.text('Track your healing journey'), findsOneWidget); // header
    expect(find.text('Every entry makes you stronger'), findsOneWidget);
    expect(find.text('RECOVERY SCORE'), findsOneWidget); // score hero label
    expect(find.text('55'), findsOneWidget); // real recoveryScore
    expect(find.text('Day 3 of 30'), findsOneWidget); // real currentDay
    expect(find.text('Entries'), findsOneWidget); // week strip metric
    expect(find.text('1'), findsWidgets); // 1 entry this week
    expect(find.textContaining('/7'), findsOneWidget); // mood tracked x/7
    expect(find.text('Recent Activity'), findsOneWidget);
    expect(find.textContaining('Today I felt more calm'), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('switching the four Journey tabs updates the header + content',
      (t) async {
    await _pump(
      t,
      _host(_overrides(
        recent: [_entry('e1', 'Calm day')],
        history: [_entry('e1', 'Calm day', mood: MoodType.good)],
        moodHistory: [_mood(MoodType.good)],
        todayMood: _mood(MoodType.good),
      )),
    );

    // Overview (default)
    expect(find.text('Every entry makes you stronger'), findsOneWidget);

    await _tapTab(t, 'Journal');
    expect(find.text('Your Journal'), findsOneWidget);
    expect(find.text('New Journal'), findsOneWidget);

    await _tapTab(t, 'Mood');
    expect(find.text('How are you feeling?'), findsOneWidget); // header
    expect(find.text('Mood History'), findsOneWidget); // tracker section

    await _tapTab(t, 'Insights');
    expect(find.text('Your Insights'), findsOneWidget);
    expect(find.text('RECOVERY INSIGHT'), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('empty journal shows the CTA empty state', (t) async {
    await _pump(t, _host(_overrides()));
    await _tapTab(t, 'Journal');
    expect(find.text('No journal entries yet.'), findsOneWidget);
    expect(find.text('Write your first journal'), findsOneWidget);
  });

  testWidgets('empty mood shows prompt + empty history', (t) async {
    await _pump(t, _host(_overrides()));
    await _tapTab(t, 'Mood');
    expect(find.text('How are you feeling today?'), findsOneWidget);
    expect(find.text('No mood history yet.'), findsOneWidget);
  });

  testWidgets('tapping a mood face saves via the existing mood system',
      (t) async {
    MoodType? saved;
    const user = AuthUser(id: 'u1', email: 'a@b.com', isEmailVerified: true);
    await _pump(
      t,
      ProviderScope(
        overrides: [
          currentUserProvider.overrideWithValue(user),
          userStatsProvider.overrideWith((ref) => Stream.value(_userStats())),
          dailyTasksProvider
              .overrideWith((ref) => Stream.value(const <DailyTask>[])),
          recentEntriesProvider.overrideWith((ref) => Stream.value(const [])),
          journalHistoryControllerProvider
              .overrideWith(() => _FakeHistory(const [])),
          moodRepositoryProvider.overrideWithValue(
            _FakeMoodRepo(onSave: (m) => saved = m),
          ),
        ],
        child: const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(size: Size(390, 2600)),
            child: JournalHomeScreen(),
          ),
        ),
      ),
    );
    await _tapTab(t, 'Mood');
    await t.tap(find.text('Great'));
    await _settle(t);
    expect(saved, MoodType.great); // real saveMood was invoked
  });

  testWidgets('tapping a journal entry opens the detail (nav preserved)',
      (t) async {
    final entry = _entry('e1', 'Today I felt more calm and focused.',
        mood: MoodType.good);
    await _pump(
      t,
      size: const Size(500, 2600),
      ProviderScope(
        overrides: [
          ..._overrides(history: [entry]),
          entryDetailProvider('e1').overrideWith((ref) => Stream.value(entry)),
        ],
        child: MaterialApp(
          home: MediaQuery(
            // Wider viewport: the reused (pre-existing) journal detail screen is
            // out of scope for this restyle and is comfortable at tablet width.
            data: const MediaQueryData(size: Size(500, 2600)),
            child: Scaffold(
              body: const JourneyTabNavigator(),
              bottomNavigationBar: NavigationBar(
                selectedIndex: 2,
                onDestinationSelected: (_) {},
                destinations: const [
                  NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
                  NavigationDestination(icon: Icon(Icons.event_note_outlined), label: 'Plan'),
                  NavigationDestination(icon: Icon(Icons.eco_outlined), label: 'Journey'),
                  NavigationDestination(icon: Icon(Icons.forum_outlined), label: 'Coach'),
                  NavigationDestination(icon: Icon(Icons.person_outline_rounded), label: 'Profile'),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // Journey selected, single bottom nav.
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(t.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex, 2);
    expect(find.byType(JournalHomeScreen), findsOneWidget);

    await _tapTab(t, 'Journal');
    await t.tap(find.textContaining('Today I felt more calm'));
    await _settle(t);

    // Detail opened, bottom nav still visible (nested navigator).
    expect(find.byType(JournalEntryDetailScreen), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);

    // Back returns to the Journey list; nav never duplicated.
    await t.tap(find.byTooltip('Back'));
    await _settle(t);
    expect(find.byType(JournalEntryDetailScreen), findsNothing);
    expect(find.byType(JournalHomeScreen), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('no overflow across tabs at 320/360/390/430', (t) async {
    for (final w in const [320.0, 360.0, 390.0, 430.0]) {
      await _pump(
        t,
        _host(
          _overrides(
            recent: [_entry('e1', 'Calm day')],
            history: [_entry('e1', 'Calm day', mood: MoodType.good)],
            moodHistory: [_mood(MoodType.good), _mood(MoodType.sad, daysAgo: 1)],
            todayMood: _mood(MoodType.good),
          ),
          size: Size(w, 2600),
        ),
        size: Size(w, 2600),
      );
      for (final tab in const ['Journal', 'Mood', 'Insights', 'Overview']) {
        await _tapTab(t, tab);
        expect(t.takeException(), isNull, reason: 'overflow on $tab @ ${w}px');
      }
    }
  });
}

// ── Fakes ─────────────────────────────────────────────────────────────────

class _FakeMoodRepo implements MoodRepository {
  _FakeMoodRepo({required this.onSave});
  final void Function(MoodType) onSave;

  @override
  Stream<MoodEntry?> watchTodayMood(String uid) => Stream.value(null);

  @override
  Stream<List<MoodEntry>> watchHistory(String uid, {int days = 30}) =>
      Stream.value(const []);

  @override
  Future<Result<void>> saveMood(
    String uid, {
    required DateTime date,
    required MoodType mood,
    required String note,
    required List<String> factors,
  }) async {
    onSave(mood);
    return const Success(null);
  }
}
