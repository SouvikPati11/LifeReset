// Domain entities for the Admin Panel.

enum UserStatus {
  active('active', 'Active'),
  suspended('suspended', 'Suspended'),
  deleted('deleted', 'Deleted');

  const UserStatus(this.value, this.label);
  final String value;
  final String label;
  static UserStatus fromValue(String? v) => values.firstWhere(
        (s) => s.value == v,
        orElse: () => UserStatus.active,
      );
}

enum ContentStatus {
  active('active', 'Active'),
  inactive('inactive', 'Inactive');

  const ContentStatus(this.value, this.label);
  final String value;
  final String label;
  bool get isActive => this == ContentStatus.active;
  static ContentStatus fromValue(String? v) =>
      v == 'inactive' ? ContentStatus.inactive : ContentStatus.active;
}

enum NotificationType {
  dailyReminder('daily_reminder', 'Daily Reminder'),
  recoveryReminder('recovery_reminder', 'Recovery Reminder'),
  subscriptionReminder('subscription_reminder', 'Subscription Reminder'),
  announcement('announcement', 'Announcement');

  const NotificationType(this.value, this.label);
  final String value;
  final String label;
  static NotificationType fromValue(String? v) =>
      values.firstWhere((t) => t.value == v, orElse: () => announcement);
}

enum NotificationAudience {
  all('all', 'All Users'),
  premium('premium', 'Premium'),
  free('free', 'Free'),
  specific('specific', 'Specific Users');

  const NotificationAudience(this.value, this.label);
  final String value;
  final String label;
  static NotificationAudience fromValue(String? v) =>
      values.firstWhere((a) => a.value == v, orElse: () => all);
}

enum PromptCategory {
  healing('healing', 'Healing'),
  reflection('reflection', 'Reflection'),
  growth('growth', 'Growth'),
  gratitude('gratitude', 'Gratitude'),
  selfLove('self_love', 'Self Love');

  const PromptCategory(this.value, this.label);
  final String value;
  final String label;
  static PromptCategory fromValue(String? v) =>
      values.firstWhere((c) => c.value == v, orElse: () => healing);
}

enum ReportType { user, recovery, revenue, subscription }

/// Dashboard headline stats.
class AdminStats {
  const AdminStats({
    required this.totalUsers,
    required this.premiumUsers,
    required this.freeUsers,
    required this.activeToday,
    required this.newSignups,
    required this.monthlyRevenue,
  });

  final int totalUsers;
  final int premiumUsers;
  final int freeUsers;
  final int activeToday;
  final int newSignups;
  final num monthlyRevenue;

  double get premiumShare => totalUsers == 0 ? 0 : premiumUsers / totalUsers;

  factory AdminStats.empty() => const AdminStats(
        totalUsers: 0,
        premiumUsers: 0,
        freeUsers: 0,
        activeToday: 0,
        newSignups: 0,
        monthlyRevenue: 0,
      );
}

class ActivityPoint {
  const ActivityPoint({required this.date, required this.count});
  final DateTime date;
  final int count;
}

/// The number of users onboarded into a given recovery area (`users/{uid}.
/// problem`). A read-only projection over the fixed onboarding problem enum —
/// no collection is created and the enum is never mutated.
class ProblemDistribution {
  const ProblemDistribution({
    required this.problemKey,
    required this.label,
    required this.count,
  });

  final String problemKey;
  final String label;
  final int count;
}

class TopProgram {
  const TopProgram({required this.name, required this.userCount, required this.iconKey});
  final String name;
  final int userCount;
  final String iconKey;
}

class SystemService {
  const SystemService({required this.name, required this.healthy});
  final String name;
  final bool healthy;
}

/// A user row for the admin user list.
class AdminUser {
  const AdminUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.plan,
    required this.role,
    required this.status,
    required this.createdAt,
  });

  final String uid;
  final String name;
  final String email;
  final String plan;
  final String role;
  final UserStatus status;
  final DateTime? createdAt;
}

class ProgramItem {
  const ProgramItem({
    required this.id,
    required this.name,
    required this.description,
    required this.totalDays,
    required this.status,
    required this.iconKey,
    required this.colorHex,
    required this.userCount,
    required this.order,
  });

  final String id;
  final String name;
  final String description;
  final int totalDays;
  final ContentStatus status;
  final String iconKey;
  final String colorHex;
  final int userCount;
  final int order;
}

class ProgramTaskItem {
  const ProgramTaskItem({
    required this.id,
    required this.programId,
    required this.day,
    required this.order,
    required this.task,
    required this.motivation,
    required this.journalQuestion,
    required this.moodGoal,
    required this.aiContext,
    required this.estimatedMinutes,
    required this.notificationText,
    required this.status,
  });

  final String id;
  final String programId;
  final int day;
  final int order;
  final String task;
  final String motivation;
  final String journalQuestion;
  final String moodGoal;
  final String aiContext;
  final int estimatedMinutes;
  final String notificationText;
  final ContentStatus status;
}

class PromptItem {
  const PromptItem({
    required this.id,
    required this.category,
    required this.text,
    required this.status,
  });

  final String id;
  final PromptCategory category;
  final String text;
  final ContentStatus status;
}

class QuoteItem {
  const QuoteItem({
    required this.id,
    required this.text,
    required this.author,
    required this.category,
    required this.status,
  });

  final String id;
  final String text;
  final String author;
  final String category;
  final ContentStatus status;
}

/// A Help Center FAQ entry, managed from the Admin Panel (`faqs` collection).
class FaqItem {
  const FaqItem({
    required this.id,
    required this.question,
    required this.answer,
    required this.order,
    required this.status,
  });

  final String id;
  final String question;
  final String answer;
  final int order;
  final ContentStatus status;
}

/// An admin-editable long-form content page (Terms of Service, Help Center),
/// stored as a single Firestore document (e.g. `app_config/terms`).
class ContentPage {
  const ContentPage({required this.title, required this.body});

  final String title;
  final String body;

  factory ContentPage.empty() => const ContentPage(title: '', body: '');
}

class AdminNotificationItem {
  const AdminNotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.audience,
    required this.scheduleAt,
    required this.status,
  });

  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final NotificationAudience audience;
  final DateTime? scheduleAt;
  final String status;
}

class AnalyticsSummary {
  const AnalyticsSummary({
    required this.dailyActiveUsers,
    required this.monthlyActiveUsers,
    required this.averageRecoveryScore,
    required this.journalCount,
    required this.aiUsage,
    required this.conversionRate,
  });

  final int dailyActiveUsers;
  final int monthlyActiveUsers;
  final double averageRecoveryScore;
  final int journalCount;
  final int aiUsage;
  final double conversionRate;

  factory AnalyticsSummary.empty() => const AnalyticsSummary(
        dailyActiveUsers: 0,
        monthlyActiveUsers: 0,
        averageRecoveryScore: 0,
        journalCount: 0,
        aiUsage: 0,
        conversionRate: 0,
      );
}

class TransactionItem {
  const TransactionItem({
    required this.id,
    required this.userName,
    required this.plan,
    required this.amount,
    required this.date,
  });

  final String id;
  final String userName;
  final String plan;
  final num amount;
  final DateTime? date;
}

class SubscriptionSummary {
  const SubscriptionSummary({
    required this.premium,
    required this.trial,
    required this.expired,
    required this.revenue,
    required this.conversionRate,
  });

  final int premium;
  final int trial;
  final int expired;
  final num revenue;
  final double conversionRate;

  factory SubscriptionSummary.empty() => const SubscriptionSummary(
        premium: 0,
        trial: 0,
        expired: 0,
        revenue: 0,
        conversionRate: 0,
      );
}

class AppSettings {
  const AppSettings({
    required this.appVersion,
    required this.maintenanceMode,
    required this.defaultLanguage,
    required this.supportEmail,
    required this.supportPhone,
    required this.supportMessage,
    required this.privacyUrl,
    required this.termsUrl,
  });

  final String appVersion;
  final bool maintenanceMode;
  final String defaultLanguage;
  final String supportEmail;
  final String supportPhone;
  final String supportMessage;
  final String privacyUrl;
  final String termsUrl;

  factory AppSettings.initial() => const AppSettings(
        appVersion: '1.0.0',
        maintenanceMode: false,
        defaultLanguage: 'en',
        supportEmail: '',
        supportPhone: '',
        supportMessage: '',
        privacyUrl: '',
        termsUrl: '',
      );
}
