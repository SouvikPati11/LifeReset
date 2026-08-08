import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../controllers/onboarding_controller.dart';
import '../widgets/onboarding_style.dart';

/// Screen 8 — Subscription / 7-Day Trial.
///
/// UI only: no payment is processed. "Start Free Trial" saves all onboarding
/// answers to Firestore and marks onboarding complete, after which the router
/// guard moves the user into the app.
class SubscriptionStep extends ConsumerWidget {
  const SubscriptionStep({super.key});

  static const List<String> _perks = [
    'Personalized AI Coaching',
    'Daily Tasks & Reminders',
    'Mood Tracking & Insights',
    'Unlimited Journal Entries',
    'Progress Analytics',
  ];

  Future<void> _startTrial(BuildContext context, WidgetRef ref) async {
    final ok = await ref.read(onboardingControllerProvider.notifier).complete();
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Could not start your trial. Try again.')),
        );
    }
    // On success the router redirects into the app automatically.
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSubmitting = ref.watch(
      onboardingControllerProvider.select((s) => s.isSubmitting),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.lg,
        AppSizes.md,
        AppSizes.lg,
        AppSizes.lg,
      ),
      child: Column(
        children: [
          const Text('👑', style: TextStyle(fontSize: 64)),
          const SizedBox(height: AppSizes.md),
          const Text(
            'Start Your 7-Day Trial',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: OnboardingStyle.ink,
            ),
          ),
          const SizedBox(height: AppSizes.xs),
          const Text(
            'Unlock your full recovery plan\nand premium features.',
            textAlign: TextAlign.center,
            style: OnboardingStyle.subtitle,
          ),
          const SizedBox(height: AppSizes.lg),
          const _PerksCard(perks: _perks),
          const SizedBox(height: AppSizes.lg),
          const _PriceCard(),
          const SizedBox(height: AppSizes.lg),
          OnboardingButton(
            label: 'Start Free Trial',
            isLoading: isSubmitting,
            onPressed: isSubmitting ? null : () => _startTrial(context, ref),
          ),
          const SizedBox(height: AppSizes.md),
          const Text(
            'Cancel anytime. No commitment.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: OnboardingStyle.bodyGray),
          ),
        ],
      ),
    );
  }
}

class _PerksCard extends StatelessWidget {
  const _PerksCard({required this.perks});

  final List<String> perks;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: OnboardingStyle.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: OnboardingStyle.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final perk in perks)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: OnboardingStyle.accent, size: AppSizes.iconMd),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: Text(
                      perk,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: OnboardingStyle.ink,
                      ),
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

class _PriceCard extends StatelessWidget {
  const _PriceCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.lg,
        vertical: AppSizes.lg,
      ),
      decoration: BoxDecoration(
        color: OnboardingStyle.selectedFill,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: OnboardingStyle.accent.withValues(alpha: 0.4)),
      ),
      child: const Column(
        children: [
          Text(
            '7-Day Free Trial',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: OnboardingStyle.ink,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '₹299',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: OnboardingStyle.accent,
                  ),
                ),
                TextSpan(
                  text: ' / month after trial',
                  style: TextStyle(
                    fontSize: 14,
                    color: OnboardingStyle.bodyGray,
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
