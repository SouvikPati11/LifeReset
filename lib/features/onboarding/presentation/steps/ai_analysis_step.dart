import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../widgets/onboarding_style.dart';

/// Screen 6 — AI Analysis.
///
/// A purely visual "analyzing" state: a brain inside pulsing radar rings and a
/// checklist that fills in over a few seconds. It calls no AI service; the
/// hosting flow advances to the plan after a short delay.
class AiAnalysisStep extends StatefulWidget {
  const AiAnalysisStep({super.key});

  @override
  State<AiAnalysisStep> createState() => _AiAnalysisStepState();
}

class _AiAnalysisStepState extends State<AiAnalysisStep>
    with TickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat();

  late final AnimationController _progress = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..forward();

  static const _steps = [
    'Understanding your situation',
    'Identifying patterns',
    'Creating personalized plan',
    'Preparing your roadmap',
  ];

  @override
  void dispose() {
    _pulse.dispose();
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.lg),
      child: Column(
        children: [
          const Spacer(),
          const Text(
            'Analyzing your answers',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: OnboardingStyle.ink,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          const Text(
            'Our AI is creating your\npersonalized recovery plan…',
            textAlign: TextAlign.center,
            style: OnboardingStyle.subtitle,
          ),
          const SizedBox(height: AppSizes.xxl),
          SizedBox(
            width: 220,
            height: 220,
            child: AnimatedBuilder(
              animation: _pulse,
              builder: (context, child) {
                final t = _pulse.value;
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    _Ring(size: 120 + t * 90, opacity: (1 - t) * 0.35),
                    _Ring(size: 120 + t * 55, opacity: (1 - t) * 0.5),
                    child!,
                  ],
                );
              },
              child: Container(
                width: 108,
                height: 108,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: OnboardingStyle.gradient,
                ),
                child: const Icon(Icons.psychology_rounded,
                    color: Colors.white, size: 52),
              ),
            ),
          ),
          const Spacer(),
          AnimatedBuilder(
            animation: _progress,
            builder: (context, _) {
              final active = (_progress.value * _steps.length)
                  .floor()
                  .clamp(0, _steps.length - 1);
              return Container(
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: OnboardingStyle.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: OnboardingStyle.border),
                ),
                child: Column(
                  children: [
                    for (var i = 0; i < _steps.length; i++)
                      _ChecklistRow(
                        label: _steps[i],
                        done: i < active,
                        active: i == active,
                      ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: AppSizes.sm),
        ],
      ),
    );
  }
}

class _Ring extends StatelessWidget {
  const _Ring({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: OnboardingStyle.accent.withValues(alpha: opacity.clamp(0, 1)),
          width: 2,
        ),
      ),
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  const _ChecklistRow({
    required this.label,
    required this.done,
    required this.active,
  });

  final String label;
  final bool done;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final Widget leading;
    if (done) {
      leading = const Icon(Icons.check_circle_rounded,
          color: OnboardingStyle.accent, size: 22);
    } else if (active) {
      leading = const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.4,
          valueColor: AlwaysStoppedAnimation<Color>(OnboardingStyle.accent),
        ),
      );
    } else {
      leading = const Icon(Icons.circle_outlined,
          color: Color(0xFFCBC7DA), size: 22);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(width: 22, height: 22, child: Center(child: leading)),
          const SizedBox(width: AppSizes.md),
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: done || active ? FontWeight.w600 : FontWeight.w400,
              color: done || active
                  ? OnboardingStyle.ink
                  : OnboardingStyle.bodyGray,
            ),
          ),
        ],
      ),
    );
  }
}
