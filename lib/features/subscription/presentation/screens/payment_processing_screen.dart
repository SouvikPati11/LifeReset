import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../controllers/checkout_controller.dart';
import '../widgets/premium_widgets.dart';
import 'payment_failed_screen.dart';
import 'premium_welcome_screen.dart';

/// Screen 4 — "Processing Payment" checklist.
///
/// Launches the purchase (or trial) flow and shows live progress. On success it
/// advances to the welcome screen; on failure to the retry screen.
class PaymentProcessingScreen extends ConsumerStatefulWidget {
  const PaymentProcessingScreen({super.key, required this.isTrial});
  final bool isTrial;

  @override
  ConsumerState<PaymentProcessingScreen> createState() =>
      _PaymentProcessingScreenState();
}

class _PaymentProcessingScreenState
    extends ConsumerState<PaymentProcessingScreen> {
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = ref.read(checkoutControllerProvider.notifier);
      if (widget.isTrial) {
        controller.startTrial();
      } else {
        controller.startPaid();
      }
    });
  }

  void _onTerminal(CheckoutFlowState state) {
    if (_navigated || !mounted) return;
    _navigated = true;
    final route = state.phase == CheckoutPhase.success
        ? MaterialPageRoute<void>(
            builder: (_) => PremiumWelcomeScreen(isTrial: state.isTrial))
        : MaterialPageRoute<void>(
            builder: (_) => PaymentFailedScreen(
                  reason: state.error,
                  isTrial: state.isTrial,
                ));
    Navigator.of(context).pushReplacement(route);
  }

  int _activeStep(CheckoutPhase phase) {
    switch (phase) {
      case CheckoutPhase.idle:
      case CheckoutPhase.creatingOrder:
      case CheckoutPhase.awaitingGateway:
        return 0;
      case CheckoutPhase.verifying:
        return 1;
      case CheckoutPhase.activating:
        return 2;
      case CheckoutPhase.success:
        return 4;
      case CheckoutPhase.failed:
        return -1;
    }
  }

  StepState _stateFor(int index, CheckoutPhase phase) {
    if (phase == CheckoutPhase.success) return StepState.done;
    final active = _activeStep(phase);
    if (index < active) return StepState.done;
    if (index == active) return StepState.active;
    return StepState.pending;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final flow = ref.watch(checkoutControllerProvider);

    ref.listen<CheckoutFlowState>(checkoutControllerProvider, (_, next) {
      if (next.isTerminal) {
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _onTerminal(next));
      }
    });

    final labels = widget.isTrial
        ? const [
            'Starting free trial',
            'Verifying eligibility',
            'Activating premium',
            'Setting up your account',
          ]
        : const [
            'Payment initiated',
            'Verifying payment',
            'Activating premium',
            'Setting up your account',
          ];

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colorScheme.primary.withValues(alpha: 0.12),
                          ),
                          child: Icon(Icons.workspace_premium_rounded,
                              size: 48, color: colorScheme.primary),
                        ),
                        const SizedBox(height: AppSizes.lg),
                        Text('Processing Payment…',
                            style: textTheme.headlineSmall),
                        const SizedBox(height: AppSizes.xs),
                        Text(
                          "Please don't close this screen",
                          style: textTheme.bodyMedium
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.xl),
                  for (var i = 0; i < labels.length; i++)
                    ProcessingStep(
                      label: labels[i],
                      state: _stateFor(i, flow.phase),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
