import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Holds the app's active [Locale].
///
/// A `null` state means "follow the device locale". Persistence will be added
/// alongside the storage service; the controller API is stable so that change
/// stays invisible to the UI.
class LocaleController extends Notifier<Locale?> {
  @override
  Locale? build() => null;

  void setLocale(Locale locale) => state = locale;

  void useSystemLocale() => state = null;
}

final localeControllerProvider =
    NotifierProvider<LocaleController, Locale?>(LocaleController.new);

/// Locales the app ships translations for. Keep in sync with the `.arb` files
/// under `lib/l10n/`.
const List<Locale> supportedLocales = [
  Locale('en'),
  Locale('es'),
];
