import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/onboarding_answers.dart';
import '../controllers/onboarding_controller.dart';
import '../widgets/onboarding_option_tile.dart';
import '../widgets/onboarding_question_layout.dart';

/// Q2 — "What hurts the most?"
class HurtMostStep extends ConsumerWidget {
  const HurtMostStep({super.key, required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(
      onboardingControllerProvider.select((s) => s.hurtMost),
    );
    final controller = ref.read(onboardingControllerProvider.notifier);

    return OnboardingQuestionLayout(
      title: 'What hurts the most?',
      subtitle: "Choose what you're struggling with the most right now.",
      continueEnabled: selected != null,
      onContinue: onContinue,
      options: [
        for (final option in HurtMost.values)
          OnboardingOptionTile(
            label: option.label,
            emoji: option.emoji,
            selected: selected == option,
            onTap: () => controller.selectHurtMost(option),
          ),
      ],
    );
  }
}
