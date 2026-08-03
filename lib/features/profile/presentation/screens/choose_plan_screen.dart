import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/errors/failures.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../domain/entities/user_profile.dart';
import '../controllers/profile_controller.dart';
import '../providers/profile_providers.dart';

/// Choose between the Free (Basic) and Premium plans. Selecting only records the
/// choice in Firestore — no payment is processed.
class ChoosePlanScreen extends ConsumerStatefulWidget {
  const ChoosePlanScreen({super.key});

  @override
  ConsumerState<ChoosePlanScreen> createState() => _ChoosePlanScreenState();
}

class _ChoosePlanScreenState extends ConsumerState<ChoosePlanScreen> {
  SubscriptionPlan _selected = SubscriptionPlan.premium;
  var _initialized = false;

  static const _premiumFeatures = [
    ('Unlimited AI Coach messages', true),
    ('AI Journal insights', true),
    ('Advanced progress analytics', true),
    ('Custom recovery programs', true),
    ('Priority support', true),
    ('Early access to new features', true),
  ];

  static const _basicFeatures = [
    ('Limited AI Coach messages (30/day)', true),
    ('Basic progress tracking', true),
    ('Standard support', true),
    ('AI Journal insights', false),
    ('Advanced analytics', false),
  ];

  Future<void> _continue() async {
    final ok =
        await ref.read(profileControllerProvider.notifier).selectPlan(_selected);
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_selected.label} plan selected')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final saving = ref.watch(profileControllerProvider).isLoading;

    // Default the selection to the user's current plan, once.
    final current = ref.watch(profileProvider).valueOrNull?.plan;
    if (!_initialized && current != null) {
      _initialized = true;
      _selected = current;
    }

    ref.listen(profileControllerProvider, (_, next) {
      if (next is AsyncError && next.error is Failure && mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text((next.error as Failure).message)),
          );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Choose a Plan')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSizes.md),
                children: [
                  _PlanCard(
                    plan: SubscriptionPlan.premium,
                    title: 'Premium',
                    tagline: 'Best for personal growth',
                    price: '₹599',
                    yearly: '₹4,999/year (Save 30%)',
                    features: _premiumFeatures,
                    mostPopular: true,
                    selected: _selected == SubscriptionPlan.premium,
                    onTap: () =>
                        setState(() => _selected = SubscriptionPlan.premium),
                  ),
                  const SizedBox(height: AppSizes.md),
                  _PlanCard(
                    plan: SubscriptionPlan.free,
                    title: 'Basic',
                    tagline: 'Good for getting started',
                    price: '₹299',
                    yearly: '₹2,499/year (Save 30%)',
                    features: _basicFeatures,
                    mostPopular: false,
                    selected: _selected == SubscriptionPlan.free,
                    onTap: () =>
                        setState(() => _selected = SubscriptionPlan.free),
                  ),
                  const SizedBox(height: AppSizes.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_outline_rounded,
                          size: AppSizes.iconSm,
                          color: Theme.of(context).colorScheme.onSurfaceVariant),
                      const SizedBox(width: AppSizes.xs),
                      Text('Secure Checkout',
                          style: Theme.of(context).textTheme.labelMedium),
                    ],
                  ),
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    "Cancel anytime. You won't be charged during trial.",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: PrimaryButton(
                label: 'Continue',
                isLoading: saving,
                onPressed: _continue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.title,
    required this.tagline,
    required this.price,
    required this.yearly,
    required this.features,
    required this.mostPopular,
    required this.selected,
    required this.onTap,
  });

  final SubscriptionPlan plan;
  final String title;
  final String tagline;
  final String price;
  final String yearly;
  final List<(String, bool)> features;
  final bool mostPopular;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.lg),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(
            color: selected ? colorScheme.primary : colorScheme.outlineVariant,
            width: selected ? 1.8 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  plan.isPremium
                      ? Icons.workspace_premium_rounded
                      : Icons.auto_awesome_rounded,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(title, style: textTheme.titleMedium),
                          if (mostPopular) ...[
                            const SizedBox(width: AppSizes.sm),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppSizes.sm, vertical: 2),
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                borderRadius:
                                    BorderRadius.circular(AppSizes.radiusPill),
                              ),
                              child: Text('Most Popular',
                                  style: textTheme.labelSmall
                                      ?.copyWith(color: Colors.white)),
                            ),
                          ],
                        ],
                      ),
                      Text(tagline,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          )),
                    ],
                  ),
                ),
                Icon(
                  selected
                      ? Icons.check_circle_rounded
                      : Icons.circle_outlined,
                  color: selected ? colorScheme.primary : colorScheme.outline,
                ),
              ],
            ),
            const SizedBox(height: AppSizes.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(price,
                    style: textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4, left: 2),
                  child: Text('/month', style: textTheme.bodySmall),
                ),
              ],
            ),
            Text(yearly,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                )),
            const SizedBox(height: AppSizes.md),
            for (final (label, included) in features)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Icon(
                      included
                          ? Icons.check_circle_rounded
                          : Icons.cancel_rounded,
                      size: AppSizes.iconSm,
                      color: included
                          ? colorScheme.primary
                          : colorScheme.outline,
                    ),
                    const SizedBox(width: AppSizes.sm),
                    Expanded(
                      child: Text(
                        label,
                        style: textTheme.bodyMedium?.copyWith(
                          color: included ? null : colorScheme.onSurfaceVariant,
                        ),
                      ),
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
