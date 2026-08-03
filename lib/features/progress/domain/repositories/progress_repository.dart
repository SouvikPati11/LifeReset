import '../../../../core/utils/result.dart';
import '../entities/progress_models.dart';

/// Contract for the Progress feature. All reads are of the user's own data.
abstract interface class ProgressRepository {
  /// Scalar recovery stats streamed from `users/{uid}`.
  Stream<ProgressStats> watchStats(String uid);

  /// Recent mood samples (oldest → newest) from `users/{uid}/mood_history`.
  Stream<List<MoodSample>> watchMoodHistory(String uid, {int days});

  /// Total number of journal entries the user has written.
  Future<Result<int>> journalCount(String uid);
}
