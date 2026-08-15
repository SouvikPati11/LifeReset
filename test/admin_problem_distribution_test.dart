import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lifereset/features/admin/data/datasources/admin_remote_data_source.dart';

/// Verifies the Dashboard "Users by Problem Category" donut against the *real*
/// [AdminRemoteDataSource] aggregate reads on an in-memory Firestore. This is a
/// read-only projection over `users/{uid}.problem` — no collection is created
/// and the fixed onboarding enum is never mutated.
void main() {
  test('counts users per recovery area, ignoring users with no problem',
      () async {
    final db = FakeFirebaseFirestore();
    final admin = AdminRemoteDataSource(db);

    Future<void> addUser(String? problem) => db.collection('users').add({
          if (problem != null) 'problem': problem,
          'createdAt': DateTime(2026, 1, 1),
        });

    await addUser('breakup_recovery');
    await addUser('breakup_recovery');
    await addUser('breakup_recovery');
    await addUser('anxiety_stress');
    await addUser('anxiety_stress');
    await addUser('low_confidence');
    await addUser('overthinking');
    await addUser(null); // no onboarding problem — counted in no bucket

    final dist = await admin.getProblemDistribution();
    final byKey = {for (final d in dist) d.problemKey: d.count};

    expect(byKey['breakup_recovery'], 3);
    expect(byKey['anxiety_stress'], 2);
    expect(byKey['low_confidence'], 1);
    expect(byKey['overthinking'], 1);

    // Every fixed enum value is represented, with human labels from the enum.
    expect(dist.length, 4);
    expect(
      dist.map((d) => d.label),
      containsAll(<String>[
        'Breakup Recovery',
        'Anxiety & Stress',
        'Low Self-Confidence',
        'Overthinking',
      ]),
    );
  });

  test('empty user base yields zeroed buckets (no fabricated data)', () async {
    final admin = AdminRemoteDataSource(FakeFirebaseFirestore());
    final dist = await admin.getProblemDistribution();
    expect(dist.length, 4);
    expect(dist.every((d) => d.count == 0), isTrue);
  });
}
