import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A smooth line chart with optional bottom labels.
class AdminLineChart extends StatelessWidget {
  const AdminLineChart({
    super.key,
    required this.values,
    required this.labels,
    this.height = 160,
  });

  final List<int> values;
  final List<String> labels;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    if (values.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(child: Text('No data', style: textTheme.bodySmall)),
      );
    }
    return SizedBox(
      height: height,
      child: Column(
        children: [
          Expanded(
            child: CustomPaint(
              size: Size.infinite,
              painter: _LinePainter(values: values, color: colorScheme.primary),
            ),
          ),
          if (labels.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final l in labels)
                  Text(l, style: textTheme.labelSmall),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _LinePainter extends CustomPainter {
  _LinePainter({required this.values, required this.color});
  final List<int> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const pad = 8.0;
    final maxV = values.reduce((a, b) => a > b ? a : b).toDouble();
    final span = maxV <= 0 ? 1.0 : maxV;

    Offset at(int i) {
      final x = values.length == 1
          ? size.width / 2
          : i / (values.length - 1) * size.width;
      final y = size.height - pad - (values[i] / span) * (size.height - 2 * pad);
      return Offset(x, y);
    }

    final path = Path()..moveTo(at(0).dx, at(0).dy);
    for (var i = 1; i < values.length; i++) {
      final p = at(i - 1), c = at(i);
      final mx = (p.dx + c.dx) / 2;
      path.cubicTo(mx, p.dy, mx, c.dy, c.dx, c.dy);
    }
    final fill = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(fill, Paint()..color = color.withValues(alpha: 0.08));
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..color = color,
    );
    final dot = Paint()..color = color;
    for (var i = 0; i < values.length; i++) {
      canvas.drawCircle(at(i), 3, dot);
    }
  }

  @override
  bool shouldRepaint(_LinePainter old) => old.values != values;
}

/// A two-segment donut (e.g. Free vs Premium) with a centered total.
class AdminDonut extends StatelessWidget {
  const AdminDonut({
    super.key,
    required this.segments,
    required this.centerValue,
    required this.centerLabel,
    this.size = 150,
  });

  /// (color, value) pairs.
  final List<(Color, num)> segments;
  final String centerValue;
  final String centerLabel;
  final double size;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final total = segments.fold<num>(0, (a, s) => a + s.$2);
    final fractions = [
      for (final s in segments) (s.$1, total == 0 ? 0.0 : s.$2 / total),
    ];
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _DonutPainter(fractions),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(centerValue,
                  style: textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700)),
              Text(centerLabel, style: textTheme.labelSmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter(this.fractions);
  final List<(Color, double)> fractions;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    const stroke = 18.0;
    final rect = Rect.fromCircle(center: center, radius: radius - stroke / 2);
    final hasData = fractions.any((f) => f.$2 > 0);
    if (!hasData) {
      canvas.drawCircle(
        center,
        radius - stroke / 2,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..color = const Color(0x22000000),
      );
      return;
    }
    var start = -math.pi / 2;
    for (final (color, fraction) in fractions) {
      if (fraction <= 0) continue;
      final sweep = fraction * 2 * math.pi;
      canvas.drawArc(
        rect,
        start,
        sweep - 0.03,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round
          ..color = color,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) => old.fractions != fractions;
}
