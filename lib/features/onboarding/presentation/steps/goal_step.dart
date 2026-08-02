import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/onboarding_answers.dart';
import '../controllers/onboarding_controller.dart';
import '../widgets/onboarding_option_tile.dart';
import '../widgets/onboarding_question_layout.dart';

/// Q3 — "What is your goal?"
class GoalStep extends ConsumerWidget {
  const GoalStep({super.key, required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(
      onboardingControllerProvider.select((s) => s.goal),
    );
    final controller = ref.read(onboardingControllerProvider.notifier);

    return OnboardingQuestionLayout(
      title: 'What is your goal?',
      subtitle: 'What do you want to achieve from this journey?',
      continueEnabled: selected != null,
      onContinue: onContinue,
      options: [
        for (final option in OnboardingGoal.values)
          OnboardingOptionTile(
            label: option.label,
            emoji: option.emoji,
            selected: selected == option,
            onTap: () => controller.selectGoal(option),
          ),
      ],
    );
  }
}
