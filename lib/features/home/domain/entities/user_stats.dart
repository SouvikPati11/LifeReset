/// A single recovery-score sample used by the progress/weekly charts.
class ScorePoint {
  const ScorePoint({required this.date, required this.score});

  final DateTime date;
  final int score;

  /// Single-letter weekday label (M, T, W, …) for chart axes.
  String get weekdayLabel {
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return labels[(date.weekday - 1) % 7];
  }
}

/// The user's recovery stats, read from `users/{uid}`.
///
/// Missing fields fall back to sane defaults so a brand-new account (no data
/// yet) renders correctly.
class UserStats {
  const UserStats({
    required this.recoveryScore,
    required this.streak,
    required this.currentDay,
    required this.completedTaskIds,
    required this.scoreHistory,
  });

  /// Default recovery score shown before any score has been recorded.
  static const int defaultRecoveryScore = 0;

  final int recoveryScore;
  final int streak;
  final int currentDay;
  final Set<String> completedTaskIds;
  final List<ScorePoint> scoreHistory;

  /// Sensible defaults for an account with no data yet.
  factory UserStats.initial() => const UserStats(
        recoveryScore: defaultRecoveryScore,
        streak: 0,
        currentDay: 1,
        completedTaskIds: {},
        scoreHistory: [],
      );

  /// Change vs. the previous recorded score ("↑ 8 points from yesterday").
  int get scoreDelta {
    if (scoreHistory.length < 2) return 0;
    return recoveryScore - scoreHistory[scoreHistory.length - 2].score;
  }

  bool isTaskCompleted(String taskId) => completedTaskIds.contains(taskId);
}
