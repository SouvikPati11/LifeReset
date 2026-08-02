/// Application-wide constant values that are not user-facing strings.
///
/// User-facing copy lives in the localization (`.arb`) files; this file holds
/// technical constants such as durations, keys and collection names.
class AppConstants {
  const AppConstants._();

  static const String appName = 'LifeReset';
  static const String appBundleId = 'com.lifereset.app';

  /// Version 1 supports Breakup Recovery only.
  static const String supportedProgram = 'breakup_recovery';

  // Animation / timing.
  static const Duration splashDuration = Duration(milliseconds: 2200);
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 350);

  // Persistence keys.
  static const String prefsThemeMode = 'prefs.theme_mode';
  static const String prefsLocale = 'prefs.locale';
  static const String prefsOnboardingComplete = 'prefs.onboarding_complete';

  // Firestore collection names (used once repositories are implemented).
  static const String usersCollection = 'users';
  static const String journalsCollection = 'journals';
  static const String progressCollection = 'progress';
  static const String subscriptionsCollection = 'subscriptions';
}
