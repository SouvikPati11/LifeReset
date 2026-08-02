import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/responsive_layout.dart';
import '../controllers/auth_controller.dart';
import '../providers/auth_providers.dart';

/// Blocks unverified users from entering the app until they confirm their
/// email. Auto-refreshes the verification status on a timer, and lets the user
/// resend the email or sign out.
class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  static const Duration _pollInterval = Duration(seconds: 4);
  static const int _resendCooldownSeconds = 30;

  Timer? _pollTimer;
  Timer? _cooldownTimer;
  int _cooldown = 0;

  @override
  void initState() {
    super.initState();
    // Auto refresh verification status; the router moves the user on once
    // verification is detected (via provider invalidation in the controller).
    _pollTimer = Timer.periodic(_pollInterval, (_) {
      ref.read(authControllerProvider.notifier).refreshVerificationStatus();
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    setState(() => _cooldown = _resendCooldownSeconds);
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_cooldown <= 1) {
        timer.cancel();
        if (mounted) setState(() => _cooldown = 0);
      } else if (mounted) {
        setState(() => _cooldown--);
      }
    });
  }

  Future<void> _resend() async {
    final sent =
        await ref.read(authControllerProvider.notifier).resendVerificationEmail();
    if (!mounted) return;
    if (sent) {
      _startCooldown();
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Verification email sent.')),
        );
    }
  }

  Future<void> _checkNow() async {
    final verified =
        await ref.read(authControllerProvider.notifier).refreshVerificationStatus();
    if (!mounted || verified) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Not verified yet. Please check your inbox.')),
      );
  }

  @override
  Widget build(BuildContext context) {
    final email = ref.watch(authStateChangesProvider).valueOrNull?.email ?? '';
    final isLoading = ref.watch(authControllerProvider).isLoading;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify your email'),
        actions: [
          TextButton(
            onPressed: () =>
                ref.read(authControllerProvider.notifier).signOut(),
            child: const Text('Sign out'),
          ),
        ],
      ),
      body: SafeArea(
        child: ContentContainer(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.lg,
            vertical: AppSizes.md,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.mark_email_read_outlined,
                size: 72,
                color: colorScheme.primary,
              ),
              const SizedBox(height: AppSizes.lg),
              Text(
                'Confirm your email',
                textAlign: TextAlign.center,
                style: textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSizes.sm),
              Text(
                email.isEmpty
                    ? 'We sent a verification link to your email. Open it to continue.'
                    : 'We sent a verification link to $email. Open it to continue.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSizes.xl),
              PrimaryButton(
                label: "I've verified",
                icon: Icons.check_circle_outline_rounded,
                isLoading: isLoading,
                onPressed: _checkNow,
              ),
              const SizedBox(height: AppSizes.sm),
              OutlinedButton(
                onPressed: (isLoading || _cooldown > 0) ? null : _resend,
                child: Text(
                  _cooldown > 0
                      ? 'Resend email in ${_cooldown}s'
                      : 'Resend verification email',
                ),
              ),
              const SizedBox(height: AppSizes.lg),
              Text(
                'This screen updates automatically once your email is verified.',
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
