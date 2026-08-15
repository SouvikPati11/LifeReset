import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lifereset/features/admin/data/datasources/admin_remote_data_source.dart';
import 'package:lifereset/features/admin/data/repositories/admin_repository_impl.dart';
import 'package:lifereset/features/admin/presentation/admin_dashboard_screen.dart';
import 'package:lifereset/features/admin/presentation/providers/admin_providers.dart';
import 'package:lifereset/features/admin/presentation/widgets/admin_shell.dart';
import 'package:lifereset/features/authentication/domain/entities/user_profile.dart';
import 'package:lifereset/features/authentication/presentation/providers/user_providers.dart';

const _admin = UserProfile(
  id: 'admin1',
  name: 'Admin',
  email: 'admin@lifereset.app',
  role: UserRole.admin,
);

Future<FakeFirebaseFirestore> _seedDb() async {
  final db = FakeFirebaseFirestore();
  // A small, real user base so the problem donut renders true segments.
  for (final p in ['breakup_recovery', 'breakup_recovery', 'anxiety_stress']) {
    await db.collection('users').add({
      'problem': p,
      'name': 'U',
      'email': 'u@x.com',
      'subscription': 'free',
      'createdAt': DateTime(2026, 1, 1),
      'updatedAt': DateTime(2026, 1, 1),
    });
  }
  return db;
}

Widget _app(FakeFirebaseFirestore db) => ProviderScope(
      overrides: [
        userProfileProvider.overrideWith((ref) => Stream.value(_admin)),
        adminRepositoryProvider.overrideWithValue(
          AdminRepositoryImpl(AdminRemoteDataSource(db)),
        ),
      ],
      child: const MaterialApp(home: AdminDashboardScreen()),
    );

Future<void> _pump(WidgetTester t, Widget app, Size size) async {
  t.view.devicePixelRatio = 1.0;
  t.view.physicalSize = size;
  await t.pumpWidget(app);
  await t.pump();
  await t.pump(const Duration(milliseconds: 300));
  await t.pump(const Duration(milliseconds: 300));
}

void main() {
  tearDown(() {
    final v = TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    v.resetPhysicalSize();
    v.resetDevicePixelRatio();
  });

  testWidgets('desktop shows a permanent sidebar, no rail', (t) async {
    final db = await _seedDb();
    await _pump(t, _app(db), const Size(1440, 1000));

    expect(find.byType(AdminSidebar), findsOneWidget);
    expect(find.byType(AdminRail), findsNothing);
    // Grouped nav headers are visible.
    expect(find.text('MANAGEMENT'), findsOneWidget);
    expect(find.text('CONTENT'), findsOneWidget);
    expect(find.text('SETTINGS'), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('tablet shows the icon rail, sidebar only in the closed drawer',
      (t) async {
    final db = await _seedDb();
    await _pump(t, _app(db), const Size(800, 1000));

    expect(find.byType(AdminRail), findsOneWidget);
    // The full sidebar lives inside the (closed) drawer, so it is not built.
    expect(find.byType(AdminSidebar), findsNothing);
    expect(t.takeException(), isNull);
  });

  testWidgets('mobile shows a menu button and no persistent nav', (t) async {
    final db = await _seedDb();
    await _pump(t, _app(db), const Size(400, 900));

    expect(find.byType(AdminRail), findsNothing);
    expect(find.byType(AdminSidebar), findsNothing);
    expect(find.byIcon(Icons.menu_rounded), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('dashboard renders the real problem-category donut', (t) async {
    final db = await _seedDb();
    // Tall viewport so the lazy dashboard ListView builds the donut card.
    await _pump(t, _app(db), const Size(1440, 3200));

    expect(find.text('Users by Problem Category'), findsOneWidget);
    // Labels come from the onboarding enum, driven by seeded user data.
    expect(find.text('Breakup Recovery'), findsOneWidget);
    expect(find.text('Anxiety & Stress'), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('selecting a section swaps the content and top-bar title',
      (t) async {
    final db = await _seedDb();
    await _pump(t, _app(db), const Size(1440, 1000));

    // Navigate to the read-only Problems stub via the sidebar.
    await t.tap(find.text('Problems'));
    await t.pump();
    await t.pump(const Duration(milliseconds: 300));

    expect(find.text('Problem Analytics'), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('no overflow across desktop / tablet / mobile widths', (t) async {
    for (final size in const [
      Size(1440, 1000),
      Size(1100, 1000),
      Size(800, 1000),
      Size(600, 1000),
      Size(400, 900),
      Size(360, 800),
    ]) {
      final db = await _seedDb();
      await _pump(t, _app(db), size);
      expect(t.takeException(), isNull, reason: 'overflow at ${size.width}px');
    }
  });
}
