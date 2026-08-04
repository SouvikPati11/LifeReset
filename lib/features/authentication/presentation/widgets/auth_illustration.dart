import 'package:flutter/material.dart';

import 'auth_style.dart';

/// The LifeReset wordmark: a gradient heart + "Life" / "Reset" lockup.
class AuthLogo extends StatelessWidget {
  const AuthLogo({super.key, this.fontSize = 30});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ShaderMask(
          shaderCallback: (rect) => AuthStyle.gradient.createShader(rect),
          child: Icon(Icons.favorite_rounded,
              size: fontSize * 1.15, color: Colors.white),
        ),
        SizedBox(width: fontSize * 0.28),
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
            children: [
              TextSpan(text: 'Life', style: TextStyle(color: onSurface)),
              const TextSpan(
                  text: 'Reset', style: TextStyle(color: AuthStyle.accent)),
            ],
          ),
        ),
      ],
    );
  }
}

/// A calm sunrise-over-mountains illustration matching the onboarding artwork.
///
/// Drawn with a [CustomPainter] (no bundled asset needed), using the brand
/// purples so it reads as part of the LifeReset visual identity.
class SunriseIllustration extends StatelessWidget {
  const SunriseIllustration({super.key, this.height = 200});

  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AuthStyle.cardRadius),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(painter: _SunrisePainter()),
      ),
    );
  }
}

class _SunrisePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final rect = Offset.zero & size;

    // Sky.
    final sky = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFB9A7F5),
          Color(0xFFD9C9FA),
          Color(0xFFF3ECFF),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, sky);

    // Sun glow.
    final sunCenter = Offset(w * 0.5, h * 0.66);
    final glow = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.95),
          const Color(0xFFF7E9C9).withValues(alpha: 0.55),
          Colors.white.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.35, 1.0],
      ).createShader(
          Rect.fromCircle(center: sunCenter, radius: h * 0.55));
    canvas.drawCircle(sunCenter, h * 0.55, glow);
    canvas.drawCircle(sunCenter, h * 0.13,
        Paint()..color = Colors.white.withValues(alpha: 0.95));

    // Birds (soft V strokes).
    final bird = Paint()
      ..color = const Color(0xFF7C5FD0).withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    void drawBird(double cx, double cy, double s) {
      canvas.drawPath(
        Path()
          ..moveTo(cx - s, cy)
          ..quadraticBezierTo(cx - s * 0.4, cy - s * 0.6, cx, cy)
          ..quadraticBezierTo(cx + s * 0.4, cy - s * 0.6, cx + s, cy),
        bird,
      );
    }

    drawBird(w * 0.74, h * 0.24, 9);
    drawBird(w * 0.8, h * 0.32, 7);
    drawBird(w * 0.68, h * 0.3, 6);

    // Distant mountains.
    final back = Paint()..color = const Color(0xFF9F8BE0);
    canvas.drawPath(
      Path()
        ..moveTo(0, h)
        ..lineTo(0, h * 0.62)
        ..lineTo(w * 0.22, h * 0.44)
        ..lineTo(w * 0.42, h * 0.6)
        ..lineTo(w * 0.62, h * 0.4)
        ..lineTo(w * 0.82, h * 0.58)
        ..lineTo(w, h * 0.46)
        ..lineTo(w, h)
        ..close(),
      back,
    );

    // Front mountains.
    final front = Paint()..color = const Color(0xFF6E5AB8);
    canvas.drawPath(
      Path()
        ..moveTo(0, h)
        ..lineTo(0, h * 0.82)
        ..lineTo(w * 0.3, h * 0.6)
        ..lineTo(w * 0.52, h * 0.82)
        ..lineTo(w * 0.74, h * 0.62)
        ..lineTo(w, h * 0.84)
        ..lineTo(w, h)
        ..close(),
      front,
    );

    // Foreground ledge + meditating figure silhouette.
    final ledge = Paint()..color = const Color(0xFF4B3F86);
    canvas.drawPath(
      Path()
        ..moveTo(0, h)
        ..lineTo(0, h * 0.9)
        ..quadraticBezierTo(w * 0.16, h * 0.86, w * 0.34, h * 0.94)
        ..lineTo(w * 0.34, h)
        ..close(),
      ledge,
    );

    final figure = Paint()..color = const Color(0xFF2E2557);
    final fx = w * 0.2;
    final fy = h * 0.88;
    // Body (triangle) + head.
    canvas.drawPath(
      Path()
        ..moveTo(fx, fy)
        ..lineTo(fx - h * 0.06, fy + h * 0.08)
        ..lineTo(fx + h * 0.06, fy + h * 0.08)
        ..close(),
      figure,
    );
    canvas.drawCircle(Offset(fx, fy - h * 0.03), h * 0.032, figure);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
