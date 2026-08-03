import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../domain/entities/subscription_models.dart';
import '../controllers/checkout_controller.dart';
import '../providers/subscription_providers.dart';
import '../widgets/premium_widgets.dart';

/// Screen 7 — manage auto-renewal, cancel, and restore.
class ManageSubscriptionScreen extends ConsumerWidget {
  const ManageSubscriptionScreen({super.key});

  static final _dateFmt = DateFormat('d MMM yyyy');

  Future<void> _setAutoRenew(
      BuildContext context, WidgetRef ref, bool value) async {
    final controller = ref.read(subscriptionActionControllerProvider.notifier);
    if (!value) {
      final ok = await _confirmCancel(context);
      if (ok != true) return;
    }
    final success =
        value ? await controller.resumeAutoRenew() : await controller.cancelAutoRenew();
    if (context.mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(value
              ? 'Auto-renewal turned on.'
              : 'Auto-renewal turned off. Premium stays active until expiry.'),
        ),
      );
    }
  }

  Future<bool?> _confirmCancel(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel subscription?'),
        content: const Text(
            "You won't be charged again. Your premium features stay active "
            'until the end of your current period.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Keep Premium')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Cancel Renewal')),
        ],
      ),
    );
  }

  Future<void> _restore(BuildContext context, WidgetRef ref) async {
    final success =
        await ref.read(subscriptionActionControllerProvider.notifier).restore();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(success ? 'Subscription restored.' : 'Nothing to restore.')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final state = ref.watch(subscriptionStateProvider).valueOrNull ??
        SubscriptionState.free();
    final busy = ref.watch(subscriptionActionControllerProvider).isLoading;
    final renewal =
        state.renewalDate == null ? 'the end of your period' : _dateFmt.format(state.renewalDate!);

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Subscription')),
      body: AbsorbPointer(
        absorbing: busy,
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.md),
          children: [
            _InfoBanner(
              color: colorScheme.primary,
              icon: Icons.info_outline_rounded,
              text:
                  'Your premium access will continue until $renewal, even if you cancel now.',
            ),
            const SizedBox(height: AppSizes.md),
            Text('Actions', style: textTheme.titleMedium),
            const SizedBox(height: AppSizes.sm),
            SectionCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.autorenew_rounded),
                    title: const Text('Auto Renewal'),
                    subtitle: const Text('Automatically renew your subscription'),
                    value: state.autoRenew,
                    onChanged: busy
                        ? null
                        : (v) => _setAutoRenew(context, ref, v),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.cancel_outlined,
                        color: colorScheme.error),
                    title: const Text('Cancel Subscription'),
                    subtitle: const Text('Turn off auto renewal'),
                    enabled: !busy && state.autoRenew,
                    onTap: () => _setAutoRenew(context, ref, false),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.restore_rounded),
                    title: const Text('Restore Purchase'),
                    subtitle: const Text('Restore your subscription'),
                    enabled: !busy,
                    onTap: () => _restore(context, ref),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.md),
            _InfoBanner(
              color: const Color(0xFFE0A800),
              icon: Icons.info_outline_rounded,
              text:
                  "You won't be charged after cancellation, and your premium "
                  'features will remain active until the end of your current period.',
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner(
      {required this.color, required this.icon, required this.text});
  final Color color;
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Text(text,
                style: textTheme.bodySmall
                    ?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
          ),
        ],
      ),
    );
  }
}
