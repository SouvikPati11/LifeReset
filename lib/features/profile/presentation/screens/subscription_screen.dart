import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../domain/entities/user_profile.dart';
import '../providers/profile_providers.dart';
import '../widgets/profile_widgets.dart';
import 'choose_plan_screen.dart';
import 'profile_placeholder_screen.dart';

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
      appBar: AppBar(
        title: const Text('Subscription'),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    const ProfilePlaceholderScreen(title: 'Subscription Help'),
              ),
            ),
            icon: const Icon(Icons.help_outline_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: profileAsync.when(
          loading: () => const LoadingView(),
          error: (_, __) => const Center(child: Text('Could not load')),
          data: (profile) => ListView(
            padding: const EdgeInsets.all(AppSizes.md),
            children: [
              _PremiumBanner(benefits: _benefits),
              const SizedBox(height: AppSizes.lg),
              Text('Your Plan', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSizes.sm),
              _PlanDetails(profile: profile),
              const SizedBox(height: AppSizes.lg),
              _UpgradeCard(
                onChoose: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ChoosePlanScreen()),
                ),
              ),
            ],
          ),
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final end = Color.lerp(colorScheme.primary, Colors.black, 0.35)!;
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [colorScheme.primary, end]),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Column(
        children: [
          const Text('👑', style: TextStyle(fontSize: 28)),
          const SizedBox(height: AppSizes.sm),
          Text('LifeReset Premium',
              style: textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              )),
          Text('Unlock your full potential',
              style: textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
              )),
          const SizedBox(height: AppSizes.md),
          for (final b in benefits)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: Colors.white, size: AppSizes.iconSm),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: Text(b,
                        style:
                            textTheme.bodyMedium?.copyWith(color: Colors.white)),
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
          _Row(
              label: 'Next Billing',
              value: onTrial ? 'Not applicable' : '—'),
          _Row(
            label: 'Trial Ends',
            value: trialEnds == null
                ? '—'
                : DateFormat('d MMM yyyy').format(trialEnds),
          ),
          if (onTrial) ...[
            const SizedBox(height: AppSizes.sm),
            Text(
              "You won't be charged during your free trial.",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: AppSizes.md),
            Text('Trial Progress',
                style: Theme.of(context).textTheme.labelMedium),
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
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Spacer(),
                Text('${(profile.trialProgress * 100).round()}%',
                    style: Theme.of(context).textTheme.labelSmall),
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
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                )),
          ),
          Text(value, style: textTheme.titleSmall),
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
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Column(
        children: [
          Text('Upgrade to Continue',
              style: textTheme.titleMedium?.copyWith(color: colorScheme.primary)),
          const SizedBox(height: AppSizes.xs),
          Text(
            'Your premium features will unlock automatically when your trial ends.',
            textAlign: TextAlign.center,
            style: textTheme.bodySmall
                ?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSizes.md),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onChoose,
              child: const Text('Choose a Plan'),
            ),
          ),
        ],
      ),
    );
  }
}
