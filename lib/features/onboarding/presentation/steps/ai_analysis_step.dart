import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';

/// Screen 6 — AI Analysis.
///
/// A purely visual "analyzing" state with a pulsing halo. It does not call any
/// AI service; the hosting flow advances to the plan after a short delay.
class AiAnalysisStep extends StatefulWidget {
  const AiAnalysisStep({super.key});

  @override
  State<AiAnalysisStep> createState() => _AiAnalysisStepState();
}

class _AiAnalysisStepState extends State<AiAnalysisStep>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(AppSizes.lg),
      child: Column(
        children: [
          const Spacer(),
          Text(
            'Analyzing your answers…',
            textAlign: TextAlign.center,
            style: textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            'Creating your personal recovery plan…',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSizes.xxl),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final t = _controller.value;
              return SizedBox(
                width: 200,
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    _Halo(scale: 0.7 + t * 0.5, opacity: (1 - t) * 0.4,
                        color: colorScheme.primary),
                    _Halo(scale: 0.6 + t * 0.3, opacity: (1 - t) * 0.6,
                        color: colorScheme.primary),
                    child!,
                  ],
                ),
              );
            },
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primary,
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md,
              vertical: AppSizes.sm,
            ),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppSizes.radiusPill),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome_rounded,
                    size: AppSizes.iconSm, color: colorScheme.primary),
                const SizedBox(width: AppSizes.sm),
                Text(
                  'This will only take a few seconds',
                  style: textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.md),
        ],
      ),
    );
  }
}

class _Halo extends StatelessWidget {
  const _Halo({
    required this.scale,
    required this.opacity,
    required this.color,
  });

  final double scale;
  final double opacity;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: Container(
        width: 160,
        height: 160,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: opacity.clamp(0.0, 1.0)),
        ),
      ),
    );
  }
}
