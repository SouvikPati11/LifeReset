import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../domain/entities/progress_models.dart';

/// A rounded surface card used across the progress screen.
class PSectionCard extends StatelessWidget {
  const PSectionCard({super.key, required this.child, this.padding});
  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: child,
    );
  }
}

/// A stat tile (icon, value, label).
class ProgressStatTile extends StatelessWidget {
  const ProgressStatTile({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return PSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withValues(alpha: 0.15),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(value,
              style: textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          Text(label,
              style: textTheme.bodySmall
                  ?.copyWith(color: colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

/// A milestone row with an achieved/locked indicator.
class MilestoneTile extends StatelessWidget {
  const MilestoneTile({super.key, required this.milestone});
  final Milestone milestone;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final achieved = milestone.achieved;
    final accent = achieved ? const Color(0xFF2E9E63) : colorScheme.outline;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
      child: Row(
        children: [
          Icon(
            achieved ? Icons.emoji_events_rounded : Icons.lock_outline_rounded,
            color: accent,
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(milestone.title,
                    style: textTheme.titleSmall?.copyWith(
                      color: achieved ? null : colorScheme.onSurfaceVariant,
                    )),
                Text(milestone.subtitle,
                    style: textTheme.bodySmall
                        ?.copyWith(color: colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          if (achieved)
            const Icon(Icons.check_circle_rounded,
                color: Color(0xFF2E9E63), size: 20),
        ],
      ),
    );
  }
}

/// A smooth line chart drawn with a CustomPainter (no chart dependency).
class ProgressLineChart extends StatelessWidget {
  const ProgressLineChart({
    super.key,
    required this.values,
    required this.labels,
    this.height = 160,
    this.color,
  });

  final List<int> values;
  final List<String> labels;
  final double height;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final lineColor = color ?? colorScheme.primary;

    if (values.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(child: Text('No data yet', style: textTheme.bodySmall)),
      );
    }
    return SizedBox(
      height: height,
      child: Column(
        children: [
          Expanded(
            child: CustomPaint(
              size: Size.infinite,
              painter: _LineChartPainter(values: values, color: lineColor),
            ),
          ),
          if (labels.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final l in labels) Text(l, style: textTheme.labelSmall),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({required this.values, required this.color});
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
  bool shouldRepaint(_LineChartPainter old) => old.values != values;
}
