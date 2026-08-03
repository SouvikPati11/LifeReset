import '../../../../core/utils/result.dart';
import '../../../../shared/repositories/base_repository.dart';
import '../../domain/entities/daily_quote.dart';
import '../../domain/entities/daily_task.dart';
import '../../domain/entities/recovery_program.dart';
import '../../domain/entities/user_stats.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_data_source.dart';

/// [HomeRepository] backed by Cloud Firestore.
class HomeRepositoryImpl extends BaseRepository implements HomeRepository {
  HomeRepositoryImpl(this._remote);

  final HomeRemoteDataSource _remote;

  @override
  Stream<UserStats> watchUserStats(String uid) =>
      _remote.watchUserStats(uid);

  @override
  Stream<List<DailyTask>> watchDailyTasks() => _remote.watchDailyTasks();

  @override
  Future<Result<DailyQuote>> getTodaysQuote() {
    return guard<DailyQuote>(() => _remote.getTodaysQuote());
  }

  @override
  Future<Result<RecoveryProgram>> getProgram() {
    return guard<RecoveryProgram>(() => _remote.getProgram());
  }

  @override
  Future<Result<void>> setTaskCompleted({
    required String uid,
    required String taskId,
    required bool completed,
  }) {
    return guard<void>(
      () => _remote.setTaskCompleted(
        uid: uid,
        taskId: taskId,
        completed: completed,
      ),
    );
  }
}
