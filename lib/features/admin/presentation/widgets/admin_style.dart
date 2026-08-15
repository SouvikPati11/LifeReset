import 'package:flutter/material.dart';

import '../../../home/presentation/widgets/home_style.dart';

/// Purple SaaS theming for the Admin Panel, layered on the shared [HomeStyle]
/// tokens used across the user app.
///
/// Wrapping the admin shell in [AdminStyle.theme] recolours every existing
/// admin view — which reads `Theme.of(context).colorScheme` — to the purple
/// palette in one place, without editing each view or the shared widgets.
class AdminStyle {
  const AdminStyle._();

  static const Color sidebarBg = HomeStyle.card;
  static const Color canvas = HomeStyle.background;

  static const double sidebarWidth = 264;
  static const double railWidth = 76;

  /// The purple-seeded Material theme applied to the whole admin surface.
  static ThemeData theme() {
    final scheme = ColorScheme.fromSeed(
      seedColor: HomeStyle.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: HomeStyle.primary,
      onPrimary: Colors.white,
      primaryContainer: HomeStyle.lavender,
      onPrimaryContainer: HomeStyle.primaryDeep,
      secondary: HomeStyle.primarySoft,
      tertiary: HomeStyle.success,
      surface: HomeStyle.card,
      surfaceContainerLowest: HomeStyle.lavenderLight,
      surfaceContainerLow: HomeStyle.card,
      onSurface: HomeStyle.ink,
      onSurfaceVariant: HomeStyle.inkSoft,
      outline: HomeStyle.border,
      outlineVariant: HomeStyle.border,
    );
    final base = ThemeData(useMaterial3: true, colorScheme: scheme);
    return base.copyWith(
      scaffoldBackgroundColor: canvas,
      textTheme: base.textTheme.apply(
        bodyColor: HomeStyle.ink,
        displayColor: HomeStyle.ink,
      ),
    );
  }
}
