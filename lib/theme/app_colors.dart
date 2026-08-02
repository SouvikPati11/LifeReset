import 'package:flutter/material.dart';

/// Brand color palette for LifeReset.
///
/// The Material 3 [ColorScheme]s in [AppTheme] are seeded from [primary]. A few
/// explicit brand and semantic colors are exposed here for use in bespoke UI
/// (e.g. gradients, status indicators) where a seeded role is not appropriate.
class AppColors {
  const AppColors._();

  /// Primary brand color — a calm, restorative teal-green.
  static const Color primary = Color(0xFF2E7D6B);
  static const Color primaryDark = Color(0xFF1B5E52);
  static const Color secondary = Color(0xFFF2A65A);
  static const Color tertiary = Color(0xFF6C7BD6);

  // Semantic colors.
  static const Color success = Color(0xFF2E9E63);
  static const Color warning = Color(0xFFE0A800);
  static const Color error = Color(0xFFC0392B);
  static const Color info = Color(0xFF2E86DE);

  // Neutral surfaces used by the splash / branded backgrounds.
  static const Color lightBackground = Color(0xFFF7FAF9);
  static const Color darkBackground = Color(0xFF0F1513);

  /// Brand gradient used on the splash and hero surfaces.
  static const List<Color> brandGradient = [primary, primaryDark];
}
