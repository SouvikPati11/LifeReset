import '../entities/daily_task.dart';
import '../repositories/home_repository.dart';

/// Streams the admin-authored tasks for the user's current day.
class WatchDailyTasks {
  const WatchDailyTasks(this._repository);

  final HomeRepository _repository;

  Stream<List<DailyTask>> call({
    required String programId,
    required int day,
  }) =>
      _repository.watchDailyTasks(programId: programId, day: day);
}
