import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Holds the user's selected [ThemeMode].
///
/// Defaults to [ThemeMode.system]. Persistence (reading/writing the choice from
/// local storage) will be wired in once the storage service is implemented;
/// the controller API is intentionally stable so that change is transparent to
/// the UI.
class ThemeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;

  void setThemeMode(ThemeMode mode) => state = mode;

  void toggle() {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }
}

final themeControllerProvider =
    NotifierProvider<ThemeController, ThemeMode>(ThemeController.new);
