import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'config/app_config.dart';
import 'config/config_providers.dart';
import 'core/utils/app_logger.dart';
import 'shared/services/firebase_service.dart';

/// Application entry point.
///
/// Bootstraps configuration and Firebase inside a guarded zone so any startup
/// error is logged rather than silently lost, then runs the app with the
/// resolved [AppConfig] injected into the Riverpod graph.
Future<void> main() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      final config = AppConfig.fromEnvironment();
      AppLogger.info('Starting LifeReset (${config.environment.name}).');

      // Placeholder config in the foundation build; safely no-ops on failure.
      await FirebaseService.initialize();

      runApp(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(config),
          ],
          child: const LifeResetApp(),
        ),
      );
    },
    (error, stackTrace) {
      AppLogger.error('Uncaught zone error', error, stackTrace);
    },
  );
}
