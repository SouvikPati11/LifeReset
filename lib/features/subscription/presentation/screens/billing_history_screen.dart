import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../providers/subscription_providers.dart';
import '../widgets/premium_widgets.dart';

/// Billing history — the user's own transactions (paid cycles + free trial).
class BillingHistoryScreen extends ConsumerWidget {
  const BillingHistoryScreen({super.key});

  static final _dateFmt = DateFormat('d MMM yyyy');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final async = ref.watch(transactionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Billing History')),
      body: async.when(
        loading: () => const LoadingView(),
        error: (_, __) => const Center(child: Text('Could not load history')),
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('No transactions yet.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppSizes.md),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final t = items[i];
              final isTrial = t.type == 'trial';
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.sm),
                child: SectionCard(
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor:
                            colorScheme.primaryContainer.withValues(alpha: 0.5),
                        child: Icon(
                          isTrial
                              ? Icons.card_giftcard_rounded
                              : Icons.workspace_premium_rounded,
                          size: 18,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: AppSizes.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(isTrial ? 'Free Trial' : 'Premium Monthly',
                                style: textTheme.titleSmall),
                            Text(
                              t.createdAt == null
                                  ? ''
                                  : _dateFmt.format(t.createdAt!),
                              style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(t.amountLabel, style: textTheme.titleSmall),
                          StatusPill(
                            label: t.status,
                            color: t.status == 'success'
                                ? kSuccessGreen
                                : colorScheme.error,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
