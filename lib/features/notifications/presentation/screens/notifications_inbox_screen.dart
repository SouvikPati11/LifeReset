import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../providers/notifications_providers.dart';
import '../widgets/notification_tile.dart';
import 'notification_settings_screen.dart';

/// Notification inbox — the list of received notifications.
class NotificationsInboxScreen extends ConsumerWidget {
  const NotificationsInboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final async = ref.watch(inboxProvider);
    final uid = ref.watch(currentUserProvider)?.id;
    final repo = ref.read(notificationsRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => const NotificationSettingsScreen()),
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (uid == null) return;
              if (value == 'read') repo.markAllRead(uid);
              if (value == 'clear') repo.clearAll(uid);
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'read', child: Text('Mark all as read')),
              PopupMenuItem(value: 'clear', child: Text('Clear all')),
            ],
          ),
        ],
      ),
      body: async.when(
        loading: () => const LoadingView(),
        error: (_, __) =>
            const Center(child: Text('Could not load notifications')),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_off_outlined,
                      size: 56, color: colorScheme.outline),
                  const SizedBox(height: AppSizes.md),
                  Text('No notifications yet', style: textTheme.titleMedium),
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    "You're all caught up.",
                    style: textTheme.bodySmall
                        ?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSizes.md),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSizes.sm),
            itemBuilder: (context, i) {
              final n = items[i];
              return Dismissible(
                key: ValueKey(n.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: AppSizes.lg),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  ),
                  child: Icon(Icons.delete_outline_rounded,
                      color: colorScheme.onErrorContainer),
                ),
                onDismissed: (_) {
                  if (uid != null) repo.delete(uid, n.id);
                },
                child: NotificationTile(
                  notification: n,
                  onTap: () {
                    if (uid != null && !n.isRead) repo.markRead(uid, n.id);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
