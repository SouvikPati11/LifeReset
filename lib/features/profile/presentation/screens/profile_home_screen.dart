import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../domain/entities/user_profile.dart';
import '../providers/profile_providers.dart';
import '../widgets/profile_widgets.dart';
import 'edit_profile_screen.dart';
import 'payment_methods_screen.dart';
import 'profile_placeholder_screen.dart';
import 'settings_screen.dart';
import 'subscription_screen.dart';

/// My Profile: account overview, subscription status and quick actions.
class ProfileHomeScreen extends ConsumerWidget {
  const ProfileHomeScreen({super.key});

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: profileAsync.when(
          loading: () => const LoadingView(),
          error: (_, __) => const Center(child: Text('Could not load profile')),
          data: (profile) => ListView(
            padding: const EdgeInsets.all(AppSizes.md),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('My Profile', style: textTheme.headlineSmall),
                        Text(
                          'Manage your account and preferences',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton.filledTonal(
                    onPressed: () =>
                        _push(context, const ProfilePlaceholderScreen(title: 'Notifications')),
                    icon: const Icon(Icons.notifications_none_rounded),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.md),
              _ProfileCard(
                profile: profile,
                onEdit: () => _push(context, EditProfileScreen(profile: profile)),
              ),
              const SizedBox(height: AppSizes.lg),
              Row(
                children: [
                  Text('Subscription Status', style: textTheme.titleMedium),
                  const Spacer(),
                  TextButton(
                    onPressed: () => _push(context, const SubscriptionScreen()),
                    child: const Text('View Details'),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.sm),
              _SubscriptionStatusCard(profile: profile),
              const SizedBox(height: AppSizes.lg),
              Text('Quick Actions', style: textTheme.titleMedium),
              const SizedBox(height: AppSizes.sm),
              Row(
                children: [
                  _QuickAction(
                    icon: Icons.person_outline_rounded,
                    label: 'Edit Profile',
                    onTap: () =>
                        _push(context, EditProfileScreen(profile: profile)),
                  ),
                  _QuickAction(
                    icon: Icons.settings_outlined,
                    label: 'Settings',
                    onTap: () => _push(context, const SettingsScreen()),
                  ),
                  _QuickAction(
                    icon: Icons.headset_mic_outlined,
                    label: 'Help &\nSupport',
                    onTap: () => _push(context, const SettingsScreen()),
                  ),
                  _QuickAction(
                    icon: Icons.credit_card_outlined,
                    label: 'Payment\nMethods',
                    onTap: () =>
                        _push(context, const PaymentMethodsScreen()),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.lg),
              PCard(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(
                          AppSizes.sm, AppSizes.md, AppSizes.sm, 0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: SectionHeader('Account'),
                      ),
                    ),
                    SettingTile(
                      icon: Icons.badge_outlined,
                      title: 'Personal Information',
                      onTap: () =>
                          _push(context, EditProfileScreen(profile: profile)),
                    ),
                    SettingTile(
                      icon: Icons.lock_outline_rounded,
                      title: 'Change Password',
                      onTap: () => _push(context,
                          const ProfilePlaceholderScreen(title: 'Change Password')),
                    ),
                    SettingTile(
                      icon: Icons.notifications_outlined,
                      title: 'Notification Preferences',
                      onTap: () => _push(context, const SettingsScreen()),
                    ),
                    SettingTile(
                      icon: Icons.shield_outlined,
                      title: 'Privacy & Security',
                      onTap: () => _push(context,
                          const ProfilePlaceholderScreen(title: 'Privacy & Security')),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.profile, required this.onEdit});

  final UserProfile profile;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final end = Color.lerp(colorScheme.primary, Colors.black, 0.35)!;
    final planLabel = profile.plan.isPremium
        ? 'Premium'
        : (profile.isOnTrial ? 'Free Trial' : 'Basic');

    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [colorScheme.primary, end]),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onEdit,
                child: _Avatar(profile: profile, radius: 32),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name.isEmpty ? 'Your name' : profile.name,
                      style: textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      profile.email,
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                    const SizedBox(height: AppSizes.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.sm, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                      ),
                      child: Text(planLabel,
                          style:
                              textTheme.labelSmall?.copyWith(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.lg),
          Row(
            children: [
              _HeroStat(value: '${profile.streak}', label: 'Day Streak'),
              _HeroStat(value: '${profile.recoveryScore}', label: 'Journey Score'),
              _HeroStat(
                  value: '${profile.completedTasks}', label: 'Tasks Completed'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.profile, required this.radius});

  final UserProfile profile;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final photo = profile.photoUrl;
    final hasPhoto = photo != null && photo.isNotEmpty;
    final parts =
        profile.name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    final initials =
        parts.isEmpty ? '?' : parts.map((p) => p[0]).take(2).join();
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.white24,
      backgroundImage: hasPhoto ? NetworkImage(photo) : null,
      child: hasPhoto
          ? null
          : Text(
              initials.toUpperCase(),
              style: TextStyle(
                color: Colors.white,
                fontSize: radius * 0.7,
                fontWeight: FontWeight.w700,
              ),
            ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              )),
          Text(label,
              textAlign: TextAlign.center,
              style: textTheme.labelSmall
                  ?.copyWith(color: Colors.white.withValues(alpha: 0.85))),
        ],
      ),
    );
  }
}

class _SubscriptionStatusCard extends StatelessWidget {
  const _SubscriptionStatusCard({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final planName = profile.plan.isPremium ? 'LifeReset Premium' : 'Basic Plan';
    final statusActive = profile.plan.isPremium || profile.isOnTrial;

    return PCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('👑', style: TextStyle(fontSize: 20)),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(planName, style: textTheme.titleSmall),
                    if (profile.isOnTrial)
                      Text('${UserProfile.trialLengthDays} Days Free Trial',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          )),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.sm, vertical: 2),
                decoration: BoxDecoration(
                  color: (statusActive ? Colors.green : colorScheme.outline)
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                ),
                child: Text(statusActive ? 'Active' : 'Inactive',
                    style: textTheme.labelSmall?.copyWith(
                      color: statusActive ? Colors.green.shade700 : null,
                    )),
              ),
            ],
          ),
          if (profile.isOnTrial) ...[
            const SizedBox(height: AppSizes.md),
            Text('Trial Progress', style: textTheme.labelMedium),
            const SizedBox(height: AppSizes.xs),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.radiusPill),
              child: LinearProgressIndicator(
                value: profile.trialProgress,
                minHeight: 6,
              ),
            ),
            const SizedBox(height: AppSizes.xs),
            Row(
              children: [
                Text(
                  '${profile.trialDaysLeft} days left of ${UserProfile.trialLengthDays} days',
                  style: textTheme.bodySmall
                      ?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                const Spacer(),
                Text('${(profile.trialProgress * 100).round()}%',
                    style: textTheme.labelSmall),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
          child: Column(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: colorScheme.primaryContainer.withValues(alpha: 0.5),
                child: Icon(icon, color: colorScheme.primary),
              ),
              const SizedBox(height: AppSizes.xs),
              Text(label,
                  textAlign: TextAlign.center, style: textTheme.labelSmall),
            ],
          ),
        ),
      ),
    );
  }
}
