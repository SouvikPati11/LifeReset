import 'package:flutter/foundation.dart';

/// Minimal logging facade.
///
/// In debug builds it prints to the developer console; in release builds the
/// calls are no-ops (and can later be routed to Crashlytics / Sentry from a
/// single place). Using this instead of `print` keeps `avoid_print` satisfied.
class AppLogger {
  const AppLogger._();

  static void debug(Object? message) {
    if (kDebugMode) {
      debugPrint('[DEBUG] $message');
    }
  }

  static void info(Object? message) {
    if (kDebugMode) {
      debugPrint('[INFO] $message');
    }
  }

  static void warning(Object? message) {
    if (kDebugMode) {
      debugPrint('[WARN] $message');
    }
  }

  static void error(Object? message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('[ERROR] $message');
      if (error != null) debugPrint('  cause: $error');
      if (stackTrace != null) debugPrint('  stack: $stackTrace');
    }
    // TODO(observability): forward to Crashlytics in release builds.
  }
}
