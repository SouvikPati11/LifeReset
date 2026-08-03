import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/result.dart';
import '../../data/services/razorpay_service.dart';
import '../providers/subscription_providers.dart';

/// Stages of the purchase / trial flow, surfaced by the processing screen.
enum CheckoutPhase {
  idle,
  creatingOrder,
  awaitingGateway,
  verifying,
  activating,
  success,
  failed,
}

class CheckoutFlowState {
  const CheckoutFlowState({
    required this.phase,
    this.error,
    this.isTrial = false,
  });

  final CheckoutPhase phase;
  final String? error;
  final bool isTrial;

  bool get isTerminal =>
      phase == CheckoutPhase.success || phase == CheckoutPhase.failed;

  factory CheckoutFlowState.idle() =>
      const CheckoutFlowState(phase: CheckoutPhase.idle);
}

/// Drives the checkout state machine:
///   createOrder → open gateway → verify (server) → activate.
///
/// Never grants premium locally — activation is decided by the backend and
/// observed through [subscriptionStateProvider].
class CheckoutController extends Notifier<CheckoutFlowState> {
  @override
  CheckoutFlowState build() => CheckoutFlowState.idle();

  /// Paid Premium Monthly purchase.
  Future<void> startPaid() async {
    final repo = ref.read(subscriptionRepositoryProvider);

    state = const CheckoutFlowState(phase: CheckoutPhase.creatingOrder);
    final orderResult = await repo.createOrder();
    final order = orderResult.when(
      success: (o) => o,
      failure: (f) {
        _fail(f.message);
        return null;
      },
    );
    if (order == null) return;

    state = const CheckoutFlowState(phase: CheckoutPhase.awaitingGateway);
    final prefill = ref.read(checkoutPrefillProvider);
    final outcome =
        await ref.read(razorpayServiceProvider).open(order, email: prefill.email);

    switch (outcome) {
      case RazorpaySuccess(:final handshake):
        state = const CheckoutFlowState(phase: CheckoutPhase.verifying);
        final verifyResult = await repo.verifyPayment(handshake);
        await verifyResult.when(
          success: (_) => _activateThenSucceed(),
          failure: (f) async => _fail(f.message),
        );
      case RazorpayFailure(:final message):
        _fail(message);
    }
  }

  /// One-time 7-day free trial (₹0, no gateway).
  Future<void> startTrial() async {
    state = const CheckoutFlowState(
        phase: CheckoutPhase.activating, isTrial: true);
    final result = await ref.read(subscriptionRepositoryProvider).startFreeTrial();
    result.when(
      success: (_) {
        state = const CheckoutFlowState(
            phase: CheckoutPhase.success, isTrial: true);
      },
      failure: (f) {
        _fail(f.message, isTrial: true);
      },
    );
  }

  Future<void> _activateThenSucceed() async {
    state = const CheckoutFlowState(phase: CheckoutPhase.activating);
    // Brief pause so the "Activating premium / Setting up your account" steps
    // are perceptible; the entitlement itself is already committed server-side.
    await Future<void>.delayed(const Duration(milliseconds: 700));
    state = const CheckoutFlowState(phase: CheckoutPhase.success);
  }

  void _fail(String message, {bool isTrial = false}) {
    state = CheckoutFlowState(
        phase: CheckoutPhase.failed, error: message, isTrial: isTrial);
  }

  void reset() => state = CheckoutFlowState.idle();
}

final checkoutControllerProvider =
    NotifierProvider<CheckoutController, CheckoutFlowState>(
  CheckoutController.new,
);

/// Loading/one-shot controller for management actions (cancel / resume /
/// restore) on the Manage Subscription screen.
class SubscriptionActionController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<bool> cancelAutoRenew() =>
      _run(() => ref.read(subscriptionRepositoryProvider).cancelAutoRenew());

  Future<bool> resumeAutoRenew() =>
      _run(() => ref.read(subscriptionRepositoryProvider).resumeAutoRenew());

  Future<bool> restore() =>
      _run(() => ref.read(subscriptionRepositoryProvider).restore());

  Future<bool> _run(Future<Result<void>> Function() action) async {
    state = const AsyncLoading();
    final result = await action();
    return result.when(
      success: (_) {
        state = const AsyncData(null);
        return true;
      },
      failure: (f) {
        state = AsyncError(f, StackTrace.current);
        return false;
      },
    );
  }
}

final subscriptionActionControllerProvider =
    AutoDisposeAsyncNotifierProvider<SubscriptionActionController, void>(
  SubscriptionActionController.new,
);
