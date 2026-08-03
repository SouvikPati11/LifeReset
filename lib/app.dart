import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_constants.dart';
import 'core/localization/locale_controller.dart';
import 'features/notifications/presentation/widgets/notifications_initializer.dart';
import 'generated/l10n/app_localizations.dart';
import 'routing/app_router.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';

/// Root application widget.
///
/// Wires together the router, Material 3 light/dark themes and localization.
/// All app-level state (theme mode, locale, router) is sourced from Riverpod
/// providers so the widget itself stays declarative.
class LifeResetApp extends ConsumerWidget {
  const LifeResetApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeControllerProvider);
    final locale = ref.watch(localeControllerProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      routerConfig: router,

      // Wire push notifications once, app-wide: requests permission, registers
      // the FCM token, and surfaces foreground messages. The inbox itself is
      // read from Firestore, so this needs no Cloud Functions to run.
      builder: (context, child) =>
          NotificationsInitializer(child: child ?? const SizedBox.shrink()),

      // Theming (Material 3).
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,

      // Localization.
      locale: locale,
      supportedLocales: supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
