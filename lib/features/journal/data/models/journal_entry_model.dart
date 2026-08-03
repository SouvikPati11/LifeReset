import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/journal_entry.dart';
import '../../domain/entities/mood_type.dart';

/// Maps a `journal_entries/{id}` document to [JournalEntry].
class JournalEntryModel {
  const JournalEntryModel._();

  static JournalEntry fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    final moodValue = data['mood'] as String?;
    return JournalEntry(
      id: doc.id,
      title: (data['title'] as String?) ?? '',
      content: (data['content'] as String?) ?? '',
      mood: moodValue == null ? null : MoodType.fromValue(moodValue),
      tags: (data['tags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      aiInsight: data['aiInsight'] as String?,
      photoUrl: data['photoUrl'] as String?,
      createdAt: _date(data['createdAt'], data['createdAtMs']),
      updatedAt: _date(data['updatedAt'], data['createdAtMs']),
    );
  }

  static DateTime _date(Object? ts, Object? millis) {
    if (ts is Timestamp) return ts.toDate();
    if (millis is int) return DateTime.fromMillisecondsSinceEpoch(millis);
    return DateTime.now();
  }

  static Map<String, dynamic> toCreateMap({
    required String title,
    required String content,
    required MoodType? mood,
    required List<String> tags,
    String? photoUrl,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return {
      'title': title,
      'content': content,
      'mood': mood?.value,
      'tags': tags,
      if (photoUrl != null) 'photoUrl': photoUrl,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAtMs': now,
    };
  }

  static Map<String, dynamic> toUpdateMap({
    required String title,
    required String content,
    required MoodType? mood,
    required List<String> tags,
  }) {
    return {
      'title': title,
      'content': content,
      'mood': mood?.value,
      'tags': tags,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
