import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../controllers/onboarding_controller.dart';
import '../widgets/onboarding_style.dart';

/// Screen 7 — Personalized Plan.
///
/// A "Made for You" header, the (locally derived) recovery score, and the
/// user's top priorities, matching the Figma.
class PersonalizedPlanStep extends ConsumerWidget {
  const PersonalizedPlanStep({super.key, required this.onContinue});

  final VoidCallback onContinue;

  static const List<(IconData, String)> _priorities = [
    (Icons.spa_rounded, 'Let go of painful memories'),
    (Icons.healing_rounded, 'Heal your emotional pain'),
    (Icons.self_improvement_rounded, 'Build self love and confidence'),
    (Icons.wb_sunny_rounded, 'Create a positive future'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final score = ref.read(onboardingControllerProvider.notifier).recoveryScore;

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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(
                      child: Text(
                        'Your Personalized\nRecovery Plan',
                        style: OnboardingStyle.title,
                      ),
                    ),
                    const SizedBox(width: AppSizes.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: OnboardingStyle.selectedFill,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'Made for You',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: OnboardingStyle.accent,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.sm),
                const Text(
                  "Based on your answers, here's your personalized plan.",
                  style: OnboardingStyle.subtitle,
                ),
                const SizedBox(height: AppSizes.lg),
                _ScoreCard(score: score),
                const SizedBox(height: AppSizes.lg),
                const Text(
                  'Your Top Priorities',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: OnboardingStyle.ink,
                  ),
                ),
                const SizedBox(height: AppSizes.sm),
                for (final (icon, label) in _priorities)
                  _PriorityRow(icon: icon, label: label),
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
          child: OnboardingButton(label: 'Continue to Plan', onPressed: onContinue),
        ),
      ],
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3A2E6B), Color(0xFF5B3BC4)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Recovery Score',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: AppSizes.xs),
                Text(
                  '$score%',
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: AppSizes.xs),
                Text(
                  'Good Start! Keep going 💜',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 76,
            height: 76,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 76,
                  height: 76,
                  child: CircularProgressIndicator(
                    value: score / 100,
                    strokeWidth: 7,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PriorityRow extends StatelessWidget {
  const _PriorityRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.sm + 4),
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: OnboardingStyle.surface,
        borderRadius: BorderRadius.circular(OnboardingStyle.fieldRadius),
        border: Border.all(color: OnboardingStyle.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: OnboardingStyle.chipBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: OnboardingStyle.accent),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: OnboardingStyle.ink,
              ),
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: OnboardingStyle.bodyGray),
        ],
      ),
    );
  }
}
