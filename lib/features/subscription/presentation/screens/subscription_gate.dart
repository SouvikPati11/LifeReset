import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/loading_view.dart';
import '../providers/subscription_providers.dart';
import 'paywall_screen.dart';
import 'premium_status_screen.dart';

/// Public entry point for the Subscription module.
///
/// Routes the user to their current subscription surface: the status screen
/// when premium is active, otherwise the paywall. Push this from anywhere
/// (e.g. a "Go Premium" CTA or the profile's Subscription row).
class SubscriptionGate extends ConsumerWidget {
  const SubscriptionGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(subscriptionStateProvider);
    return async.when(
      loading: () => const Scaffold(body: LoadingView()),
      error: (_, __) => const PaywallScreen(),
      data: (state) =>
          state.isPremiumActive ? const PremiumStatusScreen() : const PaywallScreen(),
    );
  }
}
