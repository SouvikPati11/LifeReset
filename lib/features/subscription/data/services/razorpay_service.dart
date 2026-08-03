import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../domain/entities/subscription_models.dart';

/// Outcome of a native Razorpay checkout session.
sealed class RazorpayOutcome {
  const RazorpayOutcome();
}

/// The gateway reported success; [handshake] must still be verified server-side.
class RazorpaySuccess extends RazorpayOutcome {
  const RazorpaySuccess(this.handshake);
  final PaymentHandshake handshake;
}

/// The gateway failed or the user cancelled.
class RazorpayFailure extends RazorpayOutcome {
  const RazorpayFailure({
    required this.code,
    required this.message,
    this.cancelled = false,
  });

  final String code;
  final String message;
  final bool cancelled;
}

/// Thin wrapper around the `razorpay_flutter` SDK that adapts its event-based
/// API into a single awaitable [open] call.
///
/// The SDK opens Razorpay's own secure, PCI-compliant checkout (the native
/// sheet with UPI / cards / net-banking). No card data ever touches this app,
/// and the secret key lives only in Cloud Functions — here we pass the
/// publishable key id and a server-created `order_id`.
class RazorpayService {
  RazorpayService() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  late final Razorpay _razorpay;
  Completer<RazorpayOutcome>? _pending;

  /// Opens the native checkout for [order] and completes when the user
  /// finishes, cancels, or an error occurs.
  Future<RazorpayOutcome> open(
    CheckoutOrder order, {
    String? email,
    String? contact,
  }) {
    // Guard against a session already being in flight.
    if (_pending != null && !_pending!.isCompleted) {
      return _pending!.future;
    }
    final completer = Completer<RazorpayOutcome>();
    _pending = completer;

    final options = <String, dynamic>{
      'key': order.keyId,
      'order_id': order.orderId,
      'amount': order.amountPaise,
      'currency': order.currency,
      'name': 'LifeReset',
      'description': 'LifeReset Premium — Monthly',
      'timeout': 300,
      'prefill': <String, dynamic>{
        if (email != null && email.isNotEmpty) 'email': email,
        if (contact != null && contact.isNotEmpty) 'contact': contact,
      },
      'theme': <String, dynamic>{'color': '#1B1B3A'},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      _complete(RazorpayFailure(
        code: 'open_failed',
        message: 'Could not open checkout: $e',
      ));
    }
    return completer.future;
  }

  void _handleSuccess(PaymentSuccessResponse response) {
    final orderId = response.orderId;
    final paymentId = response.paymentId;
    final signature = response.signature;
    if (orderId == null || paymentId == null || signature == null) {
      _complete(const RazorpayFailure(
        code: 'incomplete_response',
        message: 'Payment response was incomplete.',
      ));
      return;
    }
    _complete(RazorpaySuccess(PaymentHandshake(
      orderId: orderId,
      paymentId: paymentId,
      signature: signature,
    )));
  }

  void _handleError(PaymentFailureResponse response) {
    final code = response.code;
    final cancelled = code == Razorpay.PAYMENT_CANCELLED;
    _complete(RazorpayFailure(
      code: '${code ?? 'error'}',
      message: cancelled
          ? 'Payment cancelled.'
          : (response.message ?? 'Payment failed. Please try again.'),
      cancelled: cancelled,
    ));
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // The wallet flow continues and still resolves via success/error; nothing
    // to complete here.
    debugPrint('Razorpay external wallet: ${response.walletName}');
  }

  void _complete(RazorpayOutcome outcome) {
    final pending = _pending;
    if (pending != null && !pending.isCompleted) {
      pending.complete(outcome);
    }
  }

  /// Releases the underlying SDK resources and event listeners.
  void dispose() {
    _razorpay.clear();
  }
}
