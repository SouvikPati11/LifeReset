import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../controllers/onboarding_controller.dart';

/// Screen 8 — Subscription / 7-Day Trial.
///
/// UI only: no payment is processed. "Start Free Trial" saves all onboarding
/// answers to Firestore and marks onboarding complete, after which the router
/// guard moves the user into the app.
class SubscriptionStep extends ConsumerWidget {
  const SubscriptionStep({super.key});

  static const List<String> _perks = [
    'AI Coach – Get support anytime',
    'Personalized Recovery Plan',
    'Mood Tracking & Insights',
    'Daily Tasks & Reminders',
    'Journal & Progress Tracking',
    'Cancel anytime, no questions asked',
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isSubmitting = ref.watch(
      onboardingControllerProvider.select((s) => s.isSubmitting),
    );

    final gradientEnd = Color.lerp(colorScheme.primary, Colors.black, 0.5)!;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [colorScheme.primary, gradientEnd],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          children: [
            const SizedBox(height: AppSizes.md),
            const Icon(Icons.workspace_premium_rounded,
                color: Colors.amber, size: 40),
            const SizedBox(height: AppSizes.md),
            Text(
              'Start Your 7-Day Trial',
              textAlign: TextAlign.center,
              style: textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSizes.xs),
            Text(
              'Unlock everything and start your transformation journey.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: AppSizes.lg),
            const _PerksCard(perks: _perks),
            const SizedBox(height: AppSizes.lg),
            const _PriceRow(),
            const SizedBox(height: AppSizes.lg),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: isSubmitting ? null : () => _startTrial(context, ref),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: colorScheme.primary,
                ),
                child: isSubmitting
                    ? const InlineLoader(size: AppSizes.iconMd)
                    : const Text('Start Free Trial'),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline_rounded,
                    size: AppSizes.iconSm,
                    color: Colors.white.withValues(alpha: 0.8)),
                const SizedBox(width: AppSizes.xs),
                Text(
                  'Secure payment. Cancel anytime.',
                  style: textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PerksCard extends StatelessWidget {
  const _PerksCard({super.key, required this.perks});

  final List<String> perks;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final perk in perks)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.xs),
              child: Row(
                children: [
                  Icon(Icons.check_circle_rounded,
                      color: colorScheme.primary, size: AppSizes.iconMd),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: Text(perk, style: textTheme.bodyMedium),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '₹299',
                style: textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextSpan(
                text: ' / month',
                style: textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSizes.md),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md,
            vertical: AppSizes.xs,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppSizes.radiusPill),
          ),
          child: Text(
            '7-Day Free Trial',
            style: textTheme.labelMedium?.copyWith(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
