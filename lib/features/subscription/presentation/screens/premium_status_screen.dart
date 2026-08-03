import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../domain/entities/subscription_models.dart';
import '../providers/subscription_providers.dart';
import '../widgets/premium_widgets.dart';
import 'billing_history_screen.dart';
import 'manage_subscription_screen.dart';

/// Screen 6 — active subscription overview.
class PremiumStatusScreen extends ConsumerWidget {
  const PremiumStatusScreen({super.key});

  static final _dateFmt = DateFormat('d MMM yyyy');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final state = ref.watch(subscriptionStateProvider).valueOrNull ??
        SubscriptionState.free();

    final renewal =
        state.renewalDate == null ? '—' : _dateFmt.format(state.renewalDate!);
    final started =
        state.startedAt == null ? '—' : _dateFmt.format(state.startedAt!);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Premium'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _openManage(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.md),
        children: [
          // Header card.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSizes.lg),
            decoration: BoxDecoration(
              color: kPremiumIndigo,
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            ),
            child: Column(
              children: [
                const CrownBadge(size: 56),
                const SizedBox(height: AppSizes.sm),
                Text('LifeReset Premium',
                    style: textTheme.titleLarge?.copyWith(color: Colors.white)),
                const SizedBox(height: AppSizes.xs),
                StatusPill(
                  label: state.isOnTrial ? 'Trial' : state.status.label,
                  color: kSuccessGreen,
                ),
                const SizedBox(height: AppSizes.sm),
                Text(
                  state.status == SubscriptionStatus.cancelled
                      ? 'Access until $renewal'
                      : 'Renews on $renewal',
                  style: textTheme.bodySmall
                      ?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.md),
          Text('Subscription Details', style: textTheme.titleMedium),
          const SizedBox(height: AppSizes.sm),
          SectionCard(
            child: Column(
              children: [
                const DetailRow(label: 'Plan', value: 'Premium Monthly'),
                DetailRow(
                    label: 'Price',
                    value:
                        '${SubscriptionPlanConfig.priceLabel} / ${SubscriptionPlanConfig.periodLabel}'),
                DetailRow(label: 'Started', value: started),
                DetailRow(
                    label: state.status == SubscriptionStatus.cancelled
                        ? 'Access until'
                        : 'Next renewal',
                    value: renewal),
                const DetailRow(label: 'Payment Method', value: 'Razorpay'),
                DetailRow(
                  label: 'Status',
                  value: '',
                  valueWidget: StatusPill(
                    label: state.status.label,
                    color: state.status == SubscriptionStatus.cancelled
                        ? const Color(0xFFE0A800)
                        : kSuccessGreen,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.md),
          FilledButton.tonalIcon(
            onPressed: () => _openManage(context),
            icon: const Icon(Icons.tune_rounded),
            label: const Text('Manage Subscription'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const BillingHistoryScreen()),
            ),
            icon: const Icon(Icons.receipt_long_rounded),
            label: const Text('Billing History'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
            ),
          ),
          const SizedBox(height: AppSizes.md),
          SectionCard(
            color: colorScheme.primaryContainer.withValues(alpha: 0.3),
            child: Row(
              children: [
                Icon(Icons.support_agent_rounded, color: colorScheme.primary),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Need help?', style: textTheme.titleSmall),
                      Text('Contact our support team anytime.',
                          style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openManage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ManageSubscriptionScreen()),
    );
  }
}
