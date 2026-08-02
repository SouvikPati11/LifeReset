import 'package:firebase_core/firebase_core.dart';

import '../../core/utils/app_logger.dart';
import '../../firebase_options.dart';

/// Handles one-time Firebase initialization.
///
/// This foundation build ships with placeholder [DefaultFirebaseOptions], so
/// initialization is expected to fail until a real project is configured via
/// `flutterfire configure`. The failure is caught and logged rather than
/// crashing the app, allowing the splash placeholder to render. Once real
/// credentials are in place, initialization will succeed unchanged.
class FirebaseService {
  const FirebaseService._();

  static bool _initialized = false;
  static bool get isInitialized => _initialized;

  static Future<void> initialize() async {
    if (_initialized) return;
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _initialized = true;
      AppLogger.info('Firebase initialized.');
    } catch (error, stackTrace) {
      // Expected until real Firebase options are provided.
      AppLogger.warning(
        'Firebase not initialized (placeholder config in use): $error',
      );
      AppLogger.debug(stackTrace);
    }
  }
}
