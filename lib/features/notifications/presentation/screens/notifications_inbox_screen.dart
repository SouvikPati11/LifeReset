import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/ls_kit.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../../home/presentation/widgets/home_style.dart';
import '../../domain/entities/app_notification.dart';
import '../providers/notifications_providers.dart';
import '../widgets/notification_tile.dart';
import 'notification_settings_screen.dart';

/// Notification inbox — a chronological activity feed grouped by day, with
/// unread items visually distinct and swipe-to-delete.
class NotificationsInboxScreen extends ConsumerWidget {
  const NotificationsInboxScreen({super.key});

  static String _bucketOf(DateTime? t) {
    if (t == null) return 'Earlier';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(t.year, t.month, t.day);
    final diff = today.difference(d).inDays;
    if (diff <= 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return 'This Week';
    return 'Earlier';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(inboxProvider);
    final unread = ref.watch(unreadCountProvider);
    final uid = ref.watch(currentUserProvider)?.id;
    final repo = ref.read(notificationsRepositoryProvider);

    void openSettings() => Navigator.of(context).push(
          MaterialPageRoute(
              builder: (_) => const NotificationSettingsScreen()),
        );

    return Scaffold(
      backgroundColor: HomeStyle.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            LsHeader(
              title: 'Notifications',
              subtitle:
                  unread > 0 ? '$unread unread' : "You're all caught up",
              onBack: () => Navigator.of(context).maybePop(),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (unread > 0) ...[
                    LsSquareButton(
                      icon: Icons.done_all_rounded,
                      onTap: () {
                        if (uid != null) repo.markAllRead(uid);
                      },
                    ),
                    const SizedBox(width: AppSizes.sm),
                  ],
                  _OverflowMenu(
                    onSettings: openSettings,
                    onClearAll: () {
                      if (uid != null) repo.clearAll(uid);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.md),
            Expanded(
              child: async.when(
                loading: () => const LsLoader(),
                error: (_, __) => LsErrorState(
                  title: 'Could not load notifications',
                  onRetry: () => ref.invalidate(inboxProvider),
                ),
                data: (items) {
                  if (items.isEmpty) {
                    return const LsEmpty(
                      icon: Icons.notifications_none_rounded,
                      title: "You're all caught up",
                      message:
                          'New reminders and updates will appear here.',
                    );
                  }
                  return RefreshIndicator(
                    color: HomeStyle.primary,
                    onRefresh: () async {
                      ref.invalidate(inboxProvider);
                      await Future<void>.delayed(
                          const Duration(milliseconds: 400));
                    },
                    child: _Feed(
                      items: items,
                      bucketOf: _bucketOf,
                      onTap: (n) {
                        if (uid != null && !n.isRead) repo.markRead(uid, n.id);
                      },
                      onDismiss: (n) {
                        if (uid != null) repo.delete(uid, n.id);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Feed extends StatelessWidget {
  const _Feed({
    required this.items,
    required this.bucketOf,
    required this.onTap,
    required this.onDismiss,
  });

  final List<AppNotification> items;
  final String Function(DateTime?) bucketOf;
  final ValueChanged<AppNotification> onTap;
  final ValueChanged<AppNotification> onDismiss;

  @override
  Widget build(BuildContext context) {
    // Build a flat list of section headers + tiles, preserving the newest-first
    // order the repository returns.
    final children = <Widget>[];
    String? current;
    for (final n in items) {
      final bucket = bucketOf(n.createdAt);
      if (bucket != current) {
        current = bucket;
        children.add(Padding(
          padding: EdgeInsets.only(
            top: children.isEmpty ? 0 : AppSizes.lg,
            bottom: AppSizes.sm,
          ),
          child: LsGroupLabel(bucket),
        ));
      }
      children.add(Padding(
        padding: const EdgeInsets.only(bottom: AppSizes.sm),
        child: Dismissible(
          key: ValueKey(n.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: AppSizes.lg),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            ),
            child: const Icon(Icons.delete_outline_rounded,
                color: Color(0xFFB91C1C)),
          ),
          onDismissed: (_) => onDismiss(n),
          child: NotificationTile(
            notification: n,
            onTap: () => onTap(n),
          ),
        ),
      ));
    }

    return ListView(
      padding:
          const EdgeInsets.fromLTRB(AppSizes.lg, 0, AppSizes.lg, AppSizes.xl),
      children: children,
    );
  }
}

class _OverflowMenu extends StatelessWidget {
  const _OverflowMenu({required this.onSettings, required this.onClearAll});

  final VoidCallback onSettings;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'More',
      color: HomeStyle.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      onSelected: (value) {
        if (value == 'settings') onSettings();
        if (value == 'clear') onClearAll();
      },
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'settings', child: Text('Notification settings')),
        PopupMenuItem(value: 'clear', child: Text('Clear all')),
      ],
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: HomeStyle.lavender,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        child: const Icon(Icons.more_vert_rounded,
            color: HomeStyle.primary, size: 22),
      ),
    );
  }
}
