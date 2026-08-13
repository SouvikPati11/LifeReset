import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/ls_kit.dart';
import '../../../home/presentation/widgets/home_style.dart';
import '../widgets/profile_widgets.dart';
import 'choose_plan_screen.dart';
import 'profile_placeholder_screen.dart';

/// Payment Methods: current method, billing history and manage subscription.
///
/// Navigation only — no payment is processed. No card data is fabricated;
/// methods appear once a real payment integration is added.
class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HomeStyle.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            LsHeader(
              title: 'Payment Methods',
              subtitle: 'Manage billing',
              onBack: () => Navigator.of(context).maybePop(),
              trailing: LsSquareButton(
                icon: Icons.add_rounded,
                onTap: () => _push(context,
                    const ProfilePlaceholderScreen(title: 'Add Payment Method')),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                    AppSizes.lg, 0, AppSizes.lg, AppSizes.xl),
                children: [
                  const LsCard(
                    padding: EdgeInsets.all(AppSizes.lg),
                    child: Column(
                      children: [
                        Icon(Icons.credit_card_off_outlined,
                            size: 40, color: HomeStyle.inkSoft),
                        SizedBox(height: AppSizes.sm),
                        Text(
                          'No payment method yet',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: HomeStyle.ink,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Add one when you upgrade — you won’t be charged '
                          'during your free trial.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 12.5,
                              color: HomeStyle.inkSoft,
                              height: 1.4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),
                  LsGroup(
                    children: [
                      SettingTile(
                        icon: Icons.receipt_long_outlined,
                        title: 'Billing History',
                        subtitle: 'View all your payments and invoices',
                        onTap: () => _push(
                            context,
                            const ProfilePlaceholderScreen(
                                title: 'Billing History')),
                      ),
                      SettingTile(
                        icon: Icons.tune_rounded,
                        title: 'Manage Subscription',
                        subtitle: 'Cancel or update your subscription',
                        onTap: () =>
                            _push(context, const ChoosePlanScreen()),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.lg),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_outline_rounded,
                          size: 14, color: HomeStyle.inkSoft),
                      SizedBox(width: AppSizes.xs),
                      Flexible(
                        child: Text('All payments are secure and encrypted.',
                            style: TextStyle(
                                fontSize: 11.5, color: HomeStyle.inkSoft)),
                      ),
                    ],
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
