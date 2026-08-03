/// A single recovery task from today's plan (`daily_tasks`).
class DailyTask {
  const DailyTask({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.order,
    this.iconKey,
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
}
