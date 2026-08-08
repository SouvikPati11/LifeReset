import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import 'onboarding_style.dart';

/// Shared layout for the single-select question steps: a bold title, optional
/// subtitle, a scrollable list of options, and a pinned purple Continue button.
class OnboardingQuestionLayout extends StatelessWidget {
  const OnboardingQuestionLayout({
    super.key,
    required this.title,
    required this.options,
    required this.continueEnabled,
    required this.onContinue,
    this.subtitle,
    this.continueLabel = 'Continue',
  });

  final String title;
  final String? subtitle;
  final List<Widget> options;
  final bool continueEnabled;
  final VoidCallback onContinue;
  final String continueLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.lg,
              AppSizes.sm,
              AppSizes.lg,
              AppSizes.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: OnboardingStyle.title),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSizes.sm),
                  Text(subtitle!, style: OnboardingStyle.subtitle),
                ],
                const SizedBox(height: AppSizes.xl),
                ...options,
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.lg,
            AppSizes.sm,
            AppSizes.lg,
            AppSizes.lg,
          ),
          child: OnboardingButton(
            label: continueLabel,
            onPressed: continueEnabled ? onContinue : null,
          ),
        ),
      ],
    );
  }
}
