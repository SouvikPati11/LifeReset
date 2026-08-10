/// A single recovery task for a program day, sourced from the admin-managed
/// `program_tasks` collection.
///
/// The core fields ([title], [description], [duration]) drive the list cards;
/// the optional [whyThisMatters] / [journalPrompt] / [moodGoal] carry the extra
/// admin context shown on the Task Details screen (empty when not provided).
class DailyTask {
  const DailyTask({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.order,
    this.iconKey,
    this.whyThisMatters = '',
    this.journalPrompt = '',
    this.moodGoal = '',
  });

  final String id;
  final String title;
  final String description;

  /// Human-readable duration label, e.g. "5 min" or "Daily".
  final String duration;

  /// Sort order within the day's plan.
  final int order;

  /// Optional key used to pick a matching icon in the UI.
  final String? iconKey;

  /// Admin `aiContext` — the "Why this matters" detail.
  final String whyThisMatters;

  /// Admin `journalQuestion` — an optional reflective prompt.
  final String journalPrompt;

  /// Admin `moodGoal` — an optional mood intention for the task.
  final String moodGoal;
}
