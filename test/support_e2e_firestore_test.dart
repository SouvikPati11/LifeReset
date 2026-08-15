import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lifereset/core/constants/content_keys.dart';
import 'package:lifereset/features/admin/data/datasources/admin_remote_data_source.dart';
import 'package:lifereset/features/support/data/support_remote_data_source.dart';

/// TRUE Admin → Firestore → User end-to-end verification.
///
/// One in-memory [FakeFirebaseFirestore] is shared between the *real*
/// [AdminRemoteDataSource] (the exact class the Admin Panel writes through) and
/// the *real* [SupportRemoteDataSource] (the exact class the user screens read
/// through). No mocks of the app's own code — only the backend is in-memory.
void main() {
  late FakeFirebaseFirestore db;
  late AdminRemoteDataSource admin;
  late SupportRemoteDataSource user;

  setUp(() {
    db = FakeFirebaseFirestore();
    admin = AdminRemoteDataSource(db);
    user = SupportRemoteDataSource(db);
  });

  test('Terms: admin edits & saves → user reads the new content', () async {
    // 1–3. Admin Panel → Content Pages → Terms → Save (same call the write
    // controller makes: setDoc(app_config, terms, {title, body})).
    await admin.setDoc(ContentPaths.appConfig, ContentPaths.termsDoc, {
      ContentKeys.title: 'Test Terms',
      ContentKeys.body: 'These are the updated terms from the Admin Panel.',
    });

    // 4–5. User-side repository reads the same document.
    final page = await user.watchPage(ContentPaths.termsDoc).first;
    expect(page.title, 'Test Terms');
    expect(page.body, 'These are the updated terms from the Admin Panel.');
  });

  test('Help Center: admin content is displayed to the user', () async {
    await admin.setDoc(ContentPaths.appConfig, ContentPaths.helpDoc, {
      ContentKeys.title: 'Test Help Center',
      ContentKeys.body: 'This is test content from Admin Panel.',
    });

    final page = await user.watchPage(ContentPaths.helpDoc).first;
    expect(page.title, 'Test Help Center');
    expect(page.body, 'This is test content from Admin Panel.');
  });

  test('FAQs: admin creates enabled/disabled → user loads only enabled, ordered',
      () async {
    // Admin creates three FAQs (createDoc = the "Add FAQ" path).
    await admin.createDoc(ContentPaths.faqs, {
      ContentKeys.question: 'Second question?',
      ContentKeys.answer: 'Second answer.',
      ContentKeys.order: 1,
      ContentKeys.status: 'active',
    });
    await admin.createDoc(ContentPaths.faqs, {
      ContentKeys.question: 'First question?',
      ContentKeys.answer: 'First answer.',
      ContentKeys.order: 0,
      ContentKeys.status: 'active',
    });
    await admin.createDoc(ContentPaths.faqs, {
      ContentKeys.question: 'Hidden question?',
      ContentKeys.answer: 'Should not appear.',
      ContentKeys.order: 2,
      ContentKeys.status: 'inactive', // disabled by admin
    });

    final faqs = await user.watchFaqs().first;
    // Only the two enabled FAQs, sorted by order.
    expect(faqs.map((f) => f.question).toList(),
        ['First question?', 'Second question?']);
    expect(faqs.every((f) => f.question != 'Hidden question?'), isTrue);
  });

  test('FAQ edit + delete propagate to the user read', () async {
    final id = await admin.createDoc(ContentPaths.faqs, {
      ContentKeys.question: 'Editable?',
      ContentKeys.answer: 'Before edit.',
      ContentKeys.order: 0,
      ContentKeys.status: 'active',
    });
    // Admin edits the answer.
    await admin.setDoc(ContentPaths.faqs, id, {
      ContentKeys.answer: 'After edit.',
    });
    var faqs = await user.watchFaqs().first;
    expect(faqs.single.answer, 'After edit.');

    // Admin deletes it.
    await admin.deleteDoc(ContentPaths.faqs, id);
    faqs = await user.watchFaqs().first;
    expect(faqs, isEmpty);
  });

  test('Contact Support: admin settings → user reads email/phone/message',
      () async {
    await admin.setDoc(ContentPaths.appConfig, ContentPaths.generalDoc, {
      ContentKeys.supportEmail: 'help@lifereset.app',
      ContentKeys.supportPhone: '+1 555 0100',
      ContentKeys.supportMessage: 'We usually reply within a day.',
    });

    final info = await user.watchSupportInfo().first;
    expect(info.email, 'help@lifereset.app');
    expect(info.phone, '+1 555 0100');
    expect(info.message, 'We usually reply within a day.');
    expect(info.hasAny, isTrue);
  });

  test('Empty/missing documents degrade to safe empty content (no fake data)',
      () async {
    expect((await user.watchPage(ContentPaths.termsDoc).first).isEmpty, isTrue);
    expect((await user.watchFaqs().first), isEmpty);
    expect((await user.watchSupportInfo().first).hasAny, isFalse);
  });
}
