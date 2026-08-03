import '../entities/daily_task.dart';
import '../repositories/home_repository.dart';

/// Streams today's recovery tasks.
class WatchDailyTasks {
  const WatchDailyTasks(this._repository);

  final HomeRepository _repository;

  Stream<List<DailyTask>> call() => _repository.watchDailyTasks();
}
