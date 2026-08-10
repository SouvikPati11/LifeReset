import '../../../../core/utils/result.dart';
import '../entities/daily_quote.dart';
import '../entities/daily_task.dart';
import '../entities/recovery_program.dart';
import '../entities/user_stats.dart';

/// Contract for the Home Dashboard's data (Cloud Firestore).
abstract interface class HomeRepository {
  /// Streams the user's recovery stats from `users/{uid}`.
  Stream<UserStats> watchUserStats(String uid);

  /// Streams the admin-authored tasks for [day] of [programId] (from
  /// `program_tasks`) — the user's current-day plan.
  Stream<List<DailyTask>> watchDailyTasks({
    required String programId,
    required int day,
  });

  /// Reads today's motivational quote (falls back to a default when absent).
  Future<Result<DailyQuote>> getTodaysQuote();

  /// Reads the active recovery program (`programs/breakup_recovery`).
  Future<Result<RecoveryProgram>> getProgram();

  /// Marks a task complete/incomplete for the user and persists it immediately.
  Future<Result<void>> setTaskCompleted({
    required String uid,
    required String taskId,
    required bool completed,
  });
}
