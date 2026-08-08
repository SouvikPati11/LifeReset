import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/onboarding_answers.dart';
import '../controllers/onboarding_controller.dart';
import '../widgets/onboarding_option_tile.dart';
import '../widgets/onboarding_question_layout.dart';

/// Q2 — "What hurts you the most right now?"
class HurtMostStep extends ConsumerWidget {
  const HurtMostStep({super.key, required this.onContinue});

  final VoidCallback onContinue;

  static const Map<HurtMost, IconData> _icons = {
    HurtMost.missingThem: Icons.people_alt_rounded,
    HurtMost.memories: Icons.image_rounded,
    HurtMost.loneliness: Icons.person_rounded,
    HurtMost.future: Icons.schedule_rounded,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(
      onboardingControllerProvider.select((s) => s.hurtMost),
    );
    final controller = ref.read(onboardingControllerProvider.notifier);

    return OnboardingQuestionLayout(
      title: 'What hurts you the most\nright now?',
      subtitle: 'You can choose only one.',
      continueEnabled: selected != null,
      onContinue: onContinue,
      options: [
        for (final option in HurtMost.values)
          OnboardingOptionTile(
            label: option.label,
            description: option.description,
            icon: _icons[option],
            selected: selected == option,
            onTap: () => controller.selectHurtMost(option),
          ),
      ],
    );
  }
}
