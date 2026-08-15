import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lifereset/core/utils/result.dart';
import 'package:lifereset/features/authentication/domain/entities/auth_user.dart';
import 'package:lifereset/features/authentication/presentation/providers/auth_providers.dart';
import 'package:lifereset/features/authentication/presentation/providers/user_providers.dart';
import 'package:lifereset/features/coach/domain/entities/chat_message.dart';
import 'package:lifereset/features/coach/domain/entities/coach_context.dart';
import 'package:lifereset/features/coach/domain/entities/conversation.dart';
import 'package:lifereset/features/coach/presentation/providers/coach_providers.dart';
import 'package:lifereset/features/coach/presentation/screens/chat_screen.dart';
import 'package:lifereset/features/coach/presentation/screens/coach_home_screen.dart';
import 'package:lifereset/features/coach/presentation/screens/conversations_list_screen.dart';
import 'package:lifereset/features/home/presentation/widgets/coach_tab_navigator.dart';
import 'package:lifereset/features/home/presentation/widgets/profile_tab_navigator.dart';
import 'package:lifereset/features/notifications/domain/entities/app_notification.dart';
import 'package:lifereset/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:lifereset/features/notifications/presentation/providers/notifications_providers.dart';
import 'package:lifereset/features/notifications/presentation/screens/notification_settings_screen.dart';
import 'package:lifereset/features/notifications/presentation/screens/notifications_inbox_screen.dart';
import 'package:lifereset/features/profile/domain/entities/user_profile.dart';
import 'package:lifereset/features/profile/presentation/providers/profile_providers.dart';
import 'package:lifereset/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:lifereset/features/profile/presentation/screens/profile_home_screen.dart';
import 'package:lifereset/features/profile/presentation/screens/settings_screen.dart';

// ── Fixtures ────────────────────────────────────────────────────────────────

const _user = AuthUser(id: 'u1', email: 'alex@example.com', isEmailVerified: true);

UserProfile _profile() => UserProfile(
      uid: 'u1',
      name: 'Alex Morgan',
      email: 'alex@example.com',
      plan: SubscriptionPlan.free,
      trialStatus: TrialStatus.active,
      appearance: AppearanceMode.light,
      language: 'en',
      notificationsEnabled: true,
      remindersEnabled: false,
      recoveryScore: 68,
      currentDay: 12,
      streak: 4,
      completedTasks: 23,
      trialEndDate: DateTime.now().add(const Duration(days: 4)),
    );

CoachContext _ctx() => const CoachContext(
      recoveryDay: 12,
      totalDays: 30,
      recoveryScore: 68,
      problemType: 'breakup_recovery',
      streak: 4,
      journalEntriesToday: 1,
      todayTaskTitle: 'Morning walk',
      todayTaskCompleted: false,
      moodLabel: 'Good',
      moodScore: 7,
    );

List<Conversation> _conversations() => [
      Conversation(
        id: 'c1',
        title: 'Feeling overwhelmed today',
        lastMessage: 'Thanks, that really helps.',
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Conversation(
        id: 'c2',
        title: 'Building better habits',
        lastMessage: 'Let me try that tomorrow.',
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];

List<ChatMessage> _messages() => [
      ChatMessage(
        id: 'm1',
        conversationId: 'c1',
        text: "I've been feeling really overwhelmed lately.",
        sender: ChatSender.user,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      ChatMessage(
        id: 'm2',
        conversationId: 'c1',
        text: "That sounds hard. Let's take it one step at a time — "
            'what feels heaviest right now?',
        sender: ChatSender.ai,
        timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
      ),
    ];

AppNotification _notif(
  String id,
  String title,
  AppNotificationType type, {
  required bool read,
  required int hoursAgo,
}) =>
    AppNotification(
      id: id,
      title: title,
      body: 'Tap to open the related screen and continue your journey.',
      type: type,
      isRead: read,
      createdAt: DateTime.now().subtract(Duration(hours: hoursAgo)),
    );

List<AppNotification> _notifications() => [
      _notif('n1', 'Time for your daily check-in',
          AppNotificationType.dailyReminder, read: false, hoursAgo: 1),
      _notif('n2', 'How are you feeling today?',
          AppNotificationType.moodReminder, read: false, hoursAgo: 3),
      _notif('n3', 'Your journal is waiting',
          AppNotificationType.journalReminder, read: true, hoursAgo: 26),
      _notif('n4', 'Trial ending soon',
          AppNotificationType.trialEnding, read: true, hoursAgo: 100),
    ];

class _FakeNotifRepo implements NotificationsRepository {
  _FakeNotifRepo(this._inbox);
  final List<AppNotification> _inbox;

  @override
  Stream<List<AppNotification>> watchInbox(String uid) => Stream.value(_inbox);

  @override
  Stream<NotificationPrefs> watchPrefs(String uid) =>
      Stream.value(const NotificationPrefs());

  @override
  Future<Result<void>> markRead(String uid, String id) async =>
      const Success(null);
  @override
  Future<Result<void>> markAllRead(String uid) async => const Success(null);
  @override
  Future<Result<void>> delete(String uid, String id) async =>
      const Success(null);
  @override
  Future<Result<void>> clearAll(String uid) async => const Success(null);
  @override
  Future<Result<void>> savePrefs(String uid, NotificationPrefs p) async =>
      const Success(null);
  @override
  Future<Result<void>> registerToken(String uid, String t, String p) async =>
      const Success(null);
  @override
  Future<Result<void>> removeToken(String uid, String t) async =>
      const Success(null);
}

List<Override> _overrides({List<AppNotification>? inbox}) => [
      currentUserProvider.overrideWithValue(_user),
      userProfileProvider.overrideWith((ref) => Stream.value(null)),
      profileProvider.overrideWith((ref) => Stream.value(_profile())),
      coachContextProvider.overrideWith((ref) => _ctx()),
      conversationsProvider.overrideWith((ref) => Stream.value(_conversations())),
      messagesProvider('c1').overrideWith((ref) => Stream.value(_messages())),
      inboxProvider.overrideWith((ref) => Stream.value(inbox ?? _notifications())),
      notificationsRepositoryProvider
          .overrideWithValue(_FakeNotifRepo(inbox ?? _notifications())),
    ];

Widget _host(Widget child, {Size size = const Size(390, 2600)}) {
  return ProviderScope(
    overrides: _overrides(),
    child: MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(size: size),
        child: child,
      ),
    ),
  );
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

  testWidgets('Coach home shows greeting, topics and recent conversations',
      (t) async {
    await _pump(t, _host(const CoachHomeScreen()));
    expect(find.text('Coach'), findsOneWidget);
    expect(find.text('What would you like to work through?'), findsOneWidget);
    expect(find.text('Suggested topics'), findsOneWidget);
    expect(find.text('Stress'), findsOneWidget);
    expect(find.text('Recent conversations'), findsOneWidget);
    expect(find.text('Feeling overwhelmed today'), findsOneWidget);
    expect(find.textContaining('not a licensed therapist'), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('Coach home history button opens the conversations list',
      (t) async {
    await _pump(t, _host(const CoachHomeScreen()));
    await t.tap(find.byIcon(Icons.history_rounded));
    await _settle(t);
    expect(find.byType(ConversationsListScreen), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('Coach chat renders user and AI messages with a composer',
      (t) async {
    await _pump(t, _host(const ChatScreen(conversationId: 'c1')));
    expect(find.text('AI Coach'), findsOneWidget);
    expect(find.text('Online'), findsOneWidget);
    expect(find.textContaining('feeling really overwhelmed'), findsOneWidget);
    expect(find.textContaining('one step at a time'), findsOneWidget);
    expect(find.text('Message AI Coach…'), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('Coach chat pre-fills the composer with a suggested draft',
      (t) async {
    await _pump(
      t,
      _host(const ChatScreen(
        conversationId: 'c1',
        initialDraft: "I've been feeling stressed.",
      )),
    );
    expect(find.text("I've been feeling stressed."), findsOneWidget);
  });

  testWidgets('Profile home shows identity, real stats and grouped sections',
      (t) async {
    await _pump(t, _host(const ProfileHomeScreen()));
    expect(find.text('Alex Morgan'), findsOneWidget);
    expect(find.text('4'), findsOneWidget); // streak
    expect(find.text('68'), findsOneWidget); // recovery score
    expect(find.text('23'), findsOneWidget); // completed tasks
    expect(find.text('ACCOUNT'), findsOneWidget);
    expect(find.text('SUPPORT'), findsOneWidget);
    expect(find.text('Personal Information'), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('Profile → Personal Information opens the edit form', (t) async {
    await _pump(t, _host(const ProfileHomeScreen()));
    await t.tap(find.text('Personal Information'));
    await _settle(t);
    expect(find.byType(EditProfileScreen), findsOneWidget);
    expect(find.text('Full Name'), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('Edit profile validates an empty name', (t) async {
    await _pump(t, _host(EditProfileScreen(profile: _profile())));
    await t.enterText(find.byType(TextField).first, '');
    await t.tap(find.text('Save Changes'));
    await _settle(t);
    expect(find.text('Please enter your name.'), findsOneWidget);
  });

  testWidgets('Settings shows grouped preferences and logout', (t) async {
    await _pump(t, _host(const SettingsScreen()));
    expect(find.text('PREFERENCES'), findsOneWidget);
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('App Appearance'), findsOneWidget);
    expect(find.text('Log Out'), findsOneWidget);
    expect(find.byType(Switch), findsWidgets);
    expect(t.takeException(), isNull);
  });

  testWidgets('Notifications inbox groups into a chronological feed', (t) async {
    await _pump(t, _host(const NotificationsInboxScreen()));
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('TODAY'), findsOneWidget);
    expect(find.text('YESTERDAY'), findsOneWidget);
    expect(find.text('Time for your daily check-in'), findsOneWidget);
    expect(find.text('2 unread'), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('Notifications inbox shows an empty state when there is nothing',
      (t) async {
    await _pump(
      t,
      ProviderScope(
        overrides: _overrides(inbox: const []),
        child: const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(size: Size(390, 2600)),
            child: NotificationsInboxScreen(),
          ),
        ),
      ),
    );
    expect(find.text("You're all caught up"), findsWidgets);
  });

  testWidgets('Notification settings shows reminder toggles', (t) async {
    await _pump(t, _host(const NotificationSettingsScreen()));
    expect(find.text('Daily Reminder'), findsOneWidget);
    expect(find.text('Journal Reminder'), findsOneWidget);
    expect(find.text('Mood Reminder'), findsOneWidget);
    expect(find.byType(Switch), findsNWidgets(4));
    expect(t.takeException(), isNull);
  });

  // A shell that mimics the app: a tab hosted in its own Navigator with the
  // shared bottom NavigationBar, to prove sub-screens keep the bottom nav.
  Widget shell(Widget tab, int selectedIndex) {
    return ProviderScope(
      overrides: _overrides(),
      child: MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(390, 2600)),
          child: Scaffold(
            body: tab,
            bottomNavigationBar: NavigationBar(
              selectedIndex: selectedIndex,
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
    );
  }

  testWidgets('Profile sub-screens keep the bottom navigation (nested nav)',
      (t) async {
    t.view.devicePixelRatio = 1.0;
    t.view.physicalSize = const Size(390, 2600);
    await t.pumpWidget(shell(const ProfileTabNavigator(), 4));
    await _settle(t);
    expect(find.byType(ProfileHomeScreen), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);

    await t.tap(find.text('Personal Information'));
    await _settle(t);
    // Edit opened inside the tab; the bottom nav is still visible.
    expect(find.byType(EditProfileScreen), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);

    await t.tap(find.byIcon(Icons.arrow_back_rounded).first);
    await _settle(t);
    expect(find.byType(EditProfileScreen), findsNothing);
    expect(find.byType(ProfileHomeScreen), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('Coach history keeps the bottom navigation (nested nav)',
      (t) async {
    t.view.devicePixelRatio = 1.0;
    t.view.physicalSize = const Size(390, 2600);
    await t.pumpWidget(shell(const CoachTabNavigator(), 3));
    await _settle(t);
    expect(find.byType(CoachHomeScreen), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);

    await t.tap(find.byIcon(Icons.history_rounded));
    await _settle(t);
    expect(find.byType(ConversationsListScreen), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('no overflow across widths for the redesigned screens',
      (t) async {
    final screens = <String, Widget>{
      'CoachHome': const CoachHomeScreen(),
      'Chat': const ChatScreen(conversationId: 'c1'),
      'Profile': const ProfileHomeScreen(),
      'Settings': const SettingsScreen(),
      'Inbox': const NotificationsInboxScreen(),
      'NotifSettings': const NotificationSettingsScreen(),
    };
    for (final w in const [320.0, 360.0, 390.0, 430.0]) {
      for (final entry in screens.entries) {
        await _pump(t, _host(entry.value, size: Size(w, 2600)),
            size: Size(w, 2600));
        expect(t.takeException(), isNull,
            reason: 'overflow on ${entry.key} @ ${w}px');
      }
    }
  });
}
