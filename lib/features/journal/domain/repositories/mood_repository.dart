import '../../../../core/utils/result.dart';
import '../entities/mood_entry.dart';
import '../entities/mood_type.dart';

/// Contract for mood history (`users/{uid}/mood_history`).
abstract interface class MoodRepository {
  /// Streams today's mood, or `null` if not yet recorded.
  Stream<MoodEntry?> watchTodayMood(String uid);

  /// Streams the last [days] of mood entries (for analytics and the calendar).
  Stream<List<MoodEntry>> watchHistory(String uid, {int days});

  /// Records (or updates) the mood for [date].
  Future<Result<void>> saveMood(
    String uid, {
    required DateTime date,
    required MoodType mood,
    required String note,
    required List<String> factors,
  });
}
