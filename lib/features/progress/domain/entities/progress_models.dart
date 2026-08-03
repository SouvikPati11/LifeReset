// Domain entities for the Progress module — the user's personal recovery
// analytics, aggregated read-only from their own Firestore data.

/// One recovery-score sample over time.
class RecoverySample {
  const RecoverySample({required this.date, required this.score});
  final DateTime date;
  final int score;
}

/// One mood sample over time (0–10 wellbeing score).
class MoodSample {
  const MoodSample({
    required this.date,
    required this.score,
    required this.emoji,
  });
  final DateTime date;
  final int score;
  final String emoji;
}

/// Scalar recovery stats read from `users/{uid}`.
class ProgressStats {
  const ProgressStats({
    required this.recoveryScore,
    required this.streak,
    required this.currentDay,
    required this.completedTasks,
    required this.scoreHistory,
    this.totalDays = 30,
  });

  final int recoveryScore;
  final int streak;
  final int currentDay;
  final int completedTasks;
  final int totalDays;
  final List<RecoverySample> scoreHistory;

  /// Change vs. the previous recorded score.
  int get scoreDelta {
    if (scoreHistory.length < 2) return 0;
    return recoveryScore - scoreHistory[scoreHistory.length - 2].score;
  }

  /// Program completion fraction (0–1).
  double get programProgress {
    if (totalDays <= 0) return 0;
    return (currentDay / totalDays).clamp(0.0, 1.0).toDouble();
  }

  factory ProgressStats.empty() => const ProgressStats(
        recoveryScore: 0,
        streak: 0,
        currentDay: 1,
        completedTasks: 0,
        scoreHistory: [],
      );
}

/// A derived achievement shown on the progress screen. Milestones are computed
/// from the user's stats — there is nothing to write.
class Milestone {
  const Milestone({
    required this.title,
    required this.subtitle,
    required this.achieved,
  });

  final String title;
  final String subtitle;
  final bool achieved;
}

/// Builds the milestone list from the user's current stats.
List<Milestone> buildMilestones({
  required ProgressStats stats,
  required int journalCount,
}) {
  return [
    Milestone(
      title: 'First Step',
      subtitle: 'Begin your recovery journey',
      achieved: stats.currentDay >= 1,
    ),
    Milestone(
      title: 'Building Momentum',
      subtitle: 'Complete 5 recovery tasks',
      achieved: stats.completedTasks >= 5,
    ),
    Milestone(
      title: 'One Week Strong',
      subtitle: 'Reach a 7-day streak',
      achieved: stats.streak >= 7,
    ),
    Milestone(
      title: 'Journaling Habit',
      subtitle: 'Write 5 journal entries',
      achieved: journalCount >= 5,
    ),
    Milestone(
      title: 'Halfway There',
      subtitle: 'Reach day 15 of your program',
      achieved: stats.currentDay >= 15,
    ),
    Milestone(
      title: 'Thriving',
      subtitle: 'Reach a recovery score of 80',
      achieved: stats.recoveryScore >= 80,
    ),
  ];
}
