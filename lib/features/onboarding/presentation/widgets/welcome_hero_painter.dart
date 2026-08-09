import 'package:flutter/material.dart';

/// The onboarding Welcome hero: a calm pastel-purple sunrise with a centred
/// meditating figure, framing mountains, clouds, birds and foreground foliage.
///
/// Loads the bundled `assets/onboarding/hero_welcome.webp` (rendered from
/// [WelcomeHeroPainter]) and falls back to painting it live if the asset can't
/// be decoded, so the hero is never blank.
class WelcomeHero extends StatelessWidget {
  const WelcomeHero({super.key, this.asset = 'assets/onboarding/hero_welcome.webp'});

  final String asset;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Image.asset(
        asset,
        fit: BoxFit.cover,
        alignment: Alignment.bottomCenter,
        errorBuilder: (context, error, stackTrace) => const CustomPaint(
          painter: WelcomeHeroPainter(),
          size: Size.infinite,
        ),
      ),
    );
  }
}

/// Paints the Welcome hero. Composed portrait-first (centred figure, sun behind
/// it) so it fills the middle of the screen rather than leaving a washed-out
/// band. Also used to generate `assets/onboarding/hero_welcome.webp`.
class WelcomeHeroPainter extends CustomPainter {
  const WelcomeHeroPainter();

  // Sky / atmosphere.
  static const _skyTop = Color(0xFFEDE7F9);
  static const _skyMid = Color(0xFFE6DBF4);
  static const _skyHorizon = Color(0xFFF6ECDD);
  static const _cloud = Color(0xFFF4EEFB);

  // Ridge palette (far → near).
  static const _l1 = Color(0xFFD9CDEE);
  static const _l2 = Color(0xFFC6B6E7);
  static const _l3 = Color(0xFFAD9ADD);
  static const _l4 = Color(0xFF8E76CB);
  static const _foreground = Color(0xFF4A3B79);
  static const _figureColor = Color(0xFF2C2450);

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

    // ── Sun glow (behind the figure) ──
    final sunCenter = Offset(w * 0.5, h * 0.42);
    canvas.drawCircle(
      sunCenter,
      w * 0.7,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFDF3D8).withValues(alpha: 0.95),
            const Color(0xFFF6E7C4).withValues(alpha: 0.4),
            Colors.white.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.32, 1.0],
        ).createShader(Rect.fromCircle(center: sunCenter, radius: w * 0.7)),
    );
    canvas.drawCircle(sunCenter, w * 0.11,
        Paint()..color = const Color(0xFFFFF8E8).withValues(alpha: 0.95));

    // ── Wispy clouds ──
    for (final c in [
      [0.2, 0.14, 0.4, 0.04, 0.5],
      [0.82, 0.1, 0.34, 0.035, 0.5],
      [0.6, 0.2, 0.3, 0.03, 0.4],
    ]) {
      final paint = Paint()..color = _cloud.withValues(alpha: c[4]);
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(w * c[0], h * c[1]), width: w * c[2], height: h * c[3]),
        paint,
      );
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(w * (c[0] + 0.05), h * (c[1] + 0.02)),
            width: w * c[2] * 0.6,
            height: h * c[3] * 0.7),
        paint,
      );
    }

    // ── Birds (upper right) ──
    _birds(canvas, size);

    // ── Mountain ridges (far → near) with atmospheric haze between ──
    _ridge(canvas, size, const [
      [0.0, 0.5], [0.18, 0.4], [0.34, 0.47], [0.5, 0.36],
      [0.66, 0.47], [0.82, 0.4], [1.0, 0.48],
    ], _l1, _l1.withValues(alpha: 0.9));
    _haze(canvas, size, 0.5, 0.12, 0.5);

    _ridge(canvas, size, const [
      [0.0, 0.6], [0.16, 0.52], [0.32, 0.6], [0.5, 0.48],
      [0.68, 0.6], [0.84, 0.52], [1.0, 0.6],
    ], _l2, const Color(0xFFBAA8E1));
    _haze(canvas, size, 0.6, 0.11, 0.42);

    _ridge(canvas, size, const [
      [0.0, 0.72], [0.22, 0.6], [0.4, 0.7], [0.5, 0.62],
      [0.6, 0.7], [0.78, 0.6], [1.0, 0.72],
    ], _l3, const Color(0xFF9C88CF));
    _haze(canvas, size, 0.72, 0.1, 0.34);

    _ridge(canvas, size, const [
      [0.0, 0.86], [0.2, 0.74], [0.4, 0.84], [0.6, 0.74],
      [0.8, 0.84], [1.0, 0.76],
    ], _l4, const Color(0xFF7A61BC));

    // Small pines along the right near-slope.
    final tree = Paint()..color = const Color(0xFF5B4B93);
    for (var i = 0; i < 7; i++) {
      final tx = w * (0.72 + i * 0.04);
      final ty = h * (0.83 - i * 0.004);
      final ts = h * (0.028 - i * 0.001);
      canvas.drawPath(
        Path()
          ..moveTo(tx, ty - ts)
          ..lineTo(tx - ts * 0.42, ty)
          ..lineTo(tx + ts * 0.42, ty)
          ..close(),
        tree,
      );
    }

    // ── Foreground hill the figure sits on ──
    final hill = Path()
      ..moveTo(0, h)
      ..lineTo(0, h * 0.88)
      ..cubicTo(w * 0.3, h * 0.82, w * 0.7, h * 0.82, w, h * 0.88)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(hill, Paint()..color = _foreground);

    // ── Centred meditating figure ──
    _figure(canvas, Rect.fromLTWH(w * 0.36, h * 0.55, w * 0.28, h * 0.26));

    // ── Foliage in the lower corners ──
    _leaf(canvas, Offset(w * 0.06, h * 0.9), h * 0.14, false);
    _leaf(canvas, Offset(w * 0.94, h * 0.88), h * 0.15, true);
  }

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

  void _figure(Canvas canvas, Rect box) {
    final cx = box.center.dx;
    final wd = box.width;
    final ht = box.height;
    final baseY = box.bottom;
    final paint = Paint()..color = _figureColor;

    // Crossed legs / lap — a wide, low rounded base.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(cx, baseY - ht * 0.05),
            width: wd * 1.0,
            height: ht * 0.16),
        Radius.circular(ht * 0.075),
      ),
      paint,
    );

    // Torso tapering up to hooded shoulders.
    final body = Path()
      ..moveTo(cx - wd * 0.36, baseY - ht * 0.09)
      ..cubicTo(cx - wd * 0.34, baseY - ht * 0.4, cx - wd * 0.24,
          baseY - ht * 0.56, cx - wd * 0.12, baseY - ht * 0.62)
      ..cubicTo(cx - wd * 0.06, baseY - ht * 0.65, cx + wd * 0.06,
          baseY - ht * 0.65, cx + wd * 0.12, baseY - ht * 0.62)
      ..cubicTo(cx + wd * 0.24, baseY - ht * 0.56, cx + wd * 0.34,
          baseY - ht * 0.4, cx + wd * 0.36, baseY - ht * 0.09)
      ..close();
    canvas.drawPath(body, paint);

    // Hooded head.
    final headCenter = Offset(cx, baseY - ht * 0.72);
    canvas.drawCircle(headCenter, ht * 0.17, paint);

    // Soft warm rim light on the sun-facing (upper) edge of the head.
    canvas.drawArc(
      Rect.fromCircle(center: headCenter, radius: ht * 0.17),
      3.6,
      1.6,
      false,
      Paint()
        ..color = const Color(0xFFF6E7C4).withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
  }

  void _birds(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()
      ..color = const Color(0xFF6A5AA3).withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.006
      ..strokeCap = StrokeCap.round;
    void bird(double cx, double cy, double s) {
      canvas.drawPath(
        Path()
          ..moveTo(cx - s, cy)
          ..quadraticBezierTo(cx - s * 0.35, cy - s * 0.7, cx, cy)
          ..quadraticBezierTo(cx + s * 0.35, cy - s * 0.7, cx + s, cy),
        paint,
      );
    }

    bird(w * 0.78, h * 0.2, w * 0.05);
    bird(w * 0.86, h * 0.25, w * 0.04);
    bird(w * 0.72, h * 0.26, w * 0.032);
  }

  void _leaf(Canvas canvas, Offset base, double length, bool mirror) {
    final dir = mirror ? -1.0 : 1.0;
    final paint = Paint()..color = const Color(0xFF5B4B93).withValues(alpha: 0.85);
    final stem = Path()
      ..moveTo(base.dx, base.dy)
      ..quadraticBezierTo(
        base.dx + dir * length * 0.3,
        base.dy - length * 0.7,
        base.dx + dir * length * 0.15,
        base.dy - length,
      );
    for (var i = 1; i <= 5; i++) {
      final t = i / 6;
      final px = base.dx + dir * length * 0.3 * t;
      final py = base.dy - length * t;
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(px + dir * length * 0.12, py),
            width: length * 0.24,
            height: length * 0.1),
        paint,
      );
    }
    canvas.drawPath(
      stem,
      Paint()
        ..color = const Color(0xFF4A3B79)
        ..style = PaintingStyle.stroke
        ..strokeWidth = length * 0.03,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
