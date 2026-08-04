import 'package:flutter/material.dart';

/// Local visual identity for the auth screens (login / register).
///
/// The app's global Material theme is intentionally left untouched; these
/// purple brand tokens are applied only within the authentication surfaces so
/// they match the LifeReset onboarding look without changing the rest of the
/// app.
class AuthStyle {
  const AuthStyle._();

  // Brand purple gradient (#6D28FF → #8B5CF6).
  static const Color purpleStart = Color(0xFF6D28FF);
  static const Color purpleEnd = Color(0xFF8B5CF6);
  static const Color accent = Color(0xFF6D28FF);

  static const LinearGradient gradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [purpleStart, purpleEnd],
  );

  // Component dimensions from the design spec.
  static const double fieldHeight = 56;
  static const double fieldRadius = 18;
  static const double buttonHeight = 56;
  static const double buttonRadius = 20;
  static const double cardRadius = 24;
  static const double radiusPill = 999;

  // 8px spacing grid.
  static const double s8 = 8;
  static const double s12 = 12;
  static const double s16 = 16;
  static const double s24 = 24;
  static const double s32 = 32;
  static const double s40 = 40;

  /// The soft page background (a subtle lavender tint over the theme surface).
  static Color pageBackground(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    return Color.alphaBlend(purpleEnd.withValues(alpha: 0.05), surface);
  }

  /// Card / input surface — white in light mode, theme surface in dark mode.
  static Color cardSurface(BuildContext context) =>
      Theme.of(context).colorScheme.surface;

  static List<BoxShadow> softShadow(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: dark ? 0.35 : 0.06),
        blurRadius: 24,
        offset: const Offset(0, 12),
      ),
    ];
  }

  static List<BoxShadow> buttonShadow(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: purpleStart.withValues(alpha: dark ? 0.35 : 0.30),
        blurRadius: 20,
        offset: const Offset(0, 10),
      ),
    ];
  }

  // Typography (Title 34 Bold, Subtitle 16 Medium, Label 14 Medium,
  // Input 16, Button 18 SemiBold).
  static TextStyle title(BuildContext context) => TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        height: 1.1,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle subtitle(BuildContext context) => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      );

  static TextStyle label(BuildContext context) => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static const TextStyle input = TextStyle(fontSize: 16);

  static const TextStyle button = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}

/// A staggered slide-up + fade entrance used for the auth form rows.
class SlideFadeIn extends StatefulWidget {
  const SlideFadeIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 450),
    this.offset = 24,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final double offset;

  @override
  State<SlideFadeIn> createState() => _SlideFadeInState();
}

class _SlideFadeInState extends State<SlideFadeIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: widget.duration);
  late final Animation<double> _curve =
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);

  @override
  void initState() {
    super.initState();
    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future<void>.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curve,
      builder: (context, child) {
        return Opacity(
          opacity: _curve.value,
          child: Transform.translate(
            offset: Offset(0, widget.offset * (1 - _curve.value)),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
