import '../entities/user_stats.dart';
import '../repositories/home_repository.dart';

/// Streams the user's recovery stats for the dashboard.
class WatchUserStats {
  const WatchUserStats(this._repository);

  final HomeRepository _repository;

  Stream<UserStats> call(String uid) => _repository.watchUserStats(uid);
}
