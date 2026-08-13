import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/errors/failures.dart';
import '../../../../shared/widgets/ls_kit.dart';
import '../../../home/presentation/widgets/home_style.dart';
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
      backgroundColor: HomeStyle.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            LsHeader(
              title: 'Choose a Plan',
              onBack: () => Navigator.of(context).maybePop(),
            ),
            const SizedBox(height: AppSizes.md),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                    AppSizes.lg, 0, AppSizes.lg, AppSizes.md),
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
                  const _SecureNote(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSizes.lg),
              child: LsButton(
                label: 'Continue',
                loading: saving,
                onPressed: _continue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SecureNote extends StatelessWidget {
  const _SecureNote();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline_rounded, size: 16, color: HomeStyle.inkSoft),
            SizedBox(width: AppSizes.xs),
            Text('Secure Checkout',
                style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: HomeStyle.inkSoft)),
          ],
        ),
        SizedBox(height: AppSizes.xs),
        Text(
          "Cancel anytime. You won't be charged during trial.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: HomeStyle.inkSoft),
        ),
      ],
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.lg),
        decoration: BoxDecoration(
          color: selected ? HomeStyle.lavenderLight : HomeStyle.card,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(
            color: selected ? HomeStyle.primary : HomeStyle.border,
            width: selected ? 1.8 : 1,
          ),
          boxShadow: HomeStyle.softShadow,
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
                  color: HomeStyle.primary,
                ),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: HomeStyle.ink,
                              ),
                            ),
                          ),
                          if (mostPopular) ...[
                            const SizedBox(width: AppSizes.sm),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppSizes.sm, vertical: 2),
                              decoration: BoxDecoration(
                                color: HomeStyle.primary,
                                borderRadius:
                                    BorderRadius.circular(AppSizes.radiusPill),
                              ),
                              child: const Text('Popular',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ],
                      ),
                      Text(tagline,
                          style: const TextStyle(
                              fontSize: 12.5, color: HomeStyle.inkSoft)),
                    ],
                  ),
                ),
                Icon(
                  selected
                      ? Icons.check_circle_rounded
                      : Icons.circle_outlined,
                  color: selected ? HomeStyle.primary : HomeStyle.border,
                ),
              ],
            ),
            const SizedBox(height: AppSizes.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(price,
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: HomeStyle.ink)),
                const Padding(
                  padding: EdgeInsets.only(bottom: 4, left: 2),
                  child: Text('/month',
                      style: TextStyle(fontSize: 12.5, color: HomeStyle.inkSoft)),
                ),
              ],
            ),
            Text(yearly,
                style:
                    const TextStyle(fontSize: 12.5, color: HomeStyle.inkSoft)),
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
                      size: 18,
                      color: included ? HomeStyle.success : HomeStyle.inkSoft,
                    ),
                    const SizedBox(width: AppSizes.sm),
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 13.5,
                          color: included ? HomeStyle.ink : HomeStyle.inkSoft,
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
