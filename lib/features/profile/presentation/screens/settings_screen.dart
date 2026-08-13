import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/localization/locale_controller.dart';
import '../../../../shared/widgets/ls_kit.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../../../home/presentation/widgets/home_style.dart';
import '../../../../theme/theme_controller.dart';
import '../../domain/entities/user_profile.dart';
import '../controllers/profile_controller.dart';
import '../providers/profile_providers.dart';
import 'profile_placeholder_screen.dart';

/// Settings & Support: functional settings (saved to Firestore and applied to
/// the app), support links, and secure logout.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const Map<String, String> _languages = {'en': 'English', 'es': 'Español'};

  ProfileController _controller(WidgetRef ref) =>
      ref.read(profileControllerProvider.notifier);

  Future<void> _pickAppearance(BuildContext context, WidgetRef ref) async {
    final choice = await _pickOption<AppearanceMode>(
      context,
      title: 'App Appearance',
      options: [
        for (final mode in AppearanceMode.values) (mode, mode.label),
      ],
    );
    if (choice == null) return;
    ref.read(themeControllerProvider.notifier).setThemeMode(_themeMode(choice));
    await _controller(ref).updateSettings(appearance: choice);
  }

  Future<void> _pickLanguage(BuildContext context, WidgetRef ref) async {
    final choice = await _pickOption<String>(
      context,
      title: 'Language',
      options: [for (final e in _languages.entries) (e.key, e.value)],
    );
    if (choice == null) return;
    ref.read(localeControllerProvider.notifier).setLocale(Locale(choice));
    await _controller(ref).updateSettings(language: choice);
  }

  Future<T?> _pickOption<T>(
    BuildContext context, {
    required String title,
    required List<(T, String)> options,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: HomeStyle.card,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppSizes.radiusLg)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSizes.lg, AppSizes.lg, AppSizes.lg, AppSizes.sm),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: HomeStyle.ink,
                ),
              ),
            ),
            for (final (value, label) in options)
              ListTile(
                title: Text(label,
                    style: const TextStyle(color: HomeStyle.ink)),
                onTap: () => Navigator.pop(ctx, value),
              ),
            const SizedBox(height: AppSizes.sm),
          ],
        ),
      ),
    );
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
        backgroundColor: HomeStyle.card,
        title: const Text('Log out?'),
        content: const Text('You will need to sign in again.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFB91C1C)),
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
    final profile = ref.watch(profileProvider).valueOrNull;
    final langLabel = _languages[profile?.language] ?? 'English';

    return Scaffold(
      backgroundColor: HomeStyle.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            LsHeader(
              title: 'Settings',
              subtitle: 'Preferences and support',
              onBack: () => Navigator.of(context).maybePop(),
            ),
            const SizedBox(height: AppSizes.md),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                    AppSizes.lg, 0, AppSizes.lg, AppSizes.xl),
                children: [
                  const LsGroupLabel('Preferences'),
                  LsGroup(
                    children: [
                      LsRow(
                        icon: Icons.notifications_outlined,
                        title: 'Notifications',
                        showChevron: false,
                        trailing: _Toggle(
                          value: profile?.notificationsEnabled ?? true,
                          onChanged: (v) => _controller(ref)
                              .updateSettings(notificationsEnabled: v),
                        ),
                      ),
                      LsRow(
                        icon: Icons.brightness_6_outlined,
                        title: 'App Appearance',
                        trailing: _ValueChevron(
                            profile?.appearance.label ?? 'System'),
                        onTap: () => _pickAppearance(context, ref),
                      ),
                      LsRow(
                        icon: Icons.language_rounded,
                        title: 'Language',
                        trailing: _ValueChevron(langLabel),
                        onTap: () => _pickLanguage(context, ref),
                      ),
                      LsRow(
                        icon: Icons.alarm_rounded,
                        title: 'Daily Reminders',
                        showChevron: false,
                        trailing: _Toggle(
                          value: profile?.remindersEnabled ?? false,
                          onChanged: (v) => _controller(ref)
                              .updateSettings(remindersEnabled: v),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.lg),
                  const LsGroupLabel('Support'),
                  LsGroup(
                    children: [
                      LsRow(
                        icon: Icons.help_outline_rounded,
                        title: 'Help Center',
                        onTap: () => _push(context, 'Help Center'),
                      ),
                      LsRow(
                        icon: Icons.mail_outline_rounded,
                        title: 'Contact Support',
                        onTap: () => _push(context, 'Contact Support'),
                      ),
                      LsRow(
                        icon: Icons.forum_outlined,
                        title: 'FAQs',
                        onTap: () => _push(context, 'FAQs'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.lg),
                  const LsGroupLabel('About'),
                  LsGroup(
                    children: [
                      LsRow(
                        icon: Icons.description_outlined,
                        title: 'Terms of Service',
                        onTap: () => _push(context, 'Terms of Service'),
                      ),
                      LsRow(
                        icon: Icons.privacy_tip_outlined,
                        title: 'Privacy Policy',
                        onTap: () => _push(context, 'Privacy Policy'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.lg),
                  _LogoutButton(onTap: () => _logout(context, ref)),
                ],
              ),
            ),
          ],
        ),
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

class _ValueChevron extends StatelessWidget {
  const _ValueChevron(this.value);

  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: HomeStyle.inkSoft,
          ),
        ),
        const SizedBox(width: 4),
        const Icon(Icons.chevron_right_rounded,
            color: HomeStyle.inkSoft, size: 20),
      ],
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFEF2F2),
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(color: const Color(0xFFFECACA)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded, color: Color(0xFFB91C1C), size: 18),
              SizedBox(width: AppSizes.sm),
              Text(
                'Log Out',
                style: TextStyle(
                  color: Color(0xFFB91C1C),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
