import '../../../../core/utils/result.dart';
import '../entities/subscription_models.dart';

/// Contract for the Razorpay Subscription feature.
///
/// Reads are streamed from Firestore (`users/{uid}` and `transactions`);
/// mutations go exclusively through Cloud Functions so that the Razorpay secret
/// key and all entitlement writes stay on the server. The client can never
/// grant itself premium.
abstract interface class SubscriptionRepository {
  /// Server-authoritative subscription state for the user.
  Stream<SubscriptionState> watchSubscription(String uid);

  /// The user's billing history (paid cycles + the free trial).
  Stream<List<TransactionRecord>> watchTransactions(String uid);

  /// Creates a Razorpay order for Premium Monthly and returns the details
  /// needed to open the native checkout.
  Future<Result<CheckoutOrder>> createOrder();

  /// Verifies a completed payment (paymentId + orderId + signature) on the
  /// backend and activates premium. Idempotent: safe to call for duplicate
  /// gateway callbacks.
  Future<Result<void>> verifyPayment(PaymentHandshake handshake);

  /// Grants the one-time 7-day free trial. Fails if the trial was already used.
  Future<Result<void>> startFreeTrial();

  /// Turns auto-renewal off (keeps premium until the current period ends).
  Future<Result<void>> cancelAutoRenew();

  /// Re-enables auto-renewal for an active subscription.
  Future<Result<void>> resumeAutoRenew();

  /// Re-syncs entitlement from the backend (used by "Restore Purchase").
  Future<Result<void>> restore();
}
