import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/content_keys.dart';
import '../domain/entities/support_content.dart';

/// Reads user-facing help & legal content from Firestore. Content is authored in
/// the Admin Panel; the client only ever reads it.
///
/// Storage (see [ContentPaths]):
///  - `app_config/terms`   → Terms of Service ({title, body})
///  - `app_config/help`    → Help Center intro ({title, body})
///  - `app_config/general` → Contact Support ({supportEmail, supportPhone, supportMessage})
///  - `faqs/{id}`          → FAQs ({question, answer, order, status})
class SupportRemoteDataSource {
  SupportRemoteDataSource(this._db);

  final FirebaseFirestore _db;

  Stream<LegalPage> watchPage(String docId) {
    return _db
        .collection(ContentPaths.appConfig)
        .doc(docId)
        .snapshots()
        .map((doc) => LegalPage.fromMap(doc.data() ?? const {}));
  }

  Stream<List<FaqEntry>> watchFaqs() {
    // Filter to enabled entries; sort client-side by `order` so no composite
    // index is required.
    return _db
        .collection(ContentPaths.faqs)
        .where(ContentKeys.status, isEqualTo: 'active')
        .snapshots()
        .map((snap) {
      final rows = snap.docs.map((d) {
        final data = d.data();
        return (
          entry: FaqEntry.fromMap(d.id, data),
          order: (data[ContentKeys.order] as num?)?.toInt() ?? 0,
        );
      }).toList()
        ..sort((a, b) => a.order.compareTo(b.order));
      return [
        for (final r in rows)
          if (r.entry.question.trim().isNotEmpty) r.entry,
      ];
    });
  }

  Stream<SupportInfo> watchSupportInfo() {
    return _db
        .collection(ContentPaths.appConfig)
        .doc(ContentPaths.generalDoc)
        .snapshots()
        .map((doc) => SupportInfo.fromMap(doc.data() ?? const {}));
  }
}
