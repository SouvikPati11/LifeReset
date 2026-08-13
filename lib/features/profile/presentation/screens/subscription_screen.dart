import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/ls_kit.dart';
import '../../../home/presentation/widgets/home_style.dart';
import '../../domain/entities/user_profile.dart';
import '../providers/profile_providers.dart';
import '../widgets/profile_widgets.dart';
import 'choose_plan_screen.dart';

/// Subscription overview: current plan, trial status and benefits.
class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  static const List<String> _benefits = [
    'Unlimited AI Coach chats',
    'Personalized recovery plan',
    'Advanced analytics & insights',
    'Journal AI insights',
    'Priority support',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    return Scaffold(
      backgroundColor: HomeStyle.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            LsHeader(
              title: 'Subscription',
              subtitle: 'Your plan and benefits',
              onBack: () => Navigator.of(context).maybePop(),
            ),
            const SizedBox(height: AppSizes.md),
            Expanded(
              child: profileAsync.when(
                loading: () => const LsLoader(),
                error: (_, __) =>
                    const LsErrorState(title: 'Could not load'),
                data: (profile) => ListView(
                  padding: const EdgeInsets.fromLTRB(
                      AppSizes.lg, 0, AppSizes.lg, AppSizes.xl),
                  children: [
                    const _PremiumBanner(benefits: _benefits),
                    const SizedBox(height: AppSizes.lg),
                    const LsSectionTitle('Your plan'),
                    const SizedBox(height: AppSizes.md),
                    _PlanDetails(profile: profile),
                    const SizedBox(height: AppSizes.lg),
                    _UpgradeCard(
                      onChoose: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const ChoosePlanScreen()),
                      ),
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

class _PremiumBanner extends StatelessWidget {
  const _PremiumBanner({required this.benefits});

  final List<String> benefits;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        gradient: HomeStyle.scoreGradient,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: HomeStyle.softShadow,
      ),
      child: Column(
        children: [
          const Icon(Icons.workspace_premium_rounded,
              color: Colors.white, size: 34),
          const SizedBox(height: AppSizes.sm),
          const Text(
            'LifeReset Premium',
            style: TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            'Unlock your full potential',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 12.5,
            ),
          ),
          const SizedBox(height: AppSizes.md),
          for (final b in benefits)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: Colors.white, size: 18),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: Text(
                      b,
                      style: const TextStyle(color: Colors.white, fontSize: 13.5),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _PlanDetails extends StatelessWidget {
  const _PlanDetails({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final onTrial = profile.isOnTrial;
    final trialEnds = profile.trialEndDate;
    return PCard(
      child: Column(
        children: [
          _Row(label: 'Plan', value: profile.plan.label),
          _Row(
            label: 'Status',
            value: (profile.plan.isPremium || onTrial) ? 'Active' : 'Inactive',
          ),
          _Row(label: 'Billing', value: onTrial ? 'Free Trial' : '—'),
          _Row(label: 'Next Billing', value: onTrial ? 'Not applicable' : '—'),
          _Row(
            label: 'Trial Ends',
            value: trialEnds == null
                ? '—'
                : DateFormat('d MMM yyyy').format(trialEnds),
          ),
          if (onTrial) ...[
            const SizedBox(height: AppSizes.sm),
            const Text(
              "You won't be charged during your free trial.",
              style: TextStyle(fontSize: 12.5, color: HomeStyle.inkSoft),
            ),
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

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: const TextStyle(fontSize: 13.5, color: HomeStyle.inkSoft)),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: HomeStyle.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _UpgradeCard extends StatelessWidget {
  const _UpgradeCard({required this.onChoose});

  final VoidCallback onChoose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: HomeStyle.lavenderLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: HomeStyle.border),
      ),
      child: Column(
        children: [
          const Text(
            'Upgrade to Continue',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: HomeStyle.primaryDeep,
            ),
          ),
          const SizedBox(height: AppSizes.xs),
          const Text(
            'Your premium features will unlock automatically when your trial ends.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.5, color: HomeStyle.inkSoft, height: 1.4),
          ),
          const SizedBox(height: AppSizes.md),
          LsButton(label: 'Choose a Plan', onPressed: onChoose),
        ],
      ),
    );
  }
}
