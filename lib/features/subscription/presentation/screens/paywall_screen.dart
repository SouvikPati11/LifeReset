import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../domain/entities/subscription_models.dart';
import '../controllers/checkout_controller.dart';
import '../providers/subscription_providers.dart';
import '../widgets/confirm_subscription_sheet.dart';
import '../widgets/premium_widgets.dart';
import 'payment_processing_screen.dart';

/// Screen 1 — "Go Premium" paywall.
class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  bool _yearly = false;

  static const _features = <(IconData, String, String, Color)>[
    (Icons.forum_rounded, 'AI Recovery Coach', 'Unlimited AI chat support', Color(0xFF7C4DFF)),
    (Icons.checklist_rounded, 'Personalized Habit Plans', 'Advanced habit tracking', Color(0xFF3D9BE9)),
    (Icons.menu_book_rounded, 'Journal & Mood Insights', 'Deep AI-powered analysis', Color(0xFF2E9E63)),
    (Icons.workspace_premium_rounded, 'Premium Programs', 'Access all recovery programs', Color(0xFFF5A623)),
    (Icons.block_rounded, 'Ads Free Experience', 'Clean and focused experience', Color(0xFFE0576B)),
  ];

  Future<void> _onSubscribe(bool trialEligible) async {
    final proceed =
        await showConfirmSubscriptionSheet(context, trialEligible: trialEligible);
    if (proceed != true || !mounted) return;
    // Reset any prior flow state before starting a new one.
    ref.read(checkoutControllerProvider.notifier).reset();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PaymentProcessingScreen(isTrial: trialEligible),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final state = ref.watch(subscriptionStateProvider).valueOrNull ??
        SubscriptionState.free();
    final trialEligible = state.isTrialEligible;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Hero header.
          Container(
            padding: const EdgeInsets.fromLTRB(
                AppSizes.lg, AppSizes.xxl + AppSizes.md, AppSizes.lg, AppSizes.lg),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  kPremiumGold.withValues(alpha: 0.20),
                  colorScheme.surface,
                ],
              ),
            ),
            child: Column(
              children: [
                const CrownBadge(size: 72),
                const SizedBox(height: AppSizes.md),
                Text('Go Premium', style: textTheme.headlineMedium),
                const SizedBox(height: AppSizes.xs),
                Text(
                  'Unlock your full potential with LifeReset Premium',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium
                      ?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              children: [
                SectionCard(
                  child: Column(
                    children: [
                      for (final f in _features)
                        FeatureTile(
                          icon: f.$1,
                          title: f.$2,
                          subtitle: f.$3,
                          color: f.$4,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.md),
                _PlanToggle(
                  yearly: _yearly,
                  onChanged: (v) {
                    if (v) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Yearly plans are coming soon.')),
                      );
                      return;
                    }
                    setState(() => _yearly = v);
                  },
                ),
                const SizedBox(height: AppSizes.md),
                _PlanCard(trialEligible: trialEligible),
                const SizedBox(height: AppSizes.md),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => _onSubscribe(trialEligible),
                    style: FilledButton.styleFrom(
                      backgroundColor: kPremiumIndigo,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
                    ),
                    child: Text(
                      trialEligible
                          ? 'Start ${SubscriptionPlanConfig.trialDays} Day Free Trial'
                          : 'Subscribe — ${SubscriptionPlanConfig.priceLabel}/${SubscriptionPlanConfig.periodLabel}',
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.sm),
                Text(
                  'Continue means you agree to our Terms & Privacy Policy',
                  textAlign: TextAlign.center,
                  style: textTheme.labelSmall
                      ?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanToggle extends StatelessWidget {
  const _PlanToggle({required this.yearly, required this.onChanged});
  final bool yearly;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    Widget segment(String label, bool selected, VoidCallback onTap, {String? badge}) {
      return Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
            decoration: BoxDecoration(
              color: selected ? colorScheme.surface : Colors.transparent,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: textTheme.labelLarge),
                if (badge != null) ...[
                  const SizedBox(width: AppSizes.xs),
                  Text(badge,
                      style: textTheme.labelSmall
                          ?.copyWith(color: kSuccessGreen)),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppSizes.xs),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Row(
        children: [
          segment('Monthly', !yearly, () => onChanged(false)),
          segment('Yearly', yearly, () => onChanged(true), badge: 'Save 50%'),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.trialEligible});
  final bool trialEligible;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: colorScheme.primary, width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(SubscriptionPlanConfig.priceLabel,
                        style: textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800)),
                    Text('/${SubscriptionPlanConfig.periodLabel}',
                        style: textTheme.bodyMedium
                            ?.copyWith(color: colorScheme.onSurfaceVariant)),
                  ],
                ),
                const SizedBox(height: AppSizes.xs),
                Text(
                  trialEligible
                      ? '${SubscriptionPlanConfig.trialDays} Days Free Trial • Cancel Anytime'
                      : 'Cancel Anytime',
                  style: textTheme.bodySmall
                      ?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          StatusPill(label: 'Most Popular', color: kSuccessGreen),
        ],
      ),
    );
  }
}
