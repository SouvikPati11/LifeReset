import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lifereset/features/admin/data/datasources/admin_remote_data_source.dart';
import 'package:lifereset/features/admin/data/repositories/admin_repository_impl.dart';
import 'package:lifereset/features/admin/presentation/providers/admin_providers.dart';
import 'package:lifereset/features/admin/presentation/views/admin_users_view.dart';
import 'package:lifereset/features/admin/presentation/views/coach_analytics_view.dart';
import 'package:lifereset/features/admin/presentation/views/daily_tracking_view.dart';
import 'package:lifereset/features/admin/presentation/views/problems_view.dart';
import 'package:lifereset/features/admin/presentation/views/progress_view.dart';
import 'package:lifereset/features/admin/presentation/views/roles_permissions_view.dart';
import 'package:lifereset/features/admin/presentation/views/system_logs_view.dart';
import 'package:lifereset/features/admin/presentation/widgets/admin_style.dart';
import 'package:lifereset/features/authentication/domain/entities/user_profile.dart';
import 'package:lifereset/features/authentication/presentation/providers/user_providers.dart';

const _admin = UserProfile(
  id: 'admin1', name: 'Admin', email: 'admin1@x.com', role: UserRole.admin);

Future<FakeFirebaseFirestore> _seed() async {
  final db = FakeFirebaseFirestore();
  Future<void> user(String uid, {String role = 'user', int score = 40, String? problem}) =>
      db.collection('users').doc(uid).set({
        'name': uid, 'email': '$uid@x.com', 'role': role,
        'subscription': 'free', 'recoveryScore': score, 'streak': 3,
        'currentDay': 5, if (problem != null) 'problem': problem,
        'createdAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
      });
  await user('admin1', role: 'admin', problem: 'breakup_recovery');
  await user('u1', score: 80, problem: 'anxiety_stress');
  await user('u2', score: 95, problem: 'breakup_recovery');
  await db.collection('users').doc('u1').collection('mood_history').add(
      {'mood': 'great', 'date': Timestamp.fromDate(DateTime.now())});
  await db.collection('users').doc('u1').collection('journal_entries').add({'t': 1});
  await db.collection('users').doc('u2').collection('ai_conversations').add(
      {'createdAtMs': DateTime.now().millisecondsSinceEpoch});
  await db.collection('audit_logs').add({
    'actorUid': 'admin1', 'actorEmail': 'admin1@x.com', 'action': 'update',
    'module': 'users', 'targetId': 'u1', 'fields': ['role'],
    'timestamp': Timestamp.fromDate(DateTime.now()),
  });
  return db;
}

Widget _host(FakeFirebaseFirestore db, Widget view) => ProviderScope(
      overrides: [
        userProfileProvider.overrideWith((ref) => Stream.value(_admin)),
        adminRepositoryProvider.overrideWithValue(
            AdminRepositoryImpl(AdminRemoteDataSource(db))),
      ],
      child: MaterialApp(
        theme: AdminStyle.theme(),
        home: Scaffold(body: view),
      ),
    );

Future<void> _pump(WidgetTester t, Widget app, Size size) async {
  t.view.devicePixelRatio = 1.0;
  t.view.physicalSize = size;
  await t.pumpWidget(app);
  await t.pump();
  await t.pump(const Duration(milliseconds: 350));
}

void main() {
  tearDown(() {
    final v = TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    v.resetPhysicalSize();
    v.resetDevicePixelRatio();
  });

  final views = <String, Widget Function()>{
    'Problems': ProblemsView.new,
    'DailyTracking': DailyTrackingView.new,
    'Progress': ProgressView.new,
    'CoachAnalytics': CoachAnalyticsView.new,
    'AdminUsers': AdminUsersView.new,
    'RolesPermissions': RolesPermissionsView.new,
    'SystemLogs': SystemLogsView.new,
  };

  for (final entry in views.entries) {
    testWidgets('${entry.key} renders responsively without overflow',
        (t) async {
      for (final size in const [Size(1200, 2000), Size(700, 2000), Size(380, 2000)]) {
        final db = await _seed();
        await _pump(t, _host(db, entry.value()), size);
        expect(t.takeException(), isNull,
            reason: '${entry.key} @ ${size.width}px');
      }
    });
  }

  testWidgets('Problems shows the read-only distribution with real labels',
      (t) async {
    final db = await _seed();
    await _pump(t, _host(db, const ProblemsView()), const Size(1200, 2000));
    expect(find.text('Distribution by Problem'), findsOneWidget);
    expect(find.text('Breakup Recovery'), findsWidgets);
  });

  testWidgets('AI Coach view keeps conversation content private', (t) async {
    final db = await _seed();
    await _pump(t, _host(db, const CoachAnalyticsView()), const Size(1200, 2000));
    expect(find.text('Total Conversations'), findsOneWidget);
    expect(find.textContaining('never shown here'), findsOneWidget);
  });

  testWidgets('Admin Users lists admins and marks the acting admin', (t) async {
    final db = await _seed();
    await _pump(t, _host(db, const AdminUsersView()), const Size(1200, 2000));
    expect(find.text('admin1@x.com'), findsOneWidget);
    // The signed-in admin is tagged and cannot be self-revoked.
    expect(find.text('You'), findsOneWidget);
    expect(find.text('Grant admin'), findsOneWidget);
  });

  testWidgets('System Logs shows the audit trail', (t) async {
    final db = await _seed();
    await _pump(t, _host(db, const SystemLogsView()), const Size(1200, 2000));
    expect(find.text('UPDATE'), findsOneWidget);
    expect(find.textContaining('users'), findsWidgets);
  });
}
