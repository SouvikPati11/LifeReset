import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../../authentication/presentation/providers/user_providers.dart';
import '../../data/datasources/subscription_remote_data_source.dart';
import '../../data/repositories/subscription_repository_impl.dart';
import '../../data/services/razorpay_service.dart';
import '../../domain/entities/subscription_models.dart';
import '../../domain/repositories/subscription_repository.dart';

/// Dependency graph for the Razorpay Subscription feature.

final _functionsProvider = Provider<FirebaseFunctions>((ref) {
  return FirebaseFunctions.instance;
});

/// The native Razorpay SDK wrapper. Disposed with the provider scope so its
/// event listeners are always released.
final razorpayServiceProvider = Provider<RazorpayService>((ref) {
  final service = RazorpayService();
  ref.onDispose(service.dispose);
  return service;
});

final _dataSourceProvider = Provider<SubscriptionRemoteDataSource>((ref) {
  return SubscriptionRemoteDataSource(
    FirebaseFirestore.instance,
    ref.watch(_functionsProvider),
  );
});

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  return SubscriptionRepositoryImpl(ref.watch(_dataSourceProvider));
});

/// Server-authoritative subscription state for the signed-in user.
final subscriptionStateProvider = StreamProvider<SubscriptionState>((ref) {
  final uid = ref.watch(currentUserProvider)?.id;
  if (uid == null) return Stream.value(SubscriptionState.free());
  return ref.watch(subscriptionRepositoryProvider).watchSubscription(uid);
});

/// Convenience flag: is premium currently active?
final isPremiumProvider = Provider<bool>((ref) {
  return ref.watch(subscriptionStateProvider).valueOrNull?.isPremiumActive ??
      false;
});

/// Billing history (paid cycles + free trial), newest first.
final transactionsProvider = StreamProvider<List<TransactionRecord>>((ref) {
  final uid = ref.watch(currentUserProvider)?.id;
  if (uid == null) return Stream.value(const []);
  return ref.watch(subscriptionRepositoryProvider).watchTransactions(uid);
});

/// Prefill details passed to the Razorpay checkout.
final checkoutPrefillProvider = Provider<({String? email, String? name})>((ref) {
  final profile = ref.watch(userProfileProvider).valueOrNull;
  return (email: profile?.email, name: profile?.name);
});
