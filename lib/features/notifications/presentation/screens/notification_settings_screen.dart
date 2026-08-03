import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
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
    final current =
        ref.read(notificationPrefsProvider).valueOrNull ?? const NotificationPrefs();
    await ref
        .read(notificationsRepositoryProvider)
        .savePrefs(uid, change(current));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final prefs =
        ref.watch(notificationPrefsProvider).valueOrNull ?? const NotificationPrefs();
    final uid = ref.watch(currentUserProvider)?.id;
    final initState = ref.watch(notificationsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Notification Settings')),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.md),
        children: [
          if (initState.initialized && !initState.permissionGranted)
            Container(
              margin: const EdgeInsets.only(bottom: AppSizes.md),
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Row(
                children: [
                  Icon(Icons.notifications_off_rounded,
                      color: colorScheme.onErrorContainer),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: Text(
                      'Notifications are turned off for this device.',
                      style: textTheme.bodySmall,
                    ),
                  ),
                  TextButton(
                    onPressed: () => ref
                        .read(notificationsControllerProvider.notifier)
                        .recheckPermission(),
                    child: const Text('Enable'),
                  ),
                ],
              ),
            ),
          Text('Reminders', style: textTheme.titleMedium),
          const SizedBox(height: AppSizes.sm),
          _SettingsGroup(
            children: [
              _SwitchRow(
                icon: Icons.wb_sunny_rounded,
                title: 'Daily Reminder',
                subtitle: 'A gentle nudge to check in each day',
                value: prefs.dailyReminder,
                onChanged: (v) =>
                    _update(ref, uid, (p) => p.copyWith(dailyReminder: v)),
              ),
              _SwitchRow(
                icon: Icons.menu_book_rounded,
                title: 'Journal Reminder',
                subtitle: 'Remind me to write in my journal',
                value: prefs.journalReminder,
                onChanged: (v) =>
                    _update(ref, uid, (p) => p.copyWith(journalReminder: v)),
              ),
              _SwitchRow(
                icon: Icons.favorite_rounded,
                title: 'Mood Reminder',
                subtitle: 'Remind me to log my mood',
                value: prefs.moodReminder,
                onChanged: (v) =>
                    _update(ref, uid, (p) => p.copyWith(moodReminder: v)),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          Text('Other', style: textTheme.titleMedium),
          const SizedBox(height: AppSizes.sm),
          _SettingsGroup(
            children: [
              _SwitchRow(
                icon: Icons.campaign_rounded,
                title: 'Marketing Notification',
                subtitle: 'Product news and announcements',
                value: prefs.marketing,
                onChanged: (v) =>
                    _update(ref, uid, (p) => p.copyWith(marketing: v)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i != 0) const Divider(height: 1),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }
}
