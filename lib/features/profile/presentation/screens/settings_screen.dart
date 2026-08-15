import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/localization/locale_controller.dart';
import '../../../../shared/widgets/ls_kit.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../../../home/presentation/widgets/home_style.dart';
import '../../../support/presentation/screens/contact_support_screen.dart';
import '../../../support/presentation/screens/faq_screen.dart';
import '../../../support/presentation/screens/help_center_screen.dart';
import '../../../support/presentation/screens/terms_screen.dart';
import '../../domain/entities/user_profile.dart';
import '../controllers/profile_controller.dart';
import '../providers/profile_providers.dart';
import 'profile_placeholder_screen.dart';

/// Settings & Support: functional settings (saved to Firestore and applied to
/// the app), support links, and secure logout.
///
/// Appearance is fixed to **Light** — the picker is intentionally removed and a
/// stored `system`/`dark` value is migrated to `light` on open.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  static const Map<String, String> _languages = {'en': 'English', 'es': 'Español'};
  bool _migrated = false;

  ProfileController _controller() =>
      ref.read(profileControllerProvider.notifier);

  /// Reset a legacy `system`/`dark` appearance preference to `light`, once.
  void _migrateAppearance(UserProfile? profile) {
    if (_migrated || profile == null) return;
    if (profile.appearance != AppearanceMode.light) {
      _migrated = true;
      _controller().updateSettings(appearance: AppearanceMode.light);
    }
  }

  Future<void> _pickLanguage() async {
    final choice = await _pickOption<String>(
      title: 'Language',
      options: [for (final e in _languages.entries) (e.key, e.value)],
    );
    if (choice == null) return;
    ref.read(localeControllerProvider.notifier).setLocale(Locale(choice));
    await _controller().updateSettings(language: choice);
  }

  Future<T?> _pickOption<T>({
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

  Future<void> _logout() async {
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

  void _open(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  void _pushPlaceholder(String title) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ProfilePlaceholderScreen(title: title)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider).valueOrNull;
    _migrateAppearance(profile);
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
                          onChanged: (v) => _controller()
                              .updateSettings(notificationsEnabled: v),
                        ),
                      ),
                      const LsRow(
                        icon: Icons.brightness_6_outlined,
                        title: 'App Appearance',
                        showChevron: false,
                        trailing: Text(
                          'Light',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: HomeStyle.inkSoft,
                          ),
                        ),
                      ),
                      LsRow(
                        icon: Icons.language_rounded,
                        title: 'Language',
                        trailing: _ValueChevron(langLabel),
                        onTap: _pickLanguage,
                      ),
                      LsRow(
                        icon: Icons.alarm_rounded,
                        title: 'Daily Reminders',
                        showChevron: false,
                        trailing: _Toggle(
                          value: profile?.remindersEnabled ?? false,
                          onChanged: (v) => _controller()
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
                        onTap: () => _open(const HelpCenterScreen()),
                      ),
                      LsRow(
                        icon: Icons.mail_outline_rounded,
                        title: 'Contact Support',
                        onTap: () => _open(const ContactSupportScreen()),
                      ),
                      LsRow(
                        icon: Icons.forum_outlined,
                        title: 'FAQs',
                        onTap: () => _open(const FaqScreen()),
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
                        onTap: () => _open(const TermsScreen()),
                      ),
                      LsRow(
                        icon: Icons.privacy_tip_outlined,
                        title: 'Privacy Policy',
                        onTap: () => _pushPlaceholder('Privacy Policy'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.lg),
                  _LogoutButton(onTap: _logout),
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
