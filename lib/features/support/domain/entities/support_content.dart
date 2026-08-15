// Domain entities for user-facing help & legal content, sourced from the
// admin-managed Firestore documents (`app_config/*`, `faqs`).
//
// The `fromMap` factories key off [ContentKeys] — the same keys the Admin Panel
// writes — so the admin→user contract is a single source of truth.

import '../../../../core/constants/content_keys.dart';

/// A long-form content page (Terms of Service, Help Center intro).
class LegalPage {
  const LegalPage({required this.title, required this.body});

  final String title;
  final String body;

  bool get isEmpty => title.trim().isEmpty && body.trim().isEmpty;

  factory LegalPage.empty() => const LegalPage(title: '', body: '');

  factory LegalPage.fromMap(Map<String, dynamic> data) => LegalPage(
        title: (data[ContentKeys.title] as String?) ?? '',
        body: (data[ContentKeys.body] as String?) ?? '',
      );
}

/// A single Help Center FAQ (already filtered to enabled + ordered).
class FaqEntry {
  const FaqEntry({
    required this.id,
    required this.question,
    required this.answer,
  });

  final String id;
  final String question;
  final String answer;

  factory FaqEntry.fromMap(String id, Map<String, dynamic> data) => FaqEntry(
        id: id,
        question: (data[ContentKeys.question] as String?) ?? '',
        answer: (data[ContentKeys.answer] as String?) ?? '',
      );
}

/// Configurable contact-support information.
class SupportInfo {
  const SupportInfo({
    required this.email,
    required this.phone,
    required this.message,
  });

  final String email;
  final String phone;
  final String message;

  bool get hasAny =>
      email.trim().isNotEmpty ||
      phone.trim().isNotEmpty ||
      message.trim().isNotEmpty;

  factory SupportInfo.empty() =>
      const SupportInfo(email: '', phone: '', message: '');

  factory SupportInfo.fromMap(Map<String, dynamic> data) => SupportInfo(
        email: (data[ContentKeys.supportEmail] as String?) ?? '',
        phone: (data[ContentKeys.supportPhone] as String?) ?? '',
        message: (data[ContentKeys.supportMessage] as String?) ?? '',
      );
}
