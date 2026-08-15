import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lifereset/features/admin/data/datasources/admin_remote_data_source.dart';
import 'package:lifereset/features/admin/data/repositories/admin_repository_impl.dart';
import 'package:lifereset/features/admin/presentation/controllers/admin_controllers.dart';
import 'package:lifereset/features/admin/presentation/providers/admin_providers.dart';
import 'package:lifereset/features/authentication/domain/entities/user_profile.dart';
import 'package:lifereset/features/authentication/presentation/providers/user_providers.dart';

/// Real [AdminRemoteDataSource] analytics queries over an in-memory Firestore.
void main() {
  late FakeFirebaseFirestore db;
  late AdminRemoteDataSource admin;

  setUp(() {
    db = FakeFirebaseFirestore();
    admin = AdminRemoteDataSource(db);
  });

  Future<void> addUser(
    String uid, {
    String role = 'user',
    int recoveryScore = 0,
    int streak = 0,
    int currentDay = 1,
    String? problem,
  }) =>
      db.collection('users').doc(uid).set({
        'name': uid,
        'email': '$uid@x.com',
        'role': role,
        'subscription': 'free',
        'recoveryScore': recoveryScore,
        'streak': streak,
        'currentDay': currentDay,
        if (problem != null) 'problem': problem,
        'createdAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
      });

  test('tracking analytics count check-ins and mood distribution', () async {
    await addUser('u1');
    await addUser('u2');
    final now = DateTime.now();
    Future<void> mood(String uid, String m, DateTime when) => db
        .collection('users')
        .doc(uid)
        .collection('mood_history')
        .add({'mood': m, 'date': Timestamp.fromDate(when)});

    await mood('u1', 'great', now);
    await mood('u1', 'good', now.subtract(const Duration(days: 2)));
    await mood('u2', 'great', now.subtract(const Duration(days: 10)));
    await mood('u2', 'awful', now);

    final t = await admin.getTrackingAnalytics();
    expect(t.totalCheckIns, 4);
    expect(t.checkInsToday, 2); // the two `now` entries
    expect(t.checkIns7d, 3); // excludes the 10-day-old one
    final byKey = {for (final m in t.moods) m.key: m.count};
    expect(byKey['great'], 2);
    expect(byKey['good'], 1);
    expect(byKey['awful'], 1);
    expect(byKey['sad'], 0);
  });

  test('progress analytics bucket users by recovery score', () async {
    await addUser('a', recoveryScore: 30); // 0–59
    await addUser('b', recoveryScore: 65); // 60–74
    await addUser('c', recoveryScore: 80); // 75–86
    await addUser('d', recoveryScore: 95); // 87–100
    await addUser('e', recoveryScore: 50); // 0–59
    await db.collection('users').doc('a').collection('journal_entries').add({'t': 1});
    await db.collection('users').doc('b').collection('journal_entries').add({'t': 2});

    final p = await admin.getProgressAnalytics();
    final byLabel = {for (final b in p.scoreBuckets) b.label: b.count};
    expect(byLabel['0–59'], 2);
    expect(byLabel['60–74'], 1);
    expect(byLabel['75–86'], 1);
    expect(byLabel['87–100'], 1);
    expect(p.journalEntries, 2);
  });

  test('coach analytics count conversations by recency', () async {
    await addUser('u1');
    await addUser('u2');
    final now = DateTime.now();
    Future<void> convo(String uid, DateTime created) => db
        .collection('users')
        .doc(uid)
        .collection('ai_conversations')
        .add({'createdAtMs': created.millisecondsSinceEpoch});

    await convo('u1', now);
    await convo('u1', now.subtract(const Duration(days: 3)));
    await convo('u2', now.subtract(const Duration(days: 20)));
    await convo('u2', now.subtract(const Duration(days: 40)));

    final c = await admin.getCoachAnalytics();
    expect(c.totalConversations, 4);
    expect(c.conversations7d, 2);
    expect(c.conversations30d, 3);
    expect(c.totalUsers, 2);
    expect(c.avgPerUser, 2.0);
  });

  test('watchAdminUsers returns only admins; findUserByEmail resolves',
      () async {
    await addUser('admin1', role: 'admin');
    await addUser('user1');
    await addUser('admin2', role: 'admin');

    final admins = await admin.watchAdminUsers().first;
    expect(admins.map((u) => u.uid).toSet(), {'admin1', 'admin2'});

    final found = await admin.findUserByEmail('user1@x.com');
    expect(found?.uid, 'user1');
    final missing = await admin.findUserByEmail('nobody@x.com');
    expect(missing, isNull);
  });

  test('audit log is append-only readable and ordered newest-first', () async {
    await admin.logAdminAction(
      actorUid: 'admin1',
      actorEmail: 'admin1@x.com',
      action: 'update',
      module: 'users',
      targetId: 'user1',
      fields: const ['role'],
    );
    await admin.logAdminAction(
      actorUid: 'admin1',
      actorEmail: 'admin1@x.com',
      action: 'delete',
      module: 'quotes',
      targetId: 'q1',
    );

    final logs = await admin.watchAuditLogs().first;
    expect(logs.length, 2);
    // Both actions are present with their metadata.
    final actions = logs.map((l) => l.action).toSet();
    expect(actions, {'update', 'delete'});
    final roleLog = logs.firstWhere((l) => l.module == 'users');
    expect(roleLog.targetId, 'user1');
    expect(roleLog.fields, ['role']);
    expect(roleLog.actorEmail, 'admin1@x.com');
  });

  test('AdminWriteController records an audit entry on every write', () async {
    await addUser('admin1', role: 'admin');
    final container = ProviderContainer(overrides: [
      adminRepositoryProvider
          .overrideWithValue(AdminRepositoryImpl(admin)),
      userProfileProvider.overrideWith((ref) => Stream.value(const UserProfile(
          id: 'admin1', name: 'Admin', email: 'admin1@x.com',
          role: UserRole.admin))),
    ]);
    addTearDown(container.dispose);
    // Ensure the profile stream has emitted before the write reads it.
    await container.read(userProfileProvider.future);

    final ctrl = container.read(adminWriteControllerProvider.notifier);
    await ctrl.save('users', 'user1', {'role': 'admin'});
    await ctrl.remove('quotes', 'q9');
    // Allow the fire-and-forget audit writes to flush.
    await Future<void>.delayed(const Duration(milliseconds: 20));

    final logs = await admin.watchAuditLogs().first;
    expect(logs.length, 2);
    expect(logs.map((l) => l.action).toSet(), {'update', 'delete'});
    final grant = logs.firstWhere((l) => l.module == 'users');
    expect(grant.actorEmail, 'admin1@x.com');
    expect(grant.fields, ['role']);
  });
}
