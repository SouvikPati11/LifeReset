import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/onboarding_answers.dart';
import '../controllers/onboarding_controller.dart';
import '../widgets/onboarding_option_tile.dart';
import '../widgets/onboarding_question_layout.dart';

/// Screen 2 — "What brings you here today?"
class ChooseProblemStep extends ConsumerWidget {
  const ChooseProblemStep({super.key, required this.onContinue});

  final VoidCallback onContinue;

  static const Map<OnboardingProblem, IconData> _icons = {
    OnboardingProblem.breakupRecovery: Icons.favorite_rounded,
    OnboardingProblem.anxietyStress: Icons.spa_rounded,
    OnboardingProblem.lowConfidence: Icons.person_rounded,
    OnboardingProblem.overthinking: Icons.psychology_rounded,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final problem =
        ref.watch(onboardingControllerProvider.select((s) => s.problem));
    final controller = ref.read(onboardingControllerProvider.notifier);

    return OnboardingQuestionLayout(
      title: 'What brings you here\ntoday?',
      subtitle: 'Choose the area you want to work on.',
      continueEnabled: true,
      onContinue: onContinue,
      options: [
        for (final option in OnboardingProblem.values)
          OnboardingOptionTile(
            label: option.label,
            description: option.description,
            icon: _icons[option],
            selected: problem == option,
            showCheck: true,
            onTap: () => controller.selectProblem(option),
          ),
      ],
    );
  }
}
