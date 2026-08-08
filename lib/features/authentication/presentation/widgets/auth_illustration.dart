import 'package:flutter/material.dart';

import 'auth_style.dart';

/// The LifeReset wordmark: a folded two-tone heart + "Life" / "Reset" lockup,
/// matching the Figma header.
class AuthLogo extends StatelessWidget {
  const AuthLogo({super.key, this.fontSize = 30});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final heart = fontSize * 1.16;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: heart,
          height: heart,
          child: const CustomPaint(painter: _HeartLogoPainter()),
        ),
        SizedBox(width: fontSize * 0.3),
        Text.rich(
          TextSpan(
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
            children: const [
              TextSpan(text: 'Life', style: TextStyle(color: AuthStyle.ink)),
              TextSpan(text: 'Reset', style: TextStyle(color: AuthStyle.accent)),
            ],
          ),
        ),
      ],
    );
  }
}

/// A stylised "folded paper" heart: a darker left panel and a lighter right
/// panel divided by a soft centre crease.
class _HeartLogoPainter extends CustomPainter {
  const _HeartLogoPainter();

  static const _leftPanel = Color(0xFF6D28FF);
  static const _rightPanel = Color(0xFF9B6BFF);
  static const _crease = Color(0xFF5B21C7);

  Path _heart(Size size) {
    final w = size.width;
    final h = size.height;
    return Path()
      ..moveTo(w * 0.5, h * 0.30)
      ..cubicTo(w * 0.42, h * 0.10, w * 0.08, h * 0.12, w * 0.06, h * 0.38)
      ..cubicTo(w * 0.045, h * 0.58, w * 0.26, h * 0.74, w * 0.5, h * 0.94)
      ..cubicTo(w * 0.74, h * 0.74, w * 0.955, h * 0.58, w * 0.94, h * 0.38)
      ..cubicTo(w * 0.92, h * 0.12, w * 0.58, h * 0.10, w * 0.5, h * 0.30)
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path = _heart(size);

    // Left (darker) panel.
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, w * 0.5, h));
    canvas.drawPath(path, Paint()..color = _leftPanel);
    canvas.restore();

    // Right (lighter) panel.
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(w * 0.5, 0, w * 0.5, h));
    canvas.drawPath(path, Paint()..color = _rightPanel);
    canvas.restore();

    // Soft centre crease so it reads as a folded shape.
    canvas.save();
    canvas.clipPath(path);
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.5, h * 0.30)
        ..lineTo(w * 0.5, h * 0.94)
        ..lineTo(w * 0.4, h * 0.6)
        ..close(),
      Paint()..color = _crease.withValues(alpha: 0.45),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// A calm sunrise-over-mountains hero matching the onboarding artwork.
///
/// Painted with layered ridges, atmospheric haze, a glowing sun and a hooded
/// figure meditating on a ledge — using the brand purples so it reads as part
/// of the LifeReset identity. The sky top matches [AuthStyle.pageTop] so the
/// image blends seamlessly with the lavender header above it.
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
        alignment: Alignment.bottomCenter,
        errorBuilder: (context, error, stackTrace) =>
            SunriseIllustration(height: height),
      ),
    );
  }
}

class _SunrisePainter extends CustomPainter {
  // Palette — a light, airy purple sunrise that blends into the lavender
  // header (sky top == AuthStyle.pageTop).
  static const _skyTop = Color(0xFFEDE7F9);
  static const _skyMid = Color(0xFFE7DDF4);
  static const _skyHorizon = Color(0xFFF6EBDD);
  static const _cloud = Color(0xFFF3ECFA);

  static const _l1 = Color(0xFFD9CDEE); // farthest ridge
  static const _l2 = Color(0xFFC4B4E6);
  static const _l3 = Color(0xFFAB98DC);
  static const _l4 = Color(0xFF8B72C9);
  static const _l5 = Color(0xFF6A52A8); // nearest slope
  static const _rock = Color(0xFF463A72);
  static const _figure = Color(0xFF2C2450);

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
          stops: [0.0, 0.5, 1.0],
        ).createShader(rect),
    );

    // ── Sun glow + disc (centred, on the horizon) ──
    final sunCenter = Offset(w * 0.53, h * 0.62);
    canvas.drawCircle(
      sunCenter,
      h * 0.85,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.95),
            const Color(0xFFF7E7C4).withValues(alpha: 0.45),
            Colors.white.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.32, 1.0],
        ).createShader(Rect.fromCircle(center: sunCenter, radius: h * 0.85)),
    );
    canvas.drawCircle(sunCenter, h * 0.1,
        Paint()..color = const Color(0xFFFFFBF2).withValues(alpha: 0.96));

    // ── Soft wispy clouds ──
    for (final c in [
      [0.2, 0.16, 0.34, 0.05, 0.5],
      [0.8, 0.13, 0.3, 0.045, 0.5],
      [0.56, 0.24, 0.24, 0.04, 0.4],
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

    // ── Mountain layers (far → near) with atmospheric haze between them ──
    _ridge(canvas, size, const [
      [0.0, 0.52], [0.16, 0.42], [0.3, 0.5], [0.46, 0.38],
      [0.62, 0.48], [0.78, 0.4], [0.9, 0.48], [1.0, 0.44],
    ], _l1, _l1.withValues(alpha: 0.9));
    _haze(canvas, size, 0.52, 0.16, 0.5);

    _ridge(canvas, size, const [
      [0.0, 0.64], [0.14, 0.54], [0.28, 0.62], [0.42, 0.48],
      [0.58, 0.6], [0.74, 0.5], [0.88, 0.6], [1.0, 0.54],
    ], _l2, const Color(0xFFB8A6E0));
    _haze(canvas, size, 0.62, 0.14, 0.42);

    _ridge(canvas, size, const [
      [0.0, 0.76], [0.2, 0.6], [0.36, 0.72], [0.5, 0.62],
      [0.66, 0.74], [0.82, 0.62], [1.0, 0.72],
    ], _l3, const Color(0xFF9C88CF));
    _haze(canvas, size, 0.74, 0.12, 0.36);

    // Warm valley light gathering below the sun.
    final glowBand = Rect.fromLTWH(0, h * 0.56, w, h * 0.24);
    canvas.drawRect(
      glowBand,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0.06, -0.4),
          radius: 1.0,
          colors: [
            const Color(0xFFF6E7C8).withValues(alpha: 0.42),
            const Color(0xFFF6E7C8).withValues(alpha: 0.0),
          ],
        ).createShader(glowBand),
    );

    _ridge(canvas, size, const [
      [0.0, 0.92], [0.22, 0.74], [0.4, 0.88], [0.5, 0.8],
      [0.6, 0.88], [0.78, 0.72], [1.0, 0.88],
    ], _l4, const Color(0xFF7A61BC));

    // A cluster of small pines along the near-right slope.
    final treePaint = Paint()..color = const Color(0xFF5B4B93);
    for (var i = 0; i < 9; i++) {
      final tx = w * (0.66 + i * 0.037);
      final ty = h * (0.85 - i * 0.006);
      final ts = h * (0.038 - i * 0.0015);
      canvas.drawPath(
        Path()
          ..moveTo(tx, ty - ts)
          ..lineTo(tx - ts * 0.42, ty)
          ..lineTo(tx + ts * 0.42, ty)
          ..close(),
        treePaint,
      );
    }

    // ── Foreground ledge (left) the figure sits on ──
    final ledge = Path()
      ..moveTo(0, h)
      ..lineTo(0, h * 0.8)
      ..cubicTo(w * 0.12, h * 0.78, w * 0.24, h * 0.84, w * 0.36, h * 0.98)
      ..lineTo(w * 0.36, h)
      ..close();
    canvas.drawPath(ledge, Paint()..color = _l5);
    canvas.drawPath(
      Path()
        ..moveTo(0, h)
        ..lineTo(0, h * 0.88)
        ..cubicTo(w * 0.09, h * 0.87, w * 0.22, h * 0.92, w * 0.32, h)
        ..close(),
      Paint()..color = _rock,
    );

    // ── Hooded figure meditating on the ledge ──
    _figureOnLedge(
        canvas, Rect.fromLTWH(w * 0.09, h * 0.55, w * 0.2, h * 0.32));

    // ── Birds ──
    final bird = Paint()
      ..color = const Color(0xFF6A5AA3).withValues(alpha: 0.7)
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

    drawBird(w * 0.78, h * 0.24, 11);
    drawBird(w * 0.85, h * 0.3, 8);
    drawBird(w * 0.72, h * 0.31, 7);
    drawBird(w * 0.82, h * 0.38, 6);
  }

  /// Draws a closed ridge from normalized [points] with a subtle vertical
  /// gradient (top catches the light).
  void _ridge(Canvas canvas, Size size, List<List<double>> points, Color top,
      Color bottom) {
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
  void _haze(Canvas canvas, Size size, double yFrac, double heightFrac,
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

  /// A person seen from behind, sitting cross-legged in meditation: a wide low
  /// lap, a torso tapering up to hooded shoulders, and a rounded hooded head,
  /// with a soft warm rim light on the sun-facing side of the head.
  void _figureOnLedge(Canvas canvas, Rect box) {
    final cx = box.center.dx;
    final w = box.width;
    final h = box.height;
    final baseY = box.bottom;
    final paint = Paint()..color = _figure;

    // Crossed legs / lap — a wide, low rounded base.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(cx, baseY - h * 0.05),
            width: w * 1.02,
            height: h * 0.16),
        Radius.circular(h * 0.075),
      ),
      paint,
    );

    // Torso tapering up from the hips to the hooded shoulders.
    final body = Path()
      ..moveTo(cx - w * 0.37, baseY - h * 0.09)
      ..cubicTo(cx - w * 0.35, baseY - h * 0.4, cx - w * 0.24,
          baseY - h * 0.56, cx - w * 0.12, baseY - h * 0.62)
      ..cubicTo(cx - w * 0.06, baseY - h * 0.65, cx + w * 0.06,
          baseY - h * 0.65, cx + w * 0.12, baseY - h * 0.62)
      ..cubicTo(cx + w * 0.24, baseY - h * 0.56, cx + w * 0.35,
          baseY - h * 0.4, cx + w * 0.37, baseY - h * 0.09)
      ..close();
    canvas.drawPath(body, paint);

    // Hooded head — a larger circle set into the shoulders (reads as one hood).
    final headCenter = Offset(cx, baseY - h * 0.72);
    canvas.drawCircle(headCenter, h * 0.17, paint);

    // Soft warm rim light hugging the sun-facing (right) side of the head.
    canvas.drawArc(
      Rect.fromCircle(center: headCenter, radius: h * 0.17),
      -1.15, // ~-66°
      1.5, // ~86° sweep down the right edge
      false,
      Paint()
        ..color = const Color(0xFFF3E3C8).withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
