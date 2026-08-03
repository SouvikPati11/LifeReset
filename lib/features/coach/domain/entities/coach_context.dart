/// The user's current recovery context, attached to every AI message and shown
/// on the Coach home "Today's Context" card.
class CoachContext {
  const CoachContext({
    required this.recoveryDay,
    required this.totalDays,
    required this.recoveryScore,
    required this.problemType,
    required this.streak,
    required this.journalEntriesToday,
    this.todayTaskTitle,
    this.todayTaskCompleted = false,
    this.moodLabel,
    this.moodScore,
    this.previousSummary = '',
  });

  final int recoveryDay;
  final int totalDays;
  final int recoveryScore;
  final String problemType;
  final int streak;
  final int journalEntriesToday;
  final String? todayTaskTitle;
  final bool todayTaskCompleted;
  final String? moodLabel;
  final int? moodScore;

  /// Short summary of earlier conversation, included for continuity.
  final String previousSummary;

  double get progress =>
      totalDays <= 0 ? 0 : (recoveryDay / totalDays).clamp(0, 1);

  factory CoachContext.initial() => const CoachContext(
        recoveryDay: 1,
        totalDays: 30,
        recoveryScore: 0,
        problemType: 'breakup_recovery',
        streak: 0,
        journalEntriesToday: 0,
      );

  /// Compact map sent to the Cloud Function for prompt construction.
  Map<String, dynamic> toPromptMap() => {
        'recoveryDay': recoveryDay,
        'totalDays': totalDays,
        'recoveryScore': recoveryScore,
        'problemType': problemType,
        'streak': streak,
        'journalEntriesToday': journalEntriesToday,
        if (todayTaskTitle != null) 'todayTaskTitle': todayTaskTitle,
        if (moodLabel != null) 'moodLabel': moodLabel,
        if (moodScore != null) 'moodScore': moodScore,
        if (previousSummary.isNotEmpty) 'previousSummary': previousSummary,
      };
}
