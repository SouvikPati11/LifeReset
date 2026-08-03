import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/subscription_models.dart';

/// Remote data source for subscriptions.
///
/// State is streamed from Firestore (`users/{uid}`, `transactions`); every
/// mutation is a Cloud Function call so the Razorpay secret and all entitlement
/// writes remain server-side.
class SubscriptionRemoteDataSource {
  SubscriptionRemoteDataSource(this._firestore, this._functions);

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _firestore.collection(AppConstants.usersCollection).doc(uid);

  // ---- Streams (server-authoritative reads) ----

  Stream<SubscriptionState> watchSubscription(String uid) {
    return _userDoc(uid).snapshots().map((doc) {
      final data = doc.data();
      if (data == null) return SubscriptionState.free();
      return SubscriptionState(
        tier: PlanTier.fromValue(data['subscription'] as String?),
        status: SubscriptionStatus.fromValue(data['subscriptionStatus'] as String?),
        paymentState: PaymentState.fromValue(data['paymentStatus'] as String?),
        trialPhase: TrialPhase.fromValue(data['trialStatus'] as String?),
        autoRenew: (data['autoRenew'] as bool?) ?? false,
        trialConsumed: (data['trialConsumed'] as bool?) ?? false,
        startedAt: (data['subscriptionStartedAt'] as Timestamp?)?.toDate(),
        renewalDate: (data['renewalDate'] as Timestamp?)?.toDate(),
      );
    });
  }

  Stream<List<TransactionRecord>> watchTransactions(String uid) {
    return _firestore
        .collection('transactions')
        .where('uid', isEqualTo: uid)
        .snapshots()
        .map((snap) {
      final list = snap.docs.map((d) {
        final data = d.data();
        return TransactionRecord(
          id: d.id,
          type: (data['type'] as String?) ?? 'subscription',
          status: (data['status'] as String?) ?? 'success',
          amountPaise: (data['amount'] as num?)?.toInt() ?? 0,
          currency: (data['currency'] as String?) ?? SubscriptionPlanConfig.currency,
          createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
        );
      }).toList();
      // Sort client-side (newest first) to avoid a composite index.
      list.sort((a, b) =>
          (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
      return list;
    });
  }

  // ---- Mutations (Cloud Functions) ----

  Future<CheckoutOrder> createOrder() async {
    final data = await _call('createSubscriptionOrder');
    final orderId = data['orderId'] as String?;
    final keyId = data['keyId'] as String?;
    if (orderId == null || keyId == null) {
      throw const ServerException('Could not start checkout. Please try again.');
    }
    return CheckoutOrder(
      orderId: orderId,
      amountPaise: (data['amount'] as num?)?.toInt() ??
          SubscriptionPlanConfig.monthlyAmountPaise,
      currency: (data['currency'] as String?) ?? SubscriptionPlanConfig.currency,
      keyId: keyId,
    );
  }

  Future<void> verifyPayment(PaymentHandshake handshake) async {
    await _call('verifySubscriptionPayment', {
      'orderId': handshake.orderId,
      'paymentId': handshake.paymentId,
      'signature': handshake.signature,
    });
  }

  Future<void> startFreeTrial() => _call('startFreeTrial').then((_) {});

  Future<void> cancelAutoRenew() => _call('cancelSubscription').then((_) {});

  Future<void> resumeAutoRenew() => _call('resumeSubscription').then((_) {});

  Future<void> restore() => _call('getSubscription').then((_) {});

  Future<Map<String, dynamic>> _call(String name,
      [Map<String, dynamic>? payload]) async {
    try {
      final result = await _functions.httpsCallable(name).call(payload ?? const {});
      final data = result.data;
      if (data is Map) return Map<String, dynamic>.from(data);
      return <String, dynamic>{};
    } on FirebaseFunctionsException catch (e) {
      throw ServerException(
        e.message ?? 'Payment service is unavailable right now.',
        code: e.code,
      );
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Something went wrong.', code: e.code);
    }
  }
}
