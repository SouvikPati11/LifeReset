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

/// A calm sunrise-over-mountains hero matching the onboarding artwork.
///
/// Painted with layered ridges, atmospheric fog, a glowing sun and a hooded
/// figure meditating on a ledge — using the brand purples so it reads as part
/// of the LifeReset identity. [borderRadius] lets the caller round the corners
/// (0 = full-bleed, so the form sheet can overlap it).
class SunriseIllustration extends StatelessWidget {
  const SunriseIllustration({
    super.key,
    this.height = 240,
    this.borderRadius = 0,
  });

  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final painter = CustomPaint(
      size: Size.infinite,
      painter: _SunrisePainter(),
    );
    return SizedBox(
      height: height,
      width: double.infinity,
      child: borderRadius == 0
          ? painter
          : ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: painter,
            ),
    );
  }
}

/// The login hero. Loads the bundled illustration asset
/// (`assets/auth/hero_login.webp`) and falls back to [SunriseIllustration]
/// (the CustomPainter) only if the asset can't be decoded, so the screen is
/// never blank.
class AuthHeroImage extends StatelessWidget {
  const AuthHeroImage({
    super.key,
    required this.height,
    this.asset = 'assets/auth/hero_login.webp',
  });

  final double height;
  final String asset;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Image.asset(
        asset,
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
        errorBuilder: (context, error, stackTrace) =>
            SunriseIllustration(height: height),
      ),
    );
  }
}

class _SunrisePainter extends CustomPainter {
  // Palette (a warm purple sunrise).
  static const _skyTop = Color(0xFFAC98DF);
  static const _skyMid = Color(0xFFCBB9EE);
  static const _skyHorizon = Color(0xFFF2E6D9);
  static const _cloud = Color(0xFFE8DAF4);

  static const _l1 = Color(0xFFC6B7E8); // farthest
  static const _l2 = Color(0xFFB0A0DE);
  static const _l3 = Color(0xFF9581CE);
  static const _l4 = Color(0xFF735FBB);
  static const _l5 = Color(0xFF52427F); // nearest slope
  static const _rock = Color(0xFF322A55);
  static const _figure = Color(0xFF231B40);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final rect = Offset.zero & size;

    // ── Sky ──
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_skyTop, _skyMid, _skyHorizon],
          stops: [0.0, 0.55, 1.0],
        ).createShader(rect),
    );

    // ── Sun ──
    final sunCenter = Offset(w * 0.52, h * 0.6);
    canvas.drawCircle(
      sunCenter,
      h * 0.7,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.95),
            const Color(0xFFF7E7C4).withValues(alpha: 0.5),
            Colors.white.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.3, 1.0],
        ).createShader(Rect.fromCircle(center: sunCenter, radius: h * 0.7)),
    );
    canvas.drawCircle(sunCenter, h * 0.11,
        Paint()..color = const Color(0xFFFFFBF2).withValues(alpha: 0.95));

    // ── Soft wispy clouds ──
    for (final c in [
      [0.2, 0.15, 0.34, 0.05, 0.16],
      [0.78, 0.12, 0.3, 0.045, 0.16],
      [0.55, 0.22, 0.26, 0.04, 0.11],
    ]) {
      final cp = Paint()..color = _cloud.withValues(alpha: c[4]);
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(w * c[0], h * c[1]),
            width: w * c[2],
            height: h * c[3]),
        cp,
      );
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(w * (c[0] + 0.04), h * (c[1] + 0.025)),
            width: w * c[2] * 0.6,
            height: h * c[3] * 0.75),
        cp,
      );
    }

    // ── Mountain layers (far → near) with atmospheric fog between them ──
    _ridge(canvas, size, const [
      [0.0, 0.5], [0.16, 0.4], [0.3, 0.48], [0.46, 0.36],
      [0.62, 0.46], [0.78, 0.38], [0.9, 0.46], [1.0, 0.42],
    ], _l1, _l1.withValues(alpha: 0.85));
    _fog(canvas, size, 0.5, 0.16, 0.5);

    _ridge(canvas, size, const [
      [0.0, 0.62], [0.14, 0.52], [0.28, 0.6], [0.42, 0.46],
      [0.58, 0.58], [0.74, 0.48], [0.88, 0.58], [1.0, 0.52],
    ], _l2, const Color(0xFF9F8ED4));
    _fog(canvas, size, 0.6, 0.14, 0.42);

    _ridge(canvas, size, const [
      [0.0, 0.74], [0.2, 0.58], [0.36, 0.7], [0.5, 0.6],
      [0.66, 0.72], [0.82, 0.6], [1.0, 0.7],
    ], _l3, const Color(0xFF7E6ABB));
    _fog(canvas, size, 0.72, 0.12, 0.35);

    // Warm light settling into the mid-ground below the sun (soft, no hard
    // edges — reads as sunlight filling the valley).
    final glowBand = Rect.fromLTWH(0, h * 0.55, w, h * 0.22);
    canvas.drawRect(
      glowBand,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0.04, -0.4),
          radius: 1.0,
          colors: [
            const Color(0xFFF6E7C8).withValues(alpha: 0.4),
            const Color(0xFFF6E7C8).withValues(alpha: 0.0),
          ],
        ).createShader(glowBand),
    );

    _ridge(canvas, size, const [
      [0.0, 0.9], [0.22, 0.72], [0.4, 0.86], [0.5, 0.78],
      [0.6, 0.86], [0.78, 0.7], [1.0, 0.86],
    ], _l4, const Color(0xFF5F4CA2));

    // A cluster of small pines along the near-right slope for detail.
    final treePaint = Paint()..color = const Color(0xFF473B79);
    for (var i = 0; i < 9; i++) {
      final tx = w * (0.66 + i * 0.037);
      final ty = h * (0.83 - i * 0.006);
      final ts = h * (0.035 - i * 0.0015);
      canvas.drawPath(
        Path()
          ..moveTo(tx, ty - ts)
          ..lineTo(tx - ts * 0.42, ty)
          ..lineTo(tx + ts * 0.42, ty)
          ..close(),
        treePaint,
      );
    }

    // ── Foreground ledge (left) ──
    final ledge = Path()
      ..moveTo(0, h)
      ..lineTo(0, h * 0.78)
      ..cubicTo(w * 0.1, h * 0.76, w * 0.22, h * 0.82, w * 0.34, h * 0.95)
      ..lineTo(w * 0.34, h)
      ..close();
    canvas.drawPath(ledge, Paint()..color = _l5);
    canvas.drawPath(
      Path()
        ..moveTo(0, h)
        ..lineTo(0, h * 0.86)
        ..cubicTo(w * 0.08, h * 0.85, w * 0.2, h * 0.9, w * 0.3, h)
        ..close(),
      Paint()..color = _rock,
    );

    // ── Hooded figure meditating on the ledge ──
    _figureOnLedge(canvas, Rect.fromLTWH(w * 0.07, h * 0.6, w * 0.2, h * 0.26));

    // ── Birds ──
    final bird = Paint()
      ..color = const Color(0xFF5A4A93).withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    void drawBird(double cx, double cy, double s) {
      canvas.drawPath(
        Path()
          ..moveTo(cx - s, cy)
          ..quadraticBezierTo(cx - s * 0.35, cy - s * 0.7, cx, cy)
          ..quadraticBezierTo(cx + s * 0.35, cy - s * 0.7, cx + s, cy),
        bird,
      );
    }

    drawBird(w * 0.76, h * 0.26, 10);
    drawBird(w * 0.83, h * 0.32, 8);
    drawBird(w * 0.7, h * 0.33, 7);
    drawBird(w * 0.8, h * 0.4, 6);
  }

  /// Draws a closed ridge from normalized [points] with a subtle vertical
  /// gradient (top catches the light).
  void _ridge(Canvas canvas, Size size, List<List<double>> points,
      Color top, Color bottom) {
    final w = size.width;
    final h = size.height;
    final path = Path()..moveTo(0, h);
    path.lineTo(points.first[0] * w, points.first[1] * h);
    for (final p in points.skip(1)) {
      path.lineTo(p[0] * w, p[1] * h);
    }
    path.lineTo(w, h);
    path.close();
    final topY = points.map((p) => p[1]).reduce((a, b) => a < b ? a : b) * h;
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [top, bottom],
        ).createShader(Rect.fromLTWH(0, topY, w, h - topY)),
    );
  }

  /// A horizontal haze band centered at [yFrac] with [heightFrac] thickness.
  void _fog(Canvas canvas, Size size, double yFrac, double heightFrac,
      double alpha) {
    final w = size.width;
    final h = size.height;
    final r = Rect.fromLTWH(0, h * (yFrac - heightFrac / 2), w, h * heightFrac);
    canvas.drawRect(
      r,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.0),
            Colors.white.withValues(alpha: alpha),
            Colors.white.withValues(alpha: 0.0),
          ],
        ).createShader(r),
    );
  }

  void _figureOnLedge(Canvas canvas, Rect box) {
    final cx = box.center.dx;
    final w = box.width;
    final h = box.height;
    final baseY = box.bottom;
    final paint = Paint()..color = _figure;

    // Crossed-legs base: a compact rounded mound with two subtle knee bumps.
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(cx, baseY - h * 0.05),
          width: w * 0.92,
          height: h * 0.22),
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(cx - w * 0.3, baseY - h * 0.02),
          width: w * 0.34,
          height: h * 0.15),
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(cx + w * 0.3, baseY - h * 0.02),
          width: w * 0.34,
          height: h * 0.15),
      paint,
    );

    // Hooded torso + head from behind: broad rounded shoulders, rounded hood.
    final body = Path()
      ..moveTo(cx - w * 0.5, baseY - h * 0.16)
      ..cubicTo(cx - w * 0.58, baseY - h * 0.48, cx - w * 0.4, baseY - h * 0.72,
          cx - w * 0.15, baseY - h * 0.78)
      ..cubicTo(cx - w * 0.04, baseY - h * 0.81, cx + w * 0.04, baseY - h * 0.81,
          cx + w * 0.15, baseY - h * 0.78)
      ..cubicTo(cx + w * 0.4, baseY - h * 0.72, cx + w * 0.58, baseY - h * 0.48,
          cx + w * 0.5, baseY - h * 0.16)
      ..cubicTo(cx + w * 0.3, baseY - h * 0.26, cx - w * 0.3, baseY - h * 0.26,
          cx - w * 0.5, baseY - h * 0.16)
      ..close();
    canvas.drawPath(body, paint);

    // Rim light on the sun-facing (right) edge.
    canvas.drawPath(
      Path()
        ..moveTo(cx + w * 0.06, baseY - h * 0.8)
        ..cubicTo(cx + w * 0.4, baseY - h * 0.7, cx + w * 0.56,
            baseY - h * 0.44, cx + w * 0.5, baseY - h * 0.2),
      Paint()
        ..color = const Color(0xFFF3E3C8).withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
