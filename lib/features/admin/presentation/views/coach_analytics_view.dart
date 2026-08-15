import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../home/presentation/widgets/home_style.dart';
import '../providers/admin_providers.dart';
import '../widgets/admin_widgets.dart';

/// Read-only AI Coach usage analytics. Privacy-preserving: it reports only
/// aggregate conversation counts and never exposes any conversation content,
/// which stays private to each user under Firestore rules.
class CoachAnalyticsView extends ConsumerWidget {
  const CoachAnalyticsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final c = ref.watch(coachAnalyticsProvider).valueOrNull;

    return ListView(
      padding: const EdgeInsets.all(AppSizes.md),
      children: [
        MetricGrid(
          tiles: [
            MetricTile(
                icon: Icons.forum_rounded,
                value: '${c?.totalConversations ?? 0}',
                label: 'Total Conversations',
                color: const Color(0xFF7C4DFF)),
            MetricTile(
                icon: Icons.bolt_rounded,
                value: '${c?.conversations7d ?? 0}',
                label: 'Started (7 days)',
                color: colorScheme.tertiary),
            MetricTile(
                icon: Icons.calendar_month_rounded,
                value: '${c?.conversations30d ?? 0}',
                label: 'Started (30 days)',
                color: const Color(0xFF2E9E63)),
            MetricTile(
                icon: Icons.groups_rounded,
                value: (c?.avgPerUser ?? 0).toStringAsFixed(1),
                label: 'Avg per User'),
          ],
        ),
        const SizedBox(height: AppSizes.md),
        ACard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.lock_outline_rounded,
                  size: 18, color: HomeStyle.inkSoft),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Text(
                  'Conversation content is private to each user and is never '
                  'shown here. These metrics are aggregate counts only.',
                  style: textTheme.bodySmall
                      ?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
