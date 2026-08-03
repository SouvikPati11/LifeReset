import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../domain/entities/user_stats.dart';

/// A circular recovery-score ring with centered content.
class RecoveryScoreRing extends StatelessWidget {
  const RecoveryScoreRing({
    super.key,
    required this.score,
    required this.maxScore,
    required this.progressColor,
    required this.trackColor,
    required this.child,
    this.size = 120,
    this.strokeWidth = 10,
  });

  final int score;
  final int maxScore;
  final Color progressColor;
  final Color trackColor;
  final Widget child;
  final double size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final progress = maxScore <= 0 ? 0.0 : (score / maxScore).clamp(0.0, 1.0);
    return SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: progress),
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOutCubic,
        builder: (context, value, _) {
          return CustomPaint(
            painter: _RingPainter(
              progress: value,
              progressColor: progressColor,
              trackColor: trackColor,
              strokeWidth: strokeWidth,
            ),
            child: Center(child: child),
          );
        },
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.progressColor,
    required this.trackColor,
    required this.strokeWidth,
  });

  final double progress;
  final Color progressColor;
  final Color trackColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = trackColor;
    canvas.drawCircle(center, radius, track);

    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = progressColor;
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * progress, false, arc);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress ||
      old.progressColor != progressColor ||
      old.trackColor != trackColor;
}

/// A smooth line chart of recovery-score history.
class RecoveryLineChart extends StatelessWidget {
  const RecoveryLineChart({
    super.key,
    required this.values,
    required this.lineColor,
    this.height = 90,
  });

  final List<int> values;
  final Color lineColor;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _LineChartPainter(values: values, lineColor: lineColor),
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({required this.values, required this.lineColor});

  final List<int> values;
  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    final minV =
        values.reduce((a, b) => a < b ? a : b).toDouble();
    final maxV =
        values.reduce((a, b) => a > b ? a : b).toDouble();
    final span = (maxV - minV).abs() < 1 ? 1.0 : (maxV - minV);
    const pad = 8.0;

    Offset pointAt(int i) {
      final x = values.length == 1
          ? size.width / 2
          : i / (values.length - 1) * size.width;
      final normalized = (values[i] - minV) / span;
      final y = size.height - pad - normalized * (size.height - 2 * pad);
      return Offset(x, y);
    }

    final path = Path()..moveTo(pointAt(0).dx, pointAt(0).dy);
    for (var i = 1; i < values.length; i++) {
      final prev = pointAt(i - 1);
      final curr = pointAt(i);
      final controlX = (prev.dx + curr.dx) / 2;
      path.cubicTo(controlX, prev.dy, controlX, curr.dy, curr.dx, curr.dy);
    }

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..color = lineColor;
    canvas.drawPath(path, linePaint);

    final dotPaint = Paint()..color = lineColor;
    for (var i = 0; i < values.length; i++) {
      canvas.drawCircle(pointAt(i), 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_LineChartPainter old) =>
      old.values != values || old.lineColor != lineColor;
}

/// A simple animated bar chart for the weekly overview.
class WeeklyBarChart extends StatelessWidget {
  const WeeklyBarChart({
    super.key,
    required this.points,
    required this.barColor,
    this.height = 120,
  });

  final List<ScorePoint> points;
  final Color barColor;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'No data yet',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      );
    }

    final maxScore =
        points.map((p) => p.score).fold<int>(1, (a, b) => a > b ? a : b);
    final peakIndex = _peakIndex(points);
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < points.length; i++)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    height: 20,
                    child: i == peakIndex
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: barColor,
                              borderRadius:
                                  BorderRadius.circular(AppSizes.radiusSm),
                            ),
                            child: Text(
                              '${points[i].score}',
                              style: textTheme.labelSmall
                                  ?.copyWith(color: Colors.white),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(
                        begin: 0,
                        end: (points[i].score / maxScore).clamp(0.05, 1.0),
                      ),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOut,
                      builder: (context, value, _) => FractionallySizedBox(
                        heightFactor: value,
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          width: 10,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                barColor.withValues(alpha: 0.4),
                                barColor,
                              ],
                            ),
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusPill),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.xs),
                  Text(points[i].weekdayLabel, style: textTheme.labelSmall),
                ],
              ),
            ),
        ],
      ),
    );
  }

  int _peakIndex(List<ScorePoint> points) {
    var index = 0;
    for (var i = 1; i < points.length; i++) {
      if (points[i].score >= points[index].score) index = i;
    }
    return index;
  }
}
