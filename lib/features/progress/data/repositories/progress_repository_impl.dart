import '../../../../core/utils/result.dart';
import '../../../../shared/repositories/base_repository.dart';
import '../../domain/entities/progress_models.dart';
import '../../domain/repositories/progress_repository.dart';
import '../datasources/progress_remote_data_source.dart';

class ProgressRepositoryImpl extends BaseRepository implements ProgressRepository {
  ProgressRepositoryImpl(this._remote);

  final ProgressRemoteDataSource _remote;

  @override
  Stream<ProgressStats> watchStats(String uid) => _remote.watchStats(uid);

  @override
  Stream<List<MoodSample>> watchMoodHistory(String uid, {int days = 14}) =>
      _remote.watchMoodHistory(uid, days: days);

  @override
  Future<Result<int>> journalCount(String uid) =>
      guard(() => _remote.journalCount(uid));
}
