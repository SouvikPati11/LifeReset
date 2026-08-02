import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_sizes.dart';

/// A segmented, animated progress indicator shown across the question steps.
///
/// Segments up to (and including) [currentStep] animate to the filled color;
/// the rest stay muted. Matches the pill-style progress bar in the design.
class OnboardingProgressBar extends StatelessWidget {
  const OnboardingProgressBar({
    super.key,
    required this.stepCount,
    required this.currentStep,
  });

  /// Total number of chrome steps.
  final int stepCount;

  /// Zero-based index of the active step.
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: List.generate(stepCount, (index) {
        final filled = index <= currentStep;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: index == stepCount - 1 ? 0 : AppSizes.xs,
            ),
            child: AnimatedContainer(
              duration: AppConstants.mediumAnimation,
              curve: Curves.easeOut,
              height: 6,
              decoration: BoxDecoration(
                color: filled
                    ? colorScheme.primary
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppSizes.radiusPill),
              ),
            ),
          ),
        );
      }),
    );
  }
}
