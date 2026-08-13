import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/ls_kit.dart';
import '../../../home/presentation/widgets/home_style.dart';
import '../../../notifications/presentation/providers/notifications_providers.dart';
import '../../../notifications/presentation/screens/notifications_inbox_screen.dart';
import '../../domain/entities/user_profile.dart';
import '../providers/profile_providers.dart';
import 'edit_profile_screen.dart';
import 'payment_methods_screen.dart';
import 'profile_placeholder_screen.dart';
import 'settings_screen.dart';
import 'subscription_screen.dart';

/// My Profile: a personal, account-focused surface — an identity header, a
/// compact real-stat strip, subscription status, and grouped settings sections.
class ProfileHomeScreen extends ConsumerWidget {
  const ProfileHomeScreen({super.key});

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final unread = ref.watch(unreadCountProvider);

    return Scaffold(
      backgroundColor: HomeStyle.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            LsHeader(
              title: 'Profile',
              subtitle: 'Manage your account and preferences',
              trailing: LsSquareButton(
                icon: Icons.notifications_none_rounded,
                badgeCount: unread,
                onTap: () =>
                    _push(context, const NotificationsInboxScreen()),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            Expanded(
              child: profileAsync.when(
                loading: () => const LsLoader(),
                error: (_, __) => const LsErrorState(
                  title: 'Could not load profile',
                  message: 'Please try again in a moment.',
                ),
                data: (profile) => ListView(
                  padding: const EdgeInsets.fromLTRB(
                      AppSizes.lg, 0, AppSizes.lg, AppSizes.xl),
                  children: [
                    _IdentityCard(
                      profile: profile,
                      onEdit: () => _push(
                          context, EditProfileScreen(profile: profile)),
                    ),
                    const SizedBox(height: AppSizes.lg),
                    LsSectionTitle(
                      'Subscription',
                      trailing: TextButton(
                        onPressed: () =>
                            _push(context, const SubscriptionScreen()),
                        style: TextButton.styleFrom(
                          foregroundColor: HomeStyle.primary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.sm),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('View details',
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(height: AppSizes.md),
                    _SubscriptionCard(profile: profile),
                    const SizedBox(height: AppSizes.lg),
                    const LsGroupLabel('Account'),
                    LsGroup(
                      children: [
                        LsRow(
                          icon: Icons.badge_outlined,
                          title: 'Personal Information',
                          onTap: () => _push(
                              context, EditProfileScreen(profile: profile)),
                        ),
                        LsRow(
                          icon: Icons.notifications_outlined,
                          title: 'Notifications',
                          onTap: () => _push(
                              context, const NotificationsInboxScreen()),
                        ),
                        LsRow(
                          icon: Icons.settings_outlined,
                          title: 'Preferences',
                          onTap: () =>
                              _push(context, const SettingsScreen()),
                        ),
                        LsRow(
                          icon: Icons.credit_card_outlined,
                          title: 'Payment Methods',
                          onTap: () =>
                              _push(context, const PaymentMethodsScreen()),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.lg),
                    const LsGroupLabel('Support'),
                    LsGroup(
                      children: [
                        LsRow(
                          icon: Icons.help_outline_rounded,
                          title: 'Help & Support',
                          onTap: () =>
                              _push(context, const SettingsScreen()),
                        ),
                        LsRow(
                          icon: Icons.shield_outlined,
                          title: 'Privacy & Security',
                          onTap: () => _push(context,
                              const ProfilePlaceholderScreen(
                                  title: 'Privacy & Security')),
                        ),
                        LsRow(
                          icon: Icons.info_outline_rounded,
                          title: 'About LifeReset',
                          onTap: () => _push(context,
                              const ProfilePlaceholderScreen(
                                  title: 'About LifeReset')),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The gradient identity header: avatar, name, email, plan badge and a compact
/// strip of real recovery stats.
class _IdentityCard extends StatelessWidget {
  const _IdentityCard({required this.profile, required this.onEdit});

  final UserProfile profile;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final planLabel = profile.plan.isPremium
        ? 'Premium'
        : (profile.isOnTrial ? 'Free Trial' : 'Basic');

    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        gradient: HomeStyle.scoreGradient,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: HomeStyle.softShadow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onEdit,
                child: _Avatar(profile: profile, radius: 30),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name.isEmpty ? 'Your name' : profile.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      profile.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 12.5,
                      ),
                    ),
                    const SizedBox(height: AppSizes.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.workspace_premium_rounded,
                              color: Colors.white, size: 13),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              planLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              _EditChip(onTap: onEdit),
            ],
          ),
          const SizedBox(height: AppSizes.lg),
          Container(
            padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Row(
              children: [
                _Stat(value: '${profile.streak}', label: 'Day Streak'),
                _StatDivider(),
                _Stat(value: '${profile.recoveryScore}', label: 'Journey Score'),
                _StatDivider(),
                _Stat(
                    value: '${profile.completedTasks}',
                    label: 'Tasks Done'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EditChip extends StatelessWidget {
  const _EditChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.2),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: const SizedBox(
          width: 38,
          height: 38,
          child: Icon(Icons.edit_rounded, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 30,
      color: Colors.white.withValues(alpha: 0.25),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
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

class _SubscriptionCard extends StatelessWidget {
  const _SubscriptionCard({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final planName = profile.plan.isPremium ? 'LifeReset Premium' : 'Basic Plan';
    final statusActive = profile.plan.isPremium || profile.isOnTrial;

    return LsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const LsIconBadge(
                  icon: Icons.workspace_premium_rounded, size: 40),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      planName,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: HomeStyle.ink,
                      ),
                    ),
                    if (profile.isOnTrial)
                      const Text(
                        '${UserProfile.trialLengthDays} days free trial',
                        style: TextStyle(fontSize: 12.5, color: HomeStyle.inkSoft),
                      ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (statusActive ? HomeStyle.success : HomeStyle.inkSoft)
                      .withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                ),
                child: Text(
                  statusActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color:
                        statusActive ? HomeStyle.success : HomeStyle.inkSoft,
                  ),
                ),
              ),
            ],
          ),
          if (profile.isOnTrial) ...[
            const SizedBox(height: AppSizes.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.radiusPill),
              child: LinearProgressIndicator(
                value: profile.trialProgress,
                minHeight: 7,
                backgroundColor: HomeStyle.lavender,
                valueColor: const AlwaysStoppedAnimation(HomeStyle.primary),
              ),
            ),
            const SizedBox(height: AppSizes.xs),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${profile.trialDaysLeft} days left of ${UserProfile.trialLengthDays}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        const TextStyle(fontSize: 12, color: HomeStyle.inkSoft),
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                Text(
                  '${(profile.trialProgress * 100).round()}%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: HomeStyle.primary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
