import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/onboarding_answers.dart';
import '../controllers/onboarding_controller.dart';
import '../widgets/onboarding_option_tile.dart';
import '../widgets/onboarding_question_layout.dart';

/// Q3 — "What is your main goal right now?"
class GoalStep extends ConsumerWidget {
  const GoalStep({super.key, required this.onContinue});

  final VoidCallback onContinue;

  static const Map<OnboardingGoal, IconData> _icons = {
    OnboardingGoal.moveOn: Icons.rocket_launch_rounded,
    OnboardingGoal.healFeelBetter: Icons.favorite_rounded,
    OnboardingGoal.buildBetterMe: Icons.star_rounded,
    OnboardingGoal.getExBack: Icons.autorenew_rounded,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(
      onboardingControllerProvider.select((s) => s.goal),
    );
    final controller = ref.read(onboardingControllerProvider.notifier);

    return OnboardingQuestionLayout(
      title: 'What is your main goal\nright now?',
      subtitle: 'This will help us create your personalized plan.',
      continueEnabled: selected != null,
      onContinue: onContinue,
      options: [
        for (final option in OnboardingGoal.values)
          OnboardingOptionTile(
            label: option.label,
            description: option.description,
            icon: _icons[option],
            selected: selected == option,
            onTap: () => controller.selectGoal(option),
          ),
      ],
    );
  }
}
