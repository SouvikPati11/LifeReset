import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Holds the app's [ThemeMode].
///
/// LifeReset ships as a **Light-only** experience: the app never follows the
/// device's system dark mode and exposes no dark/system switch. The mode is
/// therefore pinned to [ThemeMode.light]; [setThemeMode] is retained as a
/// no-op so existing callers stay valid but can never move the app off Light.
class ThemeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.light;

  /// Intentionally a no-op — appearance is fixed to Light.
  void setThemeMode(ThemeMode mode) {}
}

final themeControllerProvider =
    NotifierProvider<ThemeController, ThemeMode>(ThemeController.new);
