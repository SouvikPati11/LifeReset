import 'package:go_router/go_router.dart';

import '../../../../routing/app_routes.dart';
import '../screens/subscription_gate.dart';

/// The Subscription route, exposed as a plug-in list.
///
/// Self-contained: [SubscriptionGate] is the entry point (paywall when free,
/// status when premium) and the confirm / processing / welcome / manage /
/// billing / failed screens are pushed with the local [Navigator]. To surface
/// it, push [SubscriptionGate] from a "Go Premium" CTA, or spread
/// [subscriptionRoutes] into the app's `GoRouter` (the `/subscription` path is
/// already reserved in [AppRoutes]).
final List<RouteBase> subscriptionRoutes = [
  GoRoute(
    path: AppRoutes.subscription,
    name: AppRoutes.subscriptionName,
    builder: (context, state) => const SubscriptionGate(),
  ),
];
