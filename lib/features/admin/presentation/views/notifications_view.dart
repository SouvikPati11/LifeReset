import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../domain/entities/admin_models.dart';
import '../controllers/admin_controllers.dart';
import '../providers/admin_providers.dart';
import '../widgets/admin_forms.dart';
import '../widgets/admin_widgets.dart';

class NotificationsView extends ConsumerWidget {
  const NotificationsView({super.key});

  IconData _iconFor(NotificationType type) {
    switch (type) {
      case NotificationType.dailyReminder:
        return Icons.alarm_rounded;
      case NotificationType.recoveryReminder:
        return Icons.self_improvement_rounded;
      case NotificationType.subscriptionReminder:
        return Icons.workspace_premium_rounded;
      case NotificationType.announcement:
        return Icons.campaign_rounded;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(adminNotificationsProvider);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Row(
            children: [
              Text('Notifications', style: textTheme.titleLarge),
              const Spacer(),
              FilledButton.icon(
                onPressed: () => showNotificationForm(context),
                icon: const Icon(Icons.add_rounded),
                label: const Text('New'),
              ),
            ],
          ),
        ),
        Expanded(
          child: async.when(
            loading: () => const LoadingView(),
            error: (_, __) => const Center(child: Text('Could not load')),
            data: (items) {
              if (items.isEmpty) {
                return const Center(child: Text('No notifications scheduled.'));
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                itemCount: items.length,
                itemBuilder: (context, i) {
                  final n = items[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.sm),
                    child: ACard(
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor:
                                colorScheme.primaryContainer.withValues(alpha: 0.5),
                            child: Icon(_iconFor(n.type),
                                size: 18, color: colorScheme.primary),
                          ),
                          const SizedBox(width: AppSizes.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(n.title, style: textTheme.titleSmall),
                                Text(
                                  n.message,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: AppSizes.xs),
                                Row(
                                  children: [
                                    StatusChip(
                                      label: n.audience.label,
                                      color: colorScheme.tertiary,
                                    ),
                                    const SizedBox(width: AppSizes.sm),
                                    if (n.scheduleAt != null)
                                      Text(
                                        DateFormat('MMM d, y · h:mm a')
                                            .format(n.scheduleAt!),
                                        style: textTheme.labelSmall,
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Delete',
                            icon: const Icon(Icons.delete_outline_rounded),
                            onPressed: () async {
                              if (await confirmDelete(context)) {
                                await ref
                                    .read(adminWriteControllerProvider.notifier)
                                    .remove('notifications', n.id);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
