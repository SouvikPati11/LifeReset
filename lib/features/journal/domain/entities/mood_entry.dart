import 'mood_type.dart';

/// A recorded mood for a given day (`users/{uid}/mood_history/{yyyy-MM-dd}`).
///
/// One entry per day; recording again updates that day's mood.
class MoodEntry {
  const MoodEntry({
    required this.id,
    required this.date,
    required this.mood,
    required this.note,
    required this.factors,
    required this.createdAt,
  });

  /// Document id, formatted `yyyy-MM-dd`.
  final String id;
  final DateTime date;
  final MoodType mood;
  final String note;

  /// Optional "what's affecting your mood" tags.
  final List<String> factors;
  final DateTime createdAt;
}
