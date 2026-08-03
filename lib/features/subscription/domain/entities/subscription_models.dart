// Domain entities for the Razorpay Subscription module.
//
// Money is handled in the smallest currency unit (paise) end-to-end with the
// gateway and the backend; the UI formats a human label separately. All
// entitlement state is server-authoritative — these types only model what the
// backend has already decided (via Cloud Functions running on the Admin SDK).

/// Pricing / plan constants for Premium Monthly (₹299 / month).
class SubscriptionPlanConfig {
  const SubscriptionPlanConfig._();

  /// Amount charged per cycle, in paise (₹299.00).
  static const int monthlyAmountPaise = 29900;
  static const String currency = 'INR';
  static const String priceLabel = '₹299';
  static const String periodLabel = 'month';

  /// One-time free-trial length.
  static const int trialDays = 7;

  /// Backend plan identifier stored on the subscription/transaction docs.
  static const String planId = 'premium_monthly';
}

/// High-level entitlement tier read from `users/{uid}.subscription`.
enum PlanTier {
  free('free'),
  premium('premium');

  const PlanTier(this.value);
  final String value;

  bool get isPremium => this == PlanTier.premium;

  static PlanTier fromValue(String? v) =>
      v == 'premium' ? PlanTier.premium : PlanTier.free;
}

/// Lifecycle of the subscription, read from `users/{uid}.subscriptionStatus`.
enum SubscriptionStatus {
  none('none', 'Inactive'),
  trialing('trialing', 'Trial'),
  active('active', 'Active'),
  cancelled('cancelled', 'Cancelled'),
  expired('expired', 'Expired');

  const SubscriptionStatus(this.value, this.label);
  final String value;
  final String label;

  static SubscriptionStatus fromValue(String? v) {
    for (final s in values) {
      if (s.value == v) return s;
    }
    return SubscriptionStatus.none;
  }
}

/// Result of the most recent payment attempt, read from
/// `users/{uid}.paymentStatus`.
enum PaymentState {
  none('none', 'None'),
  trial('trial', 'Free Trial'),
  paid('paid', 'Paid'),
  failed('failed', 'Failed'),
  expired('expired', 'Expired');

  const PaymentState(this.value, this.label);
  final String value;
  final String label;

  static PaymentState fromValue(String? v) {
    for (final s in values) {
      if (s.value == v) return s;
    }
    return PaymentState.none;
  }
}

/// One-time free-trial phase, read from `users/{uid}.trialStatus`.
enum TrialPhase {
  none('none'),
  active('active'),
  expired('expired');

  const TrialPhase(this.value);
  final String value;

  static TrialPhase fromValue(String? v) {
    for (final t in values) {
      if (t.value == v) return t;
    }
    return TrialPhase.none;
  }
}

/// The complete, server-authoritative subscription state for the signed-in
/// user, assembled from `users/{uid}`.
class SubscriptionState {
  const SubscriptionState({
    required this.tier,
    required this.status,
    required this.paymentState,
    required this.trialPhase,
    required this.autoRenew,
    required this.trialConsumed,
    this.startedAt,
    this.renewalDate,
  });

  final PlanTier tier;
  final SubscriptionStatus status;
  final PaymentState paymentState;
  final TrialPhase trialPhase;
  final bool autoRenew;
  final bool trialConsumed;
  final DateTime? startedAt;
  final DateTime? renewalDate;

  /// True while the user is entitled to premium features — premium tier whose
  /// paid/trial period has not lapsed. A cancelled subscription remains active
  /// until [renewalDate].
  bool get isPremiumActive {
    if (!tier.isPremium) return false;
    if (status == SubscriptionStatus.expired) return false;
    final end = renewalDate;
    if (end == null) return true;
    return end.isAfter(DateTime.now());
  }

  bool get isOnTrial =>
      trialPhase == TrialPhase.active && status == SubscriptionStatus.trialing;

  /// True when the one-time free trial has never been used and the user is not
  /// already premium — i.e. the "Start 7-day free trial" CTA may be offered.
  bool get isTrialEligible => !trialConsumed && !isPremiumActive;

  int get daysRemaining {
    final end = renewalDate;
    if (end == null) return 0;
    final diff = end.difference(DateTime.now());
    if (diff.isNegative) return 0;
    return (diff.inHours / 24).ceil();
  }

  factory SubscriptionState.free() => const SubscriptionState(
        tier: PlanTier.free,
        status: SubscriptionStatus.none,
        paymentState: PaymentState.none,
        trialPhase: TrialPhase.none,
        autoRenew: false,
        trialConsumed: false,
      );
}

/// A Razorpay order created server-side, opened in the native checkout.
class CheckoutOrder {
  const CheckoutOrder({
    required this.orderId,
    required this.amountPaise,
    required this.currency,
    required this.keyId,
  });

  final String orderId;
  final int amountPaise;
  final String currency;

  /// Razorpay publishable key id (safe to expose to the client).
  final String keyId;
}

/// The three fields Razorpay returns on a successful payment; sent to the
/// backend for signature verification. The client never trusts these on its
/// own.
class PaymentHandshake {
  const PaymentHandshake({
    required this.orderId,
    required this.paymentId,
    required this.signature,
  });

  final String orderId;
  final String paymentId;
  final String signature;
}

/// A billing-history row read from `transactions`.
class TransactionRecord {
  const TransactionRecord({
    required this.id,
    required this.type,
    required this.status,
    required this.amountPaise,
    required this.currency,
    this.createdAt,
  });

  final String id;

  /// `subscription` for a paid cycle, `trial` for the free trial.
  final String type;
  final String status;
  final int amountPaise;
  final String currency;
  final DateTime? createdAt;

  /// Human amount label, e.g. `₹299` or `Free`.
  String get amountLabel =>
      amountPaise <= 0 ? 'Free' : '₹${(amountPaise / 100).round()}';
}
