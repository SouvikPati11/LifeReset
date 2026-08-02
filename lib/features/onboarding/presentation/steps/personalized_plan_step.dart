import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../controllers/onboarding_controller.dart';

/// Screen 7 — Personalized Plan.
///
/// Presents the (locally derived) recovery score and the program's feature
/// tiles: 30-Day Plan, Recovery Score, Daily Tasks, AI Coach, Journal and Mood
/// Tracking.
class PersonalizedPlanStep extends ConsumerWidget {
  const PersonalizedPlanStep({super.key, required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final score = ref.read(onboardingControllerProvider.notifier).recoveryScore;

    final features = <_PlanFeature>[
      _PlanFeature(Icons.calendar_month_rounded, '30 Days\nPlan'),
      _PlanFeature(Icons.trending_up_rounded, 'Recovery\nScore', value: '$score'),
      _PlanFeature(Icons.checklist_rounded, 'Daily\nTasks'),
      _PlanFeature(Icons.smart_toy_rounded, 'AI Coach'),
      _PlanFeature(Icons.menu_book_rounded, 'Journal'),
      _PlanFeature(Icons.sentiment_satisfied_rounded, 'Mood\nTracking'),
    ];

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.lg,
              AppSizes.lg,
              AppSizes.lg,
              AppSizes.md,
            ),
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.primary,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: AppSizes.lg),
                Text(
                  'Your Plan Is Ready!',
                  textAlign: TextAlign.center,
                  style: textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSizes.xs),
                Text(
                  'We created a personalized 30-day recovery plan just for you.',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSizes.xl),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: AppSizes.md,
                  crossAxisSpacing: AppSizes.md,
                  childAspectRatio: 0.92,
                  children: [
                    for (final feature in features) _PlanTile(feature: feature),
                  ],
                ),
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
            label: 'Continue to Plan',
            onPressed: onContinue,
          ),
        ),
      ],
    );
  }
}

class _PlanFeature {
  const _PlanFeature(this.icon, this.label, {this.value});

  final IconData icon;
  final String label;
  final String? value;
}

class _PlanTile extends StatelessWidget {
  const _PlanTile({required this.feature});

  final _PlanFeature feature;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSizes.sm),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (feature.value != null)
            Text(
              feature.value!,
              style: textTheme.titleLarge?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            )
          else
            Icon(feature.icon, color: colorScheme.primary, size: AppSizes.iconLg),
          const SizedBox(height: AppSizes.sm),
          Text(
            feature.label,
            textAlign: TextAlign.center,
            style: textTheme.labelMedium,
          ),
        ],
      ),
    );
  }
}
