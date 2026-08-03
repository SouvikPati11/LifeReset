import '../../../../core/utils/result.dart';
import '../entities/mood_entry.dart';
import '../entities/mood_type.dart';
import '../repositories/mood_repository.dart';

class WatchTodayMood {
  const WatchTodayMood(this._repo);
  final MoodRepository _repo;
  Stream<MoodEntry?> call(String uid) => _repo.watchTodayMood(uid);
}

class WatchMoodHistory {
  const WatchMoodHistory(this._repo);
  final MoodRepository _repo;
  Stream<List<MoodEntry>> call(String uid, {int days = 30}) =>
      _repo.watchHistory(uid, days: days);
}

class SaveMood {
  const SaveMood(this._repo);
  final MoodRepository _repo;
  Future<Result<void>> call(
    String uid, {
    required DateTime date,
    required MoodType mood,
    required String note,
    required List<String> factors,
  }) =>
      _repo.saveMood(uid, date: date, mood: mood, note: note, factors: factors);
}
