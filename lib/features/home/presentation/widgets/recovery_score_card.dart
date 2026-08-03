import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../domain/entities/user_stats.dart';
import '../providers/home_providers.dart';
import 'charts.dart';

/// The gradient Recovery Score card: an animated score ring plus a line chart
/// of recent history.
class RecoveryScoreCard extends ConsumerWidget {
  const RecoveryScoreCard({super.key});

  static const int _maxScore = 100;
  static const List<String> _weekLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(userStatsProvider).valueOrNull ?? UserStats.initial();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final gradientEnd = Color.lerp(colorScheme.primary, Colors.black, 0.35)!;
    const onCard = Colors.white;

    final values = stats.scoreHistory.map((p) => p.score).toList();

    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorScheme.primary, gradientEnd],
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RecoveryScoreRing(
                score: stats.recoveryScore,
                maxScore: _maxScore,
                progressColor: onCard,
                trackColor: onCard.withValues(alpha: 0.25),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${stats.recoveryScore}',
                      style: textTheme.headlineMedium?.copyWith(
                        color: onCard,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '/$_maxScore',
                      style: textTheme.bodySmall
                          ?.copyWith(color: onCard.withValues(alpha: 0.8)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.sm),
              _DeltaLabel(delta: stats.scoreDelta),
            ],
          ),
          const SizedBox(width: AppSizes.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recovery Score',
                  style: textTheme.titleMedium?.copyWith(color: onCard),
                ),
                const SizedBox(height: AppSizes.md),
                RecoveryLineChart(
                  values: values,
                  lineColor: onCard,
                  height: 72,
                ),
                const SizedBox(height: AppSizes.sm),
                _WeekLabels(labels: _weekLabels, color: onCard),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DeltaLabel extends StatelessWidget {
  const _DeltaLabel({required this.delta});

  final int delta;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    const color = Colors.white;
    final (icon, text) = switch (delta) {
      > 0 => (Icons.arrow_upward_rounded, '$delta points'),
      < 0 => (Icons.arrow_downward_rounded, '${delta.abs()} points'),
      _ => (Icons.remove_rounded, 'No change'),
    };
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: AppSizes.iconSm, color: color),
            const SizedBox(width: 2),
            Text(
              text,
              style: textTheme.labelMedium?.copyWith(color: color),
            ),
          ],
        ),
        Text(
          'from yesterday',
          style: textTheme.bodySmall?.copyWith(
            color: color.withValues(alpha: 0.75),
          ),
        ),
      ],
    );
  }
}

class _WeekLabels extends StatelessWidget {
  const _WeekLabels({required this.labels, required this.color});

  final List<String> labels;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (var i = 0; i < labels.length; i++)
          if (i == labels.length - 1)
            Container(
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Text(
                labels[i],
                style: textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          else
            SizedBox(
              width: 22,
              child: Text(
                labels[i],
                textAlign: TextAlign.center,
                style: textTheme.labelSmall
                    ?.copyWith(color: color.withValues(alpha: 0.8)),
              ),
            ),
      ],
    );
  }
}
