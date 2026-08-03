import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../domain/entities/subscription_models.dart';
import 'premium_widgets.dart';

/// Shows the "Confirm Subscription" bottom sheet. Resolves to `true` when the
/// user chooses to proceed (to payment, or to start the free trial).
Future<bool?> showConfirmSubscriptionSheet(
  BuildContext context, {
  required bool trialEligible,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _ConfirmSubscriptionSheet(trialEligible: trialEligible),
  );
}

class _ConfirmSubscriptionSheet extends StatelessWidget {
  const _ConfirmSubscriptionSheet({required this.trialEligible});
  final bool trialEligible;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSizes.lg, 0, AppSizes.lg, AppSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CrownBadge(),
            const SizedBox(height: AppSizes.md),
            Text('Confirm Subscription', style: textTheme.titleLarge),
            const SizedBox(height: AppSizes.xs),
            Text('Premium Monthly',
                style: textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            Text(
              '${SubscriptionPlanConfig.priceLabel} / ${SubscriptionPlanConfig.periodLabel}',
              style: textTheme.bodyMedium
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: AppSizes.md),
            SectionCard(
              child: Column(
                children: [
                  if (trialEligible)
                    _row(
                      context,
                      '${SubscriptionPlanConfig.trialDays} Days Free Trial',
                      '₹0 today',
                    ),
                  _row(
                    context,
                    trialEligible
                        ? 'Auto renews after ${SubscriptionPlanConfig.trialDays} days'
                        : 'Billed monthly',
                    '${SubscriptionPlanConfig.priceLabel}/${SubscriptionPlanConfig.periodLabel}',
                  ),
                  _row(context, 'Cancel anytime', ''),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_rounded,
                    size: 14, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: AppSizes.xs),
                Text('Secure payment by Razorpay',
                    style: textTheme.bodySmall
                        ?.copyWith(color: colorScheme.onSurfaceVariant)),
              ],
            ),
            const SizedBox(height: AppSizes.md),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: kPremiumIndigo,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
                ),
                child: Text(
                    trialEligible ? 'Start Free Trial' : 'Continue to Payment'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(BuildContext context, String label, String trailing) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, size: 20, color: kSuccessGreen),
          const SizedBox(width: AppSizes.sm),
          Expanded(child: Text(label, style: textTheme.bodyMedium)),
          if (trailing.isNotEmpty)
            Text(trailing,
                style: textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
