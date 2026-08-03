import '../../../../core/utils/result.dart';
import '../../../../shared/repositories/base_repository.dart';
import '../../domain/entities/mood_entry.dart';
import '../../domain/entities/mood_type.dart';
import '../../domain/repositories/mood_repository.dart';
import '../datasources/mood_remote_data_source.dart';
import '../models/mood_entry_model.dart';

class MoodRepositoryImpl extends BaseRepository implements MoodRepository {
  MoodRepositoryImpl(this._remote);

  final MoodRemoteDataSource _remote;

  @override
  Stream<MoodEntry?> watchTodayMood(String uid) => _remote.watchTodayMood(uid);

  @override
  Stream<List<MoodEntry>> watchHistory(String uid, {int days = 30}) =>
      _remote.watchHistory(uid, days: days);

  @override
  Future<Result<void>> saveMood(
    String uid, {
    required DateTime date,
    required MoodType mood,
    required String note,
    required List<String> factors,
  }) {
    return guard<void>(() => _remote.saveMood(
          uid,
          FirebaseMoodRemoteDataSource.dateId(date),
          MoodEntryModel.toSaveMap(
            date: date,
            mood: mood,
            note: note,
            factors: factors,
          ),
        ));
  }
}
