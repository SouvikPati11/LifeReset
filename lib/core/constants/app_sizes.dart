/// Spacing, radius and breakpoint constants for a consistent layout system.
class AppSizes {
  const AppSizes._();

  // Spacing scale (4pt grid).
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  // Corner radii.
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 20;
  static const double radiusPill = 999;

  // Component sizing.
  static const double buttonHeight = 52;
  static const double iconSm = 18;
  static const double iconMd = 24;
  static const double iconLg = 32;

  // Responsive breakpoints (logical pixels).
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
  static const double maxContentWidth = 1200;
}
