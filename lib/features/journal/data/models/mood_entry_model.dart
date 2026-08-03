import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/mood_entry.dart';
import '../../domain/entities/mood_type.dart';

/// Maps a `mood_history/{yyyy-MM-dd}` document to [MoodEntry].
class MoodEntryModel {
  const MoodEntryModel._();

  static MoodEntry fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    return MoodEntry(
      id: doc.id,
      date: (data['date'] as Timestamp?)?.toDate() ?? _parseId(doc.id),
      mood: MoodType.fromValue(data['mood'] as String?),
      note: (data['note'] as String?) ?? '',
      factors: (data['factors'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  static DateTime _parseId(String id) => DateTime.tryParse(id) ?? DateTime.now();

  static Map<String, dynamic> toSaveMap({
    required DateTime date,
    required MoodType mood,
    required String note,
    required List<String> factors,
  }) {
    return {
      'date': Timestamp.fromDate(DateTime(date.year, date.month, date.day)),
      'mood': mood.value,
      'note': note,
      'factors': factors,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
