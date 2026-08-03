// Domain entities for the Push Notification module.

/// Notification categories. Values are the strings written by the backend
/// (Cloud Functions) and stored on each inbox document's `type` field. The
/// reminder types line up with the Admin Panel's notification types plus the
/// journal / mood / trial reminders driven by Cloud Functions.
enum AppNotificationType {
  dailyReminder('daily_reminder', 'Daily Reminder'),
  recoveryReminder('recovery_reminder', 'Recovery Task Reminder'),
  journalReminder('journal_reminder', 'Journal Reminder'),
  moodReminder('mood_reminder', 'Mood Reminder'),
  trialEnding('trial_ending', 'Trial Ending Reminder'),
  subscriptionReminder('subscription_reminder', 'Subscription Reminder'),
  announcement('announcement', 'Announcement');

  const AppNotificationType(this.value, this.label);
  final String value;
  final String label;

  /// True for marketing/announcement messages (gated by the marketing setting).
  bool get isMarketing => this == AppNotificationType.announcement;

  static AppNotificationType fromValue(String? v) {
    for (final t in values) {
      if (t.value == v) return t;
    }
    return AppNotificationType.announcement;
  }
}

/// A single inbox item stored at `users/{uid}/notifications/{id}`.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    this.createdAt,
  });

  final String id;
  final String title;
  final String body;
  final AppNotificationType type;
  final bool isRead;
  final DateTime? createdAt;
}

/// The user's per-category notification preferences, stored as the
/// `notificationSettings` map on `users/{uid}`. Cloud Functions read these
/// before sending reminders; defaults are opt-in (true).
class NotificationPrefs {
  const NotificationPrefs({
    this.dailyReminder = true,
    this.journalReminder = true,
    this.moodReminder = true,
    this.marketing = true,
  });

  final bool dailyReminder;
  final bool journalReminder;
  final bool moodReminder;
  final bool marketing;

  NotificationPrefs copyWith({
    bool? dailyReminder,
    bool? journalReminder,
    bool? moodReminder,
    bool? marketing,
  }) =>
      NotificationPrefs(
        dailyReminder: dailyReminder ?? this.dailyReminder,
        journalReminder: journalReminder ?? this.journalReminder,
        moodReminder: moodReminder ?? this.moodReminder,
        marketing: marketing ?? this.marketing,
      );

  Map<String, dynamic> toMap() => {
        'dailyReminder': dailyReminder,
        'journalReminder': journalReminder,
        'moodReminder': moodReminder,
        'marketing': marketing,
      };

  factory NotificationPrefs.fromMap(Map<String, dynamic>? map) {
    final m = map ?? const <String, dynamic>{};
    return NotificationPrefs(
      dailyReminder: (m['dailyReminder'] as bool?) ?? true,
      journalReminder: (m['journalReminder'] as bool?) ?? true,
      moodReminder: (m['moodReminder'] as bool?) ?? true,
      marketing: (m['marketing'] as bool?) ?? true,
    );
  }
}
