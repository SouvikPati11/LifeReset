import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/primary_button.dart';

/// Shared layout for the single-select question steps: a title, optional
/// subtitle, a scrollable list of options, and a pinned Continue button.
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
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.lg,
              AppSizes.md,
              AppSizes.lg,
              AppSizes.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: textTheme.headlineMedium),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSizes.sm),
                  Text(
                    subtitle!,
                    style: textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
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
          child: PrimaryButton(
            label: continueLabel,
            onPressed: continueEnabled ? onContinue : null,
          ),
        ),
      ],
    );
  }
}
