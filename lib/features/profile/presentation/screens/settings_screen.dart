import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/localization/locale_controller.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../../../../theme/theme_controller.dart';
import '../../domain/entities/user_profile.dart';
import '../controllers/profile_controller.dart';
import '../providers/profile_providers.dart';
import '../widgets/profile_widgets.dart';
import 'profile_placeholder_screen.dart';

/// Settings & Support: functional settings (saved to Firestore and applied to
/// the app), support links, and secure logout.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const Map<String, String> _languages = {'en': 'English', 'es': 'Español'};

  ProfileController _controller(WidgetRef ref) =>
      ref.read(profileControllerProvider.notifier);

  Future<void> _pickAppearance(BuildContext context, WidgetRef ref) async {
    final choice = await showModalBottomSheet<AppearanceMode>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final mode in AppearanceMode.values)
              ListTile(
                title: Text(mode.label),
                onTap: () => Navigator.pop(ctx, mode),
              ),
          ],
        ),
      ),
    );
    if (choice == null) return;
    ref.read(themeControllerProvider.notifier).setThemeMode(_themeMode(choice));
    await _controller(ref).updateSettings(appearance: choice);
  }

  Future<void> _pickLanguage(BuildContext context, WidgetRef ref) async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final entry in _languages.entries)
              ListTile(
                title: Text(entry.value),
                onTap: () => Navigator.pop(ctx, entry.key),
              ),
          ],
        ),
      ),
    );
    if (choice == null) return;
    ref.read(localeControllerProvider.notifier).setLocale(Locale(choice));
    await _controller(ref).updateSettings(language: choice);
  }

  ThemeMode _themeMode(AppearanceMode mode) {
    switch (mode) {
      case AppearanceMode.light:
        return ThemeMode.light;
      case AppearanceMode.dark:
        return ThemeMode.dark;
      case AppearanceMode.system:
        return ThemeMode.system;
    }
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You will need to sign in again.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    // Clear cached profile data, then sign out (the router returns to login).
    ref.invalidate(profileProvider);
    await ref.read(authControllerProvider.notifier).signOut();
  }

  void _push(BuildContext context, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ProfilePlaceholderScreen(title: title)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final profile = ref.watch(profileProvider).valueOrNull;
    final langLabel = _languages[profile?.language] ?? 'English';

    return Scaffold(
      appBar: AppBar(title: const Text('Settings & Support')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.md),
          children: [
            const SectionHeader('Settings'),
            PCard(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
              child: Column(
                children: [
                  SettingTile(
                    icon: Icons.notifications_outlined,
                    title: 'Notification Preferences',
                    showChevron: false,
                    trailing: Switch(
                      value: profile?.notificationsEnabled ?? true,
                      onChanged: (v) =>
                          _controller(ref).updateSettings(notificationsEnabled: v),
                    ),
                  ),
                  SettingTile(
                    icon: Icons.brightness_6_outlined,
                    title: 'App Appearance',
                    trailing: Text(profile?.appearance.label ?? 'System'),
                    onTap: () => _pickAppearance(context, ref),
                  ),
                  SettingTile(
                    icon: Icons.language_rounded,
                    title: 'Language',
                    trailing: Text(langLabel),
                    onTap: () => _pickLanguage(context, ref),
                  ),
                  SettingTile(
                    icon: Icons.alarm_rounded,
                    title: 'Reminders',
                    showChevron: false,
                    trailing: Switch(
                      value: profile?.remindersEnabled ?? false,
                      onChanged: (v) =>
                          _controller(ref).updateSettings(remindersEnabled: v),
                    ),
                  ),
                ],
              ),
            ),
            const SectionHeader('Support'),
            PCard(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
              child: Column(
                children: [
                  SettingTile(
                    icon: Icons.help_outline_rounded,
                    title: 'Help Center',
                    onTap: () => _push(context, 'Help Center'),
                  ),
                  SettingTile(
                    icon: Icons.mail_outline_rounded,
                    title: 'Contact Support',
                    onTap: () => _push(context, 'Contact Support'),
                  ),
                  SettingTile(
                    icon: Icons.forum_outlined,
                    title: 'FAQs',
                    onTap: () => _push(context, 'FAQs'),
                  ),
                  SettingTile(
                    icon: Icons.description_outlined,
                    title: 'Terms of Service',
                    onTap: () => _push(context, 'Terms of Service'),
                  ),
                  SettingTile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    onTap: () => _push(context, 'Privacy Policy'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.lg),
            OutlinedButton.icon(
              onPressed: () => _logout(context, ref),
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.error,
                minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
              ),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Log Out'),
            ),
          ],
        ),
      ),
    );
  }
}
