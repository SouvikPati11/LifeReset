import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

const _user = AuthUser(id: 'u1', email: 'alex@example.com', isEmailVerified: true);

UserProfile _profile() => UserProfile(
      uid: 'u1', name: 'Alex Morgan', email: 'alex@example.com',
      plan: SubscriptionPlan.free, trialStatus: TrialStatus.active,
      appearance: AppearanceMode.light, language: 'en',
      notificationsEnabled: true, remindersEnabled: false,
      recoveryScore: 68, currentDay: 12, streak: 4, completedTasks: 23,
      trialEndDate: DateTime.now().add(const Duration(days: 4)),
    );

CoachContext _ctx() => const CoachContext(
      recoveryDay: 12, totalDays: 30, recoveryScore: 68, problemType: 'x',
      streak: 4, journalEntriesToday: 1, todayTaskTitle: 'Morning walk',
      moodLabel: 'Good', moodScore: 7,
    );

List<Conversation> _conversations() => [
      Conversation(id: 'c1', title: 'Feeling overwhelmed today',
          lastMessage: 'Thanks, that really helps.',
          updatedAt: DateTime.now().subtract(const Duration(hours: 2))),
      Conversation(id: 'c2', title: 'Building better habits',
          lastMessage: 'Let me try that tomorrow.',
          updatedAt: DateTime.now().subtract(const Duration(days: 1))),
      Conversation(id: 'c3', title: 'I need help with motivation',
          lastMessage: 'That makes sense.',
          updatedAt: DateTime.now().subtract(const Duration(days: 2))),
    ];

List<ChatMessage> _messages() => [
      ChatMessage(id: 'm1', conversationId: 'c1',
          text: "I've been feeling really overwhelmed lately and I'm not sure "
              'where to start.',
          sender: ChatSender.user,
          timestamp: DateTime.now().subtract(const Duration(minutes: 6))),
      ChatMessage(id: 'm2', conversationId: 'c1',
          text: "That sounds really hard, and it's brave of you to say it out "
              "loud. Let's take it one small step at a time. What feels "
              'heaviest right now?',
          sender: ChatSender.ai,
          timestamp: DateTime.now().subtract(const Duration(minutes: 5))),
      ChatMessage(id: 'm3', conversationId: 'c1',
          text: 'Mostly work — it never seems to stop.',
          sender: ChatSender.user,
          timestamp: DateTime.now().subtract(const Duration(minutes: 4))),
    ];

AppNotification _n(String id, String title, AppNotificationType type,
        {required bool read, required int hoursAgo}) =>
    AppNotification(
      id: id, title: title,
      body: 'Tap to open the related screen and keep your momentum going.',
      type: type, isRead: read,
      createdAt: DateTime.now().subtract(Duration(hours: hoursAgo)),
    );

List<AppNotification> _notifications() => [
      _n('n1', 'Time for your daily check-in',
          AppNotificationType.dailyReminder, read: false, hoursAgo: 1),
      _n('n2', 'How are you feeling today?',
          AppNotificationType.moodReminder, read: false, hoursAgo: 4),
      _n('n3', 'Your journal is waiting',
          AppNotificationType.journalReminder, read: true, hoursAgo: 26),
      _n('n4', 'Your free trial ends in 3 days',
          AppNotificationType.trialEnding, read: true, hoursAgo: 30),
      _n('n5', "What's new in LifeReset",
          AppNotificationType.announcement, read: true, hoursAgo: 100),
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
  Future<Result<void>> markRead(String u, String i) async => const Success(null);
  @override
  Future<Result<void>> markAllRead(String u) async => const Success(null);
  @override
  Future<Result<void>> delete(String u, String i) async => const Success(null);
  @override
  Future<Result<void>> clearAll(String u) async => const Success(null);
  @override
  Future<Result<void>> savePrefs(String u, NotificationPrefs p) async => const Success(null);
  @override
  Future<Result<void>> registerToken(String u, String t, String p) async => const Success(null);
  @override
  Future<Result<void>> removeToken(String u, String t) async => const Success(null);
}

List<Override> _overrides() => [
      currentUserProvider.overrideWithValue(_user),
      userProfileProvider.overrideWith((ref) => Stream.value(null)),
      profileProvider.overrideWith((ref) => Stream.value(_profile())),
      coachContextProvider.overrideWith((ref) => _ctx()),
      conversationsProvider.overrideWith((ref) => Stream.value(_conversations())),
      messagesProvider('c1').overrideWith((ref) => Stream.value(_messages())),
      inboxProvider.overrideWith((ref) => Stream.value(_notifications())),
      notificationsRepositoryProvider
          .overrideWithValue(_FakeNotifRepo(_notifications())),
    ];

Future<void> _shoot(WidgetTester t, Widget screen, String file,
    {double height = 1500}) async {
  final key = GlobalKey();
  final size = Size(390, height);
  t.view.devicePixelRatio = 1.0;
  t.view.physicalSize = size;
  addTearDown(() {
    t.view.resetPhysicalSize();
    t.view.resetDevicePixelRatio();
  });
  await t.pumpWidget(ProviderScope(
    overrides: _overrides(),
    child: MaterialApp(
      home: RepaintBoundary(
        key: key,
        child: MediaQuery(
          data: MediaQueryData(size: size),
          child: screen,
        ),
      ),
    ),
  ));
  await t.pump();
  await t.pump(const Duration(milliseconds: 400));
  await t.pump(const Duration(milliseconds: 600));
  await t.runAsync(() async {
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 2.0);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final dir = Directory('build/cpn_preview')..createSync(recursive: true);
    File('${dir.path}/$file').writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

void main() {
  testWidgets('shot coach home', (t) async {
    await _shoot(t, const CoachHomeScreen(), 'coach_home.png');
  });
  testWidgets('shot coach chat', (t) async {
    await _shoot(t, const ChatScreen(conversationId: 'c1'), 'coach_chat.png',
        height: 1000);
  });
  testWidgets('shot profile', (t) async {
    await _shoot(t, const ProfileHomeScreen(), 'profile_home.png');
  });
  testWidgets('shot edit profile', (t) async {
    await _shoot(t, EditProfileScreen(profile: _profile()), 'profile_edit.png');
  });
  testWidgets('shot settings', (t) async {
    await _shoot(t, const SettingsScreen(), 'settings.png');
  });
  testWidgets('shot notifications inbox', (t) async {
    await _shoot(t, const NotificationsInboxScreen(), 'notifications.png');
  });
  testWidgets('shot notification settings', (t) async {
    await _shoot(
        t, const NotificationSettingsScreen(), 'notification_settings.png',
        height: 1000);
  });
}
