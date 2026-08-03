import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../controllers/checkout_controller.dart';
import '../widgets/premium_widgets.dart';
import 'payment_processing_screen.dart';

/// Screen 8 — payment failed / retry. Premium is never unlocked here.
class PaymentFailedScreen extends ConsumerWidget {
  const PaymentFailedScreen({super.key, this.reason, this.isTrial = false});
  final String? reason;
  final bool isTrial;

  void _retry(BuildContext context, WidgetRef ref) {
    ref.read(checkoutControllerProvider.notifier).reset();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => PaymentProcessingScreen(isTrial: isTrial),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  color: colorScheme.error.withValues(alpha: 0.12),
                ),
                child: Icon(Icons.credit_card_off_rounded,
                    size: 56, color: colorScheme.error),
              ),
              const SizedBox(height: AppSizes.lg),
              Text('Payment Failed', style: textTheme.headlineSmall),
              const SizedBox(height: AppSizes.xs),
              Text(
                "We couldn't complete your payment. Please try again.",
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium
                    ?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: AppSizes.lg),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: colorScheme.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded,
                        size: 18, color: colorScheme.error),
                    const SizedBox(width: AppSizes.sm),
                    Expanded(
                      child: Text(
                        reason?.trim().isNotEmpty == true
                            ? reason!
                            : 'No amount has been deducted from your account.',
                        style: textTheme.bodySmall
                            ?.copyWith(color: colorScheme.error),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => _retry(context, ref),
                  style: FilledButton.styleFrom(
                    backgroundColor: kPremiumIndigo,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
                  ),
                  child: const Text('Try Again'),
                ),
              ),
              const SizedBox(height: AppSizes.sm),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _retry(context, ref),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
                  ),
                  child: const Text('Change Payment Method'),
                ),
              ),
              const SizedBox(height: AppSizes.xs),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Contact support at support@lifereset.app')),
                  );
                },
                child: const Text('Contact Support'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
