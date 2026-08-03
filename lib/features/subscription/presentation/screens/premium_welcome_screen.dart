import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../routing/app_routes.dart';
import '../../domain/entities/subscription_models.dart';
import '../widgets/premium_widgets.dart';

/// Screen 5 — "Welcome to LifeReset Premium".
class PremiumWelcomeScreen extends StatelessWidget {
  const PremiumWelcomeScreen({super.key, this.isTrial = false});
  final bool isTrial;

  static const _benefits = <(IconData, String, Color)>[
    (Icons.forum_rounded, 'AI Coach Unlocked', Color(0xFF7C4DFF)),
    (Icons.workspace_premium_rounded, 'All Programs Access', Color(0xFFF5A623)),
    (Icons.insights_rounded, 'Advanced Insights', Color(0xFF2E9E63)),
    (Icons.block_rounded, 'Ads Free', Color(0xFFE0576B)),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kPremiumGold.withValues(alpha: 0.15),
                ),
                child: const Icon(Icons.celebration_rounded,
                    size: 60, color: kPremiumGold),
              ),
              const SizedBox(height: AppSizes.lg),
              Text('Welcome to\nLifeReset Premium!',
                  textAlign: TextAlign.center,
                  style: textTheme.headlineMedium),
              const SizedBox(height: AppSizes.sm),
              Text(
                isTrial
                    ? 'Your ${SubscriptionPlanConfig.trialDays}-day free trial is now active. Start your journey to a better you.'
                    : 'Your subscription is now active. Start your journey to a better you.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium
                    ?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: AppSizes.xl),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: AppSizes.sm,
                crossAxisSpacing: AppSizes.sm,
                childAspectRatio: 3.2,
                children: [
                  for (final b in _benefits)
                    BenefitChip(icon: b.$1, label: b.$2, color: b.$3),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => context.go(AppRoutes.home),
                  style: FilledButton.styleFrom(
                    backgroundColor: kPremiumIndigo,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
                  ),
                  child: const Text('Go to Dashboard'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
