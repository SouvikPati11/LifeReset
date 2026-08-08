import 'package:flutter/material.dart';

/// Local visual identity for the auth screens (login / register).
///
/// The app's global Material theme is intentionally left untouched. The auth
/// surfaces always render with this **fixed light palette** so they match the
/// approved Figma design regardless of the device's theme brightness (this is
/// why the login card no longer turns dark on a dark-mode device).
class AuthStyle {
  const AuthStyle._();

  // ── Brand purple ─────────────────────────────────────────────────────────
  static const Color purpleStart = Color(0xFF6D28FF);
  static const Color purpleEnd = Color(0xFF8B5CF6);
  static const Color accent = Color(0xFF7C3AED);

  /// The gradient used on the primary CTA (left → right).
  static const LinearGradient gradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [purpleStart, purpleEnd],
  );

  // ── Fixed light palette (matches the Figma mockup) ────────────────────────
  /// Lavender tint behind the logo / hero at the top of the login screen.
  static const Color pageTop = Color(0xFFEDE7F9);
  static const Color pageBottom = Color(0xFFF8F5FE);
  static const Color surface = Color(0xFFFFFFFF); // white card + inputs
  static const Color ink = Color(0xFF1A1B2E); // headings
  static const Color labelInk = Color(0xFF2A2B3C); // field labels
  static const Color bodyGray = Color(0xFF6B7280); // subtitles / muted text
  static const Color placeholder = Color(0xFF9AA0AC); // input hints
  static const Color fieldBorder = Color(0xFFE6E4F0); // input outline
  static const Color divider = Color(0xFFE6E4F0);
  static const Color iconMuted = Color(0xFF6B7280); // eye / neutral icons
  static const Color strongGreen = Color(0xFF22C55E);

  /// Soft top-to-bottom lavender background for the auth pages.
  static const LinearGradient pageGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [pageTop, pageBottom],
  );

  // ── Dimensions (from the mockup) ──────────────────────────────────────────
  static const double fieldHeight = 58;
  static const double fieldRadius = 14;
  static const double buttonHeight = 58;
  static const double buttonRadius = 14;
  static const double cardRadius = 32;
  static const double radiusPill = 999;

  // 8px spacing grid.
  static const double s8 = 8;
  static const double s12 = 12;
  static const double s16 = 16;
  static const double s20 = 20;
  static const double s24 = 24;
  static const double s28 = 28;
  static const double s32 = 32;
  static const double s40 = 40;

  static List<BoxShadow> get buttonShadow => [
        BoxShadow(
          color: purpleStart.withValues(alpha: 0.32),
          blurRadius: 24,
          offset: const Offset(0, 12),
        ),
      ];

  /// Soft upward shadow for the white form card overlapping the hero.
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: const Color(0xFF6D28FF).withValues(alpha: 0.06),
          blurRadius: 24,
          offset: const Offset(0, -8),
        ),
      ];

  // ── Typography ────────────────────────────────────────────────────────────
  static const TextStyle title = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w800,
    height: 1.15,
    letterSpacing: -0.5,
    color: ink,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.3,
    color: bodyGray,
  );

  static const TextStyle label = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: labelInk,
  );

  static const TextStyle input = TextStyle(fontSize: 16, color: ink);

  static const TextStyle button = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  static const TextStyle link = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: accent,
  );

  static const TextStyle muted = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: bodyGray,
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
