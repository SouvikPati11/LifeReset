import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../domain/entities/app_notification.dart';

/// Visual mapping (icon + accent colour) for each notification type.
({IconData icon, Color color}) notificationVisual(AppNotificationType type) {
  switch (type) {
    case AppNotificationType.dailyReminder:
      return (icon: Icons.wb_sunny_rounded, color: const Color(0xFFF5A623));
    case AppNotificationType.recoveryReminder:
      return (icon: Icons.self_improvement_rounded, color: const Color(0xFF7C4DFF));
    case AppNotificationType.journalReminder:
      return (icon: Icons.menu_book_rounded, color: const Color(0xFF2E9E63));
    case AppNotificationType.moodReminder:
      return (icon: Icons.favorite_rounded, color: const Color(0xFFE0576B));
    case AppNotificationType.trialEnding:
      return (icon: Icons.hourglass_bottom_rounded, color: const Color(0xFFE0A800));
    case AppNotificationType.subscriptionReminder:
      return (icon: Icons.workspace_premium_rounded, color: const Color(0xFF3D9BE9));
    case AppNotificationType.announcement:
      return (icon: Icons.campaign_rounded, color: const Color(0xFF6C63FF));
  }
}

/// Short relative time label, e.g. "just now", "3h", "2d".
String relativeTime(DateTime? time) {
  if (time == null) return '';
  final diff = DateTime.now().difference(time);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m';
  if (diff.inHours < 24) return '${diff.inHours}h';
  if (diff.inDays < 7) return '${diff.inDays}d';
  final weeks = (diff.inDays / 7).floor();
  if (weeks < 5) return '${weeks}w';
  return '${(diff.inDays / 30).floor()}mo';
}

/// A single inbox row.
class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final visual = notificationVisual(notification.type);
    final unread = !notification.isRead;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: unread
              ? colorScheme.primary.withValues(alpha: 0.06)
              : colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: visual.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Icon(visual.icon, size: 20, color: visual.color),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight:
                                unread ? FontWeight.w700 : FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppSizes.sm),
                      Text(
                        relativeTime(notification.createdAt),
                        style: textTheme.labelSmall
                            ?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    notification.body,
                    style: textTheme.bodySmall
                        ?.copyWith(color: colorScheme.onSurfaceVariant),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (unread) ...[
              const SizedBox(width: AppSizes.sm),
              Container(
                width: 9,
                height: 9,
                margin: const EdgeInsets.only(top: 6),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
