/// Centralized route names and paths.
///
/// Only the splash route is wired into the router in this foundation build.
/// The remaining entries are declared ahead of time so that feature modules
/// can register their screens against a single source of truth without
/// introducing magic strings.
class AppRoutes {
  const AppRoutes._();

  // Active in the foundation build.
  static const String splash = '/';
  static const String splashName = 'splash';

  // Reserved for upcoming feature modules (not yet registered).
  static const String onboarding = '/onboarding';
  static const String onboardingName = 'onboarding';

  static const String login = '/auth/login';
  static const String loginName = 'login';

  static const String home = '/home';
  static const String homeName = 'home';

  static const String coach = '/coach';
  static const String coachName = 'coach';

  static const String journal = '/journal';
  static const String journalName = 'journal';

  static const String progress = '/progress';
  static const String progressName = 'progress';

  static const String subscription = '/subscription';
  static const String subscriptionName = 'subscription';

  static const String profile = '/profile';
  static const String profileName = 'profile';

  static const String admin = '/admin';
  static const String adminName = 'admin';
}
