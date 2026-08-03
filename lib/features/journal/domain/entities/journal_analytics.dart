import 'mood_entry.dart';
import 'mood_type.dart';

/// A point on the mood-trend chart.
class MoodTrendPoint {
  const MoodTrendPoint({required this.date, required this.score});

  final DateTime date;
  final int score;
}

/// Aggregated mood analytics computed from the user's mood history.
class MoodAnalytics {
  const MoodAnalytics({
    required this.trend,
    required this.distribution,
    required this.averageScore,
    required this.streak,
    required this.totalTracked,
  });

  final List<MoodTrendPoint> trend;
  final Map<MoodType, int> distribution;

  /// Average wellbeing score on a 0–10 scale.
  final double averageScore;

  /// Consecutive days (ending today) with a recorded mood.
  final int streak;
  final int totalTracked;

  factory MoodAnalytics.empty() => const MoodAnalytics(
        trend: [],
        distribution: {},
        averageScore: 0,
        streak: 0,
        totalTracked: 0,
      );

  /// Builds analytics from a chronological list of mood entries.
  factory MoodAnalytics.fromHistory(List<MoodEntry> history) {
    if (history.isEmpty) return MoodAnalytics.empty();

    final sorted = [...history]..sort((a, b) => a.date.compareTo(b.date));
    final trend = sorted
        .map((e) => MoodTrendPoint(date: e.date, score: e.mood.score))
        .toList(growable: false);

    final distribution = <MoodType, int>{};
    var total = 0;
    for (final entry in sorted) {
      distribution.update(entry.mood, (v) => v + 1, ifAbsent: () => 1);
      total += entry.mood.score;
    }
    final average = total / sorted.length;

    return MoodAnalytics(
      trend: trend,
      distribution: distribution,
      averageScore: average,
      streak: _streak(sorted),
      totalTracked: sorted.length,
    );
  }

  static int _streak(List<MoodEntry> sorted) {
    final days = sorted
        .map((e) => DateTime(e.date.year, e.date.month, e.date.day))
        .toSet();
    final today = DateTime.now();
    var cursor = DateTime(today.year, today.month, today.day);
    // Allow the streak to count from today or yesterday.
    if (!days.contains(cursor)) {
      cursor = cursor.subtract(const Duration(days: 1));
      if (!days.contains(cursor)) return 0;
    }
    var streak = 0;
    while (days.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }
}

/// Headline counts for the journal overview / healing progress.
class JournalStats {
  const JournalStats({
    required this.totalEntries,
    required this.entriesThisWeek,
    required this.moodDaysThisWeek,
    required this.moodStreak,
  });

  final int totalEntries;
  final int entriesThisWeek;

  /// Days in the last 7 with a recorded mood (out of 7).
  final int moodDaysThisWeek;
  final int moodStreak;

  factory JournalStats.empty() => const JournalStats(
        totalEntries: 0,
        entriesThisWeek: 0,
        moodDaysThisWeek: 0,
        moodStreak: 0,
      );
}
