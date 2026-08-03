import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../widgets/profile_widgets.dart';
import 'choose_plan_screen.dart';
import 'profile_placeholder_screen.dart';

/// Payment Methods: current method, billing history and manage subscription.
///
/// Navigation only — no payment is processed. No card data is fabricated;
/// methods appear once a real payment integration is added.
class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Methods'),
        actions: [
          TextButton.icon(
            onPressed: () => _push(context,
                const ProfilePlaceholderScreen(title: 'Add Payment Method')),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add'),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.md),
          children: [
            PCard(
              child: Column(
                children: [
                  Icon(Icons.credit_card_off_outlined,
                      size: 40, color: colorScheme.onSurfaceVariant),
                  const SizedBox(height: AppSizes.sm),
                  Text('No payment method yet', style: textTheme.titleSmall),
                  const SizedBox(height: 2),
                  Text(
                    'Add one when you upgrade — you won’t be charged during your '
                    'free trial.',
                    textAlign: TextAlign.center,
                    style: textTheme.bodySmall
                        ?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.md),
            PCard(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
              child: Column(
                children: [
                  SettingTile(
                    icon: Icons.receipt_long_outlined,
                    title: 'Billing History',
                    subtitle: 'View all your payments and invoices',
                    onTap: () => _push(context,
                        const ProfilePlaceholderScreen(title: 'Billing History')),
                  ),
                  SettingTile(
                    icon: Icons.tune_rounded,
                    title: 'Manage Subscription',
                    subtitle: 'Cancel or update your subscription',
                    onTap: () => _push(context, const ChoosePlanScreen()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.lg),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline_rounded,
                      size: 14, color: colorScheme.onSurfaceVariant),
                  const SizedBox(width: AppSizes.xs),
                  Text('All payments are secure and encrypted.',
                      style: textTheme.labelSmall
                          ?.copyWith(color: colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
