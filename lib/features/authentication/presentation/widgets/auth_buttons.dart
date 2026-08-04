import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'auth_style.dart';

/// The primary purple-gradient CTA: 56 high, radius 20, soft shadow, a
/// press-scale animation, an ink ripple, and a built-in loading state. Shows a
/// trailing arrow when idle.
class AuthGradientButton extends StatefulWidget {
  const AuthGradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  State<AuthGradientButton> createState() => _AuthGradientButtonState();
}

class _AuthGradientButtonState extends State<AuthGradientButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null && !widget.isLoading;

    return AnimatedScale(
      scale: _pressed ? 0.97 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: AnimatedOpacity(
        opacity: enabled ? 1 : 0.6,
        duration: const Duration(milliseconds: 200),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: AuthStyle.gradient,
            borderRadius: BorderRadius.circular(AuthStyle.buttonRadius),
            boxShadow: enabled ? AuthStyle.buttonShadow(context) : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(AuthStyle.buttonRadius),
              onTap: enabled ? widget.onPressed : null,
              onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
              onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
              onTapCancel:
                  enabled ? () => setState(() => _pressed = false) : null,
              child: SizedBox(
                height: AuthStyle.buttonHeight,
                child: Center(
                  child: widget.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(widget.label, style: AuthStyle.button),
                            const SizedBox(width: AuthStyle.s8),
                            const Icon(Icons.arrow_forward_rounded,
                                color: Colors.white, size: 20),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The white "Continue with Google" button — 56 high, soft border, ink ripple,
/// and a recognizable multi-colour Google "G".
class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({
    super.key,
    required this.onPressed,
    this.label = 'Continue with Google',
  });

  final VoidCallback? onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: AuthStyle.cardSurface(context),
      borderRadius: BorderRadius.circular(AuthStyle.fieldRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(AuthStyle.fieldRadius),
        onTap: onPressed,
        child: Container(
          height: AuthStyle.buttonHeight,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AuthStyle.fieldRadius),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CustomPaint(painter: _GoogleGPainter()),
              ),
              const SizedBox(width: AuthStyle.s12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Draws the four-colour Google "G".
class _GoogleGPainter extends CustomPainter {
  const _GoogleGPainter();

  static const _blue = Color(0xFF4285F4);
  static const _red = Color(0xFFEA4335);
  static const _yellow = Color(0xFFFBBC05);
  static const _green = Color(0xFF34A853);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    final stroke = radius * 0.42;
    final rect = Rect.fromCircle(center: center, radius: radius - stroke / 2);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;

    // Ring arcs (red top, yellow left, green bottom, blue right).
    canvas.drawArc(rect, _deg(-45), _deg(-115), false, paint..color = _red);
    canvas.drawArc(rect, _deg(-160), _deg(-70), false, paint..color = _yellow);
    canvas.drawArc(rect, _deg(130), _deg(70), false, paint..color = _green);
    canvas.drawArc(rect, _deg(50), _deg(80), false, paint..color = _blue);

    // The horizontal blue bar of the "G".
    final barPaint = Paint()..color = _blue;
    canvas.drawRect(
      Rect.fromLTRB(center.dx, center.dy - stroke / 2,
          center.dx + radius, center.dy + stroke / 2),
      barPaint,
    );
  }

  double _deg(double d) => d * math.pi / 180;

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// A labelled divider ("──── OR CONTINUE WITH ────").
class AuthOrDivider extends StatelessWidget {
  const AuthOrDivider({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(child: Divider(color: colorScheme.outlineVariant)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AuthStyle.s16),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(child: Divider(color: colorScheme.outlineVariant)),
      ],
    );
  }
}
