import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/daily_quote.dart';

/// Maps a `quotes/{id}` document to [DailyQuote].
class DailyQuoteModel {
  const DailyQuoteModel._();

  static DailyQuote fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    return DailyQuote(
      text: (data['text'] as String?) ?? DailyQuote.fallback.text,
      author: (data['author'] as String?) ?? DailyQuote.fallback.author,
    );
  }
}
