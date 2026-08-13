import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/ls_kit.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../../home/presentation/widgets/home_style.dart';
import '../../domain/entities/app_notification.dart';
import '../controllers/notifications_controller.dart';
import '../providers/notifications_providers.dart';

/// Notification preferences — toggles saved to Firestore and honoured by the
/// sending Cloud Functions.
class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  Future<void> _update(
    WidgetRef ref,
    String? uid,
    NotificationPrefs Function(NotificationPrefs) change,
  ) async {
    if (uid == null) return;
    final current = ref.read(notificationPrefsProvider).valueOrNull ??
        const NotificationPrefs();
    await ref
        .read(notificationsRepositoryProvider)
        .savePrefs(uid, change(current));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(notificationPrefsProvider).valueOrNull ??
        const NotificationPrefs();
    final uid = ref.watch(currentUserProvider)?.id;
    final initState = ref.watch(notificationsControllerProvider);

    return Scaffold(
      backgroundColor: HomeStyle.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            LsHeader(
              title: 'Notification Settings',
              subtitle: 'Choose what reaches you',
              onBack: () => Navigator.of(context).maybePop(),
            ),
            const SizedBox(height: AppSizes.md),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                    AppSizes.lg, 0, AppSizes.lg, AppSizes.xl),
                children: [
                  if (initState.initialized && !initState.permissionGranted)
                    _PermissionBanner(
                      onEnable: () => ref
                          .read(notificationsControllerProvider.notifier)
                          .recheckPermission(),
                    ),
                  const LsGroupLabel('Reminders'),
                  LsGroup(
                    children: [
                      LsRow(
                        icon: Icons.wb_sunny_rounded,
                        iconColor: const Color(0xFFF59E0B),
                        title: 'Daily Reminder',
                        subtitle: 'A gentle nudge to check in each day',
                        showChevron: false,
                        trailing: _Toggle(
                          value: prefs.dailyReminder,
                          onChanged: (v) =>
                              _update(ref, uid, (p) => p.copyWith(dailyReminder: v)),
                        ),
                      ),
                      LsRow(
                        icon: Icons.menu_book_rounded,
                        iconColor: const Color(0xFF10B981),
                        title: 'Journal Reminder',
                        subtitle: 'Remind me to write in my journal',
                        showChevron: false,
                        trailing: _Toggle(
                          value: prefs.journalReminder,
                          onChanged: (v) => _update(
                              ref, uid, (p) => p.copyWith(journalReminder: v)),
                        ),
                      ),
                      LsRow(
                        icon: Icons.favorite_rounded,
                        iconColor: const Color(0xFFE0576B),
                        title: 'Mood Reminder',
                        subtitle: 'Remind me to log my mood',
                        showChevron: false,
                        trailing: _Toggle(
                          value: prefs.moodReminder,
                          onChanged: (v) =>
                              _update(ref, uid, (p) => p.copyWith(moodReminder: v)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.lg),
                  const LsGroupLabel('Other'),
                  LsGroup(
                    children: [
                      LsRow(
                        icon: Icons.campaign_rounded,
                        title: 'Product Updates',
                        subtitle: 'News and announcements',
                        showChevron: false,
                        trailing: _Toggle(
                          value: prefs.marketing,
                          onChanged: (v) =>
                              _update(ref, uid, (p) => p.copyWith(marketing: v)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PermissionBanner extends StatelessWidget {
  const _PermissionBanner({required this.onEnable});

  final VoidCallback onEnable;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.lg),
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications_off_rounded, color: Color(0xFFB91C1C)),
          const SizedBox(width: AppSizes.sm),
          const Expanded(
            child: Text(
              'Notifications are turned off for this device.',
              style: TextStyle(fontSize: 13, color: Color(0xFF7F1D1D)),
            ),
          ),
          TextButton(
            onPressed: onEnable,
            style: TextButton.styleFrom(foregroundColor: HomeStyle.primary),
            child: const Text('Enable'),
          ),
        ],
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: value,
      onChanged: onChanged,
      activeThumbColor: Colors.white,
      activeTrackColor: HomeStyle.primary,
      inactiveThumbColor: Colors.white,
      inactiveTrackColor: HomeStyle.border,
    );
  }
}
