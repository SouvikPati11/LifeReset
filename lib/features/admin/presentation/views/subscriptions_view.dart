import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../providers/admin_providers.dart';
import '../widgets/admin_charts.dart';
import '../widgets/admin_widgets.dart';

class SubscriptionsView extends ConsumerWidget {
  const SubscriptionsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final summary = ref.watch(subscriptionSummaryProvider).valueOrNull;
    final txnsAsync = ref.watch(transactionsProvider);
    final currency = NumberFormat.simpleCurrency();

    return ListView(
      padding: const EdgeInsets.all(AppSizes.md),
      children: [
        Text('Subscriptions', style: textTheme.titleLarge),
        const SizedBox(height: AppSizes.md),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSizes.md,
          crossAxisSpacing: AppSizes.md,
          childAspectRatio: 1.5,
          children: [
            MetricTile(
              icon: Icons.workspace_premium_rounded,
              value: '${summary?.premium ?? 0}',
              label: 'Premium',
              color: const Color(0xFFE0A800),
            ),
            MetricTile(
              icon: Icons.hourglass_top_rounded,
              value: '${summary?.trial ?? 0}',
              label: 'On Trial',
              color: colorScheme.tertiary,
            ),
            MetricTile(
              icon: Icons.event_busy_rounded,
              value: '${summary?.expired ?? 0}',
              label: 'Expired',
              color: colorScheme.error,
            ),
            MetricTile(
              icon: Icons.payments_rounded,
              value: currency.format(summary?.revenue ?? 0),
              label: 'Total Revenue',
              color: const Color(0xFF2E9E63),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.md),
        ACard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Subscription Mix', style: textTheme.titleMedium),
              const SizedBox(height: AppSizes.md),
              Row(
                children: [
                  AdminDonut(
                    segments: [
                      (const Color(0xFFE0A800), summary?.premium ?? 0),
                      (colorScheme.tertiary, summary?.trial ?? 0),
                      (colorScheme.outline, summary?.expired ?? 0),
                    ],
                    centerValue:
                        '${((summary?.conversionRate ?? 0) * 100).toStringAsFixed(0)}%',
                    centerLabel: 'Convert',
                  ),
                  const SizedBox(width: AppSizes.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Legend(
                            color: const Color(0xFFE0A800),
                            label: 'Premium',
                            value: '${summary?.premium ?? 0}'),
                        const SizedBox(height: AppSizes.sm),
                        _Legend(
                            color: colorScheme.tertiary,
                            label: 'Trial',
                            value: '${summary?.trial ?? 0}'),
                        const SizedBox(height: AppSizes.sm),
                        _Legend(
                            color: colorScheme.outline,
                            label: 'Expired',
                            value: '${summary?.expired ?? 0}'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.md),
        Text('Recent Transactions', style: textTheme.titleMedium),
        const SizedBox(height: AppSizes.sm),
        txnsAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(AppSizes.lg),
            child: LoadingView(),
          ),
          error: (_, __) => const Text('Could not load transactions.'),
          data: (txns) {
            if (txns.isEmpty) {
              return Text('No transactions yet.', style: textTheme.bodySmall);
            }
            return Column(
              children: [
                for (final t in txns)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.sm),
                    child: ACard(
                      child: Row(
                        children: [
                          const Icon(Icons.receipt_long_rounded, size: 20),
                          const SizedBox(width: AppSizes.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    t.userName.isEmpty
                                        ? 'Unknown user'
                                        : t.userName,
                                    style: textTheme.bodyMedium),
                                Text(
                                  '${t.plan}'
                                  '${t.date == null ? '' : ' · ${DateFormat('MMM d, y').format(t.date!)}'}',
                                  style: textTheme.labelSmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(currency.format(t.amount),
                              style: textTheme.titleSmall),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label, required this.value});
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSizes.sm),
        Expanded(child: Text(label, style: textTheme.bodyMedium)),
        Text(value, style: textTheme.titleSmall),
      ],
    );
  }
}
