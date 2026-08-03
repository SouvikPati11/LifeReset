import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../domain/entities/journal_analytics.dart';
import '../../domain/entities/mood_type.dart';
import 'mood_widgets.dart';

/// Line chart of mood scores over time, with weekday labels for short ranges.
class MoodTrendChart extends StatelessWidget {
  const MoodTrendChart({super.key, required this.points, this.height = 150});

  final List<MoodTrendPoint> points;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    if (points.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text('No mood data yet', style: textTheme.bodySmall),
        ),
      );
    }
    return SizedBox(
      height: height,
      child: Column(
        children: [
          Expanded(
            child: CustomPaint(
              size: Size.infinite,
              painter: _TrendPainter(
                scores: points.map((p) => p.score).toList(),
                color: colorScheme.primary,
              ),
            ),
          ),
          if (points.length <= 7) ...[
            const SizedBox(height: AppSizes.xs),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final p in points)
                  Text(_weekday(p.date), style: textTheme.labelSmall),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _weekday(DateTime d) {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return labels[(d.weekday - 1) % 7];
  }
}

class _TrendPainter extends CustomPainter {
  _TrendPainter({required this.scores, required this.color});

  final List<int> scores;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (scores.isEmpty) return;
    const maxScore = 10.0;
    const pad = 8.0;

    Offset pointAt(int i) {
      final x = scores.length == 1
          ? size.width / 2
          : i / (scores.length - 1) * size.width;
      final y = size.height - pad - (scores[i] / maxScore) * (size.height - 2 * pad);
      return Offset(x, y);
    }

    if (scores.length == 1) {
      canvas.drawCircle(pointAt(0), 4, Paint()..color = color);
      return;
    }

    final path = Path()..moveTo(pointAt(0).dx, pointAt(0).dy);
    for (var i = 1; i < scores.length; i++) {
      final prev = pointAt(i - 1);
      final curr = pointAt(i);
      final cx = (prev.dx + curr.dx) / 2;
      path.cubicTo(cx, prev.dy, cx, curr.dy, curr.dx, curr.dy);
    }

    // Soft fill under the line.
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
    for (var i = 0; i < scores.length; i++) {
      canvas.drawCircle(pointAt(i), 3, dot);
    }
  }

  @override
  bool shouldRepaint(_TrendPainter old) =>
      old.scores != scores || old.color != color;
}

/// Donut of mood distribution with the average score in the center.
class MoodDistributionDonut extends StatelessWidget {
  const MoodDistributionDonut({
    super.key,
    required this.distribution,
    required this.averageScore,
    this.size = 140,
  });

  final Map<MoodType, int> distribution;
  final double averageScore;
  final double size;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final total = distribution.values.fold<int>(0, (a, b) => a + b);
    final segments = [
      for (final mood in MoodType.values)
        if ((distribution[mood] ?? 0) > 0)
          (moodColor(mood), (distribution[mood] ?? 0) / total),
    ];

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _DonutPainter(segments: segments),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                averageScore.toStringAsFixed(1),
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text('Avg Mood', style: textTheme.labelSmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({required this.segments});

  final List<(Color, double)> segments;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    const stroke = 16.0;
    final rect = Rect.fromCircle(center: center, radius: radius - stroke / 2);

    if (segments.isEmpty) {
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
    const gap = 0.04;
    for (final (color, fraction) in segments) {
      final sweep = fraction * 2 * math.pi - gap;
      canvas.drawArc(
        rect,
        start + gap / 2,
        sweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round
          ..color = color,
      );
      start += fraction * 2 * math.pi;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) => old.segments != segments;
}
