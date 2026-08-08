import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/onboarding_answers.dart';
import '../controllers/onboarding_controller.dart';
import '../widgets/onboarding_option_tile.dart';
import '../widgets/onboarding_question_layout.dart';

/// Q1 — "When did your breakup happen?" (options are text-only, per the Figma).
class BreakupTimingStep extends ConsumerWidget {
  const BreakupTimingStep({super.key, required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(
      onboardingControllerProvider.select((s) => s.breakupTiming),
    );
    final controller = ref.read(onboardingControllerProvider.notifier);

    return OnboardingQuestionLayout(
      title: 'When did your\nbreakup happen?',
      subtitle: 'This helps us understand your current stage.',
      continueEnabled: selected != null,
      onContinue: onContinue,
      options: [
        for (final option in BreakupTiming.values)
          OnboardingOptionTile(
            label: option.label,
            description: option.description,
            selected: selected == option,
            onTap: () => controller.selectTiming(option),
          ),
      ],
    );
  }
}
