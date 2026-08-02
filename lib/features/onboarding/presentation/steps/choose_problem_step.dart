import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../controllers/onboarding_controller.dart';
import '../widgets/onboarding_question_layout.dart';

/// Screen 2 — "What do you want to improve?"
///
/// Version 1 offers only Breakup Recovery, which is pre-selected, so Continue is
/// always enabled.
class ChooseProblemStep extends ConsumerWidget {
  const ChooseProblemStep({super.key, required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final problem =
        ref.watch(onboardingControllerProvider.select((s) => s.problem));

    return OnboardingQuestionLayout(
      title: 'What do you want\nto improve?',
      subtitle: 'Select the area you want to focus on.',
      continueEnabled: true,
      onContinue: onContinue,
      options: [
        _ProblemCard(
          title: problem.label,
          description: 'Heal your heart and build a better you.',
          selected: true,
        ),
      ],
    );
  }
}

class _ProblemCard extends StatelessWidget {
  const _ProblemCard({
    required this.title,
    required this.description,
    required this.selected,
  });

  final String title;
  final String description;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.lg,
        vertical: AppSizes.xl,
      ),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: selected ? colorScheme.primary : colorScheme.outlineVariant,
          width: selected ? 1.6 : 1,
        ),
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.circle_outlined,
              color: selected ? colorScheme.primary : colorScheme.outline,
            ),
          ),
          const Text('💔', style: TextStyle(fontSize: 56)),
          const SizedBox(height: AppSizes.md),
          Text(
            title,
            textAlign: TextAlign.center,
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSizes.xs),
          Text(
            description,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
