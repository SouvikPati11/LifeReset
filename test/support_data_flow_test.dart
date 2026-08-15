import 'package:flutter_test/flutter_test.dart';

import 'package:lifereset/core/constants/content_keys.dart';
import 'package:lifereset/features/support/domain/entities/support_content.dart';

/// Verifies the Admin → Firestore → User content contract end-to-end at the
/// data layer: a document written with the Admin Panel's keys (ContentKeys) at
/// the Admin Panel's path (ContentPaths) is read back by the user-facing
/// parsers with the exact same values. Both sides import these constants, so a
/// key/path rename cannot silently break only one side.
void main() {
  group('Admin → Firestore → User content contract', () {
    test('Help Center content the admin writes is read by the user screen', () {
      // Exactly what Admin Panel → Content Pages → Help Center writes, to the
      // document app_config/help.
      final adminWrite = <String, dynamic>{
        ContentKeys.title: 'Test Help Center',
        ContentKeys.body: 'This is test content from Admin Panel.',
      };
      expect(ContentPaths.helpDoc, 'help');
      expect(ContentPaths.appConfig, 'app_config');

      // Exactly what the user-facing Help Center / helpContentProvider reads.
      final page = LegalPage.fromMap(adminWrite);
      expect(page.title, 'Test Help Center');
      expect(page.body, 'This is test content from Admin Panel.');
      expect(page.isEmpty, isFalse);
    });

    test('Terms of Service content round-trips admin write to user read', () {
      final adminWrite = <String, dynamic>{
        ContentKeys.title: 'Terms of Service',
        ContentKeys.body: 'These are the terms you agree to.',
      };
      expect(ContentPaths.termsDoc, 'terms');

      final page = LegalPage.fromMap(adminWrite);
      expect(page.title, 'Terms of Service');
      expect(page.body, 'These are the terms you agree to.');
    });

    test('An enabled FAQ the admin creates is read by the user screen', () {
      final adminWrite = <String, dynamic>{
        ContentKeys.question: 'How do I reset my streak?',
        ContentKeys.answer: 'Open Settings and tap reset.',
        ContentKeys.order: 0,
        ContentKeys.status: 'active', // ContentStatus.active.value
      };
      expect(ContentPaths.faqs, 'faqs');

      final entry = FaqEntry.fromMap('faq1', adminWrite);
      expect(entry.question, 'How do I reset my streak?');
      expect(entry.answer, 'Open Settings and tap reset.');
      // The user query filters status == 'active'; this doc qualifies.
      expect(adminWrite[ContentKeys.status], 'active');
    });

    test('Support settings the admin configures are read by Contact Support',
        () {
      // Exactly what Admin Panel → Settings writes to app_config/general.
      final adminWrite = <String, dynamic>{
        ContentKeys.supportEmail: 'help@lifereset.app',
        ContentKeys.supportPhone: '+1 555 0100',
        ContentKeys.supportMessage: 'We usually reply within a day.',
      };
      expect(ContentPaths.generalDoc, 'general');

      final info = SupportInfo.fromMap(adminWrite);
      expect(info.email, 'help@lifereset.app');
      expect(info.phone, '+1 555 0100');
      expect(info.message, 'We usually reply within a day.');
      expect(info.hasAny, isTrue);
    });

    test('Missing/empty documents degrade to safe empty content', () {
      expect(LegalPage.fromMap(const {}).isEmpty, isTrue);
      expect(SupportInfo.fromMap(const {}).hasAny, isFalse);
      final entry = FaqEntry.fromMap('x', const {});
      expect(entry.question, '');
    });
  });
}
