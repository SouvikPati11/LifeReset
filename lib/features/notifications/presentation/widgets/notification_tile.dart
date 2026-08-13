import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../home/presentation/widgets/home_style.dart';
import '../../domain/entities/app_notification.dart';

/// Visual mapping (icon + accent colour) for each notification type.
({IconData icon, Color color}) notificationVisual(AppNotificationType type) {
  switch (type) {
    case AppNotificationType.dailyReminder:
      return (icon: Icons.wb_sunny_rounded, color: const Color(0xFFF59E0B));
    case AppNotificationType.recoveryReminder:
      return (icon: Icons.self_improvement_rounded, color: HomeStyle.primary);
    case AppNotificationType.journalReminder:
      return (icon: Icons.menu_book_rounded, color: const Color(0xFF10B981));
    case AppNotificationType.moodReminder:
      return (icon: Icons.favorite_rounded, color: const Color(0xFFE0576B));
    case AppNotificationType.trialEnding:
      return (icon: Icons.hourglass_bottom_rounded, color: const Color(0xFFE0A800));
    case AppNotificationType.subscriptionReminder:
      return (icon: Icons.workspace_premium_rounded, color: const Color(0xFF3D9BE9));
    case AppNotificationType.announcement:
      return (icon: Icons.campaign_rounded, color: HomeStyle.primary);
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

/// A single inbox row. Unread rows use a lavender surface with a purple dot and
/// bolder title; read rows are visually quieter (plain white).
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
    final visual = notificationVisual(notification.type);
    final unread = !notification.isRead;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: unread ? HomeStyle.lavenderLight : HomeStyle.card,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            border: Border.all(
              color: unread ? HomeStyle.lavender : HomeStyle.border,
            ),
            boxShadow: unread ? null : HomeStyle.softShadow,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: visual.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
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
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight:
                                  unread ? FontWeight.w800 : FontWeight.w600,
                              color: unread ? HomeStyle.ink : HomeStyle.inkSoft,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSizes.sm),
                        Text(
                          relativeTime(notification.createdAt),
                          style: const TextStyle(
                            fontSize: 11,
                            color: HomeStyle.inkSoft,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      notification.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: HomeStyle.inkSoft,
                        height: 1.35,
                      ),
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
                  decoration: const BoxDecoration(
                    color: HomeStyle.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
