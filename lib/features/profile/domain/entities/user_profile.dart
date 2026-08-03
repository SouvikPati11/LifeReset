/// Gender options for the profile.
enum Gender {
  male('male', 'Male'),
  female('female', 'Female'),
  nonBinary('non_binary', 'Non-binary'),
  preferNotToSay('prefer_not_to_say', 'Prefer not to say');

  const Gender(this.value, this.label);
  final String value;
  final String label;

  static Gender? fromValue(String? v) {
    if (v == null) return null;
    for (final g in Gender.values) {
      if (g.value == v) return g;
    }
    return null;
  }
}

/// App appearance preference.
enum AppearanceMode {
  system('system', 'System'),
  light('light', 'Light'),
  dark('dark', 'Dark');

  const AppearanceMode(this.value, this.label);
  final String value;
  final String label;

  static AppearanceMode fromValue(String? v) {
    switch (v) {
      case 'light':
        return AppearanceMode.light;
      case 'dark':
        return AppearanceMode.dark;
      default:
        return AppearanceMode.system;
    }
  }
}

/// The user's chosen subscription plan (entitlement is set server-side after
/// payment; this is the intent recorded on plan selection).
enum SubscriptionPlan {
  free('free', 'Basic'),
  premium('premium', 'Premium');

  const SubscriptionPlan(this.value, this.label);
  final String value;
  final String label;

  bool get isPremium => this == SubscriptionPlan.premium;

  static SubscriptionPlan fromValue(String? v) =>
      v == 'premium' ? SubscriptionPlan.premium : SubscriptionPlan.free;
}

/// Free-trial state.
enum TrialStatus {
  none('none'),
  active('active'),
  expired('expired');

  const TrialStatus(this.value);
  final String value;

  static TrialStatus fromValue(String? v) {
    switch (v) {
      case 'active':
        return TrialStatus.active;
      case 'expired':
        return TrialStatus.expired;
      default:
        return TrialStatus.none;
    }
  }
}

/// The complete profile aggregated from `users/{uid}`.
class UserProfile {
  const UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.plan,
    required this.trialStatus,
    required this.appearance,
    required this.language,
    required this.notificationsEnabled,
    required this.remindersEnabled,
    required this.recoveryScore,
    required this.currentDay,
    required this.streak,
    required this.completedTasks,
    this.photoUrl,
    this.gender,
    this.dateOfBirth,
    this.bio = '',
    this.location = '',
    this.trialEndDate,
  });

  static const int trialLengthDays = 7;

  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final Gender? gender;
  final DateTime? dateOfBirth;
  final String bio;
  final String location;
  final String language;
  final AppearanceMode appearance;
  final bool notificationsEnabled;
  final bool remindersEnabled;
  final SubscriptionPlan plan;
  final TrialStatus trialStatus;
  final DateTime? trialEndDate;

  // Cross-module recovery values (read-only here).
  final int recoveryScore;
  final int currentDay;
  final int streak;
  final int completedTasks;

  bool get isOnTrial => trialStatus == TrialStatus.active && trialEndDate != null;

  /// Whole days left in the trial (0–[trialLengthDays]).
  int get trialDaysLeft {
    if (trialEndDate == null) return 0;
    final diff = trialEndDate!.difference(DateTime.now());
    if (diff.isNegative) return 0;
    return (diff.inHours / 24).ceil().clamp(0, trialLengthDays);
  }

  /// Trial completion fraction (0–1) for the progress bar.
  double get trialProgress {
    if (!isOnTrial) return 0;
    return ((trialLengthDays - trialDaysLeft) / trialLengthDays)
        .clamp(0.0, 1.0)
        .toDouble();
  }

  factory UserProfile.initial(String uid, String email) => UserProfile(
        uid: uid,
        name: '',
        email: email,
        plan: SubscriptionPlan.free,
        trialStatus: TrialStatus.none,
        appearance: AppearanceMode.system,
        language: 'en',
        notificationsEnabled: true,
        remindersEnabled: false,
        recoveryScore: 0,
        currentDay: 1,
        streak: 0,
        completedTasks: 0,
      );
}
