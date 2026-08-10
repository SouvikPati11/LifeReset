import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/errors/failures.dart';
import '../controllers/onboarding_controller.dart';
import '../widgets/onboarding_style.dart';

/// Screen 8 — Subscription / 7-Day Trial.
///
/// The subscription is OPTIONAL. Both actions finish onboarding through the same
/// secure completion mechanism ([OnboardingController.complete]) — which marks
/// `onboardingCompleted` on `users/{uid}` and never touches `subscription`
/// (so it stays `free`) — after which the router guard moves the user into the
/// app. No payment is processed here.
///
///  • "Start Free Trial" — the primary CTA (kept as-is).
///  • "Skip" — a subtle top-right action for users who don't want the trial.
///
/// The two are distinct affordances but share the completion path: neither ever
/// fakes a subscription, and neither navigates to Home unless the Firestore
/// completion write actually succeeds.
class SubscriptionStep extends ConsumerWidget {
  const SubscriptionStep({super.key});

  static const List<String> _perks = [
    'Personalized AI Coaching',
    'Daily Tasks & Reminders',
    'Mood Tracking & Insights',
    'Unlimited Journal Entries',
    'Progress Analytics',
  ];

  /// Skip the trial and finish onboarding. Uses the same secure completion write
  /// as [_startTrial]; `subscription` is left untouched (stays `free`) and Home
  /// opens only if the write succeeds.
  Future<void> _skip(BuildContext context, WidgetRef ref) =>
      _finishOnboarding(context, ref);

  /// Start the free trial and finish onboarding. (No payment is processed; the
  /// user is only marked as onboarded, not as subscribed.)
  Future<void> _startTrial(BuildContext context, WidgetRef ref) =>
      _finishOnboarding(context, ref);

  /// Shared completion runner: persists onboarding completion and, on failure,
  /// surfaces the ACTUAL reason (e.g. permission denied, no network) instead of
  /// a blanket message. On success the router redirects into the app.
  Future<void> _finishOnboarding(BuildContext context, WidgetRef ref) async {
    final ok = await ref.read(onboardingControllerProvider.notifier).complete();
    if (!ok && context.mounted) {
      final failure = ref
          .read(onboardingControllerProvider)
          .submission
          .whenOrNull(error: (e, _) => e is Failure ? e : null);
      final message = failure?.message ?? 'Could not continue. Please try again.';
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSubmitting = ref.watch(
      onboardingControllerProvider.select((s) => s.isSubmitting),
    );

    // The scrollable block holds the hero/perks/price; the CTA and footer are
    // pinned below so they stay on-screen (matching the Figma one-screen layout).
    return Column(
      children: [
        // Optional-subscription escape hatch: a subtle top-right "Skip" that
        // finishes onboarding without the trial. Deliberately less prominent
        // than the primary CTA (text-only) so the Figma layout is preserved.
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: AppSizes.sm, top: AppSizes.xs),
            child: TextButton(
              onPressed: isSubmitting ? null : () => _skip(context, ref),
              style: TextButton.styleFrom(
                foregroundColor: OnboardingStyle.bodyGray,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.sm,
                  vertical: AppSizes.xs,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Skip',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
        const Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              AppSizes.lg,
              AppSizes.sm,
              AppSizes.lg,
              AppSizes.sm,
            ),
            child: Column(
              children: [
                _CrownIcon(),
                SizedBox(height: AppSizes.xs),
                Text(
                  'Start Your 7-Day Trial',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: OnboardingStyle.ink,
                  ),
                ),
                SizedBox(height: AppSizes.xs),
                Text(
                  'Unlock your full recovery plan\nand premium features.',
                  textAlign: TextAlign.center,
                  style: OnboardingStyle.subtitle,
                ),
                SizedBox(height: AppSizes.md),
                _PerksCard(perks: _perks),
                SizedBox(height: AppSizes.sm),
                _PriceCard(),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.lg,
            AppSizes.sm,
            AppSizes.lg,
            AppSizes.md,
          ),
          child: Column(
            children: [
              OnboardingButton(
                label: 'Start Free Trial',
                isLoading: isSubmitting,
                onPressed: isSubmitting ? null : () => _startTrial(context, ref),
              ),
              const SizedBox(height: AppSizes.sm),
              const Text(
                'Cancel anytime. No commitment.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: OnboardingStyle.bodyGray),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A purple crown illustration with gold jewels (replaces the flat emoji).
class _CrownIcon extends StatelessWidget {
  const _CrownIcon();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 84,
      height: 64,
      child: CustomPaint(painter: _CrownPainter()),
    );
  }
}

class _CrownPainter extends CustomPainter {
  const _CrownPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Sparkles around the crown.
    final sparkle = Paint()..color = const Color(0xFFFBBF24);
    void star(double cx, double cy, double r) {
      canvas.drawCircle(Offset(cx, cy), r, sparkle);
    }

    star(w * 0.08, h * 0.2, 2.4);
    star(w * 0.93, h * 0.16, 3);
    star(w * 0.86, h * 0.42, 2);

    // Crown body.
    final crown = Path()
      ..moveTo(w * 0.04, h * 0.64)
      ..lineTo(w * 0.10, h * 0.16)
      ..lineTo(w * 0.30, h * 0.50)
      ..lineTo(w * 0.50, h * 0.08)
      ..lineTo(w * 0.70, h * 0.50)
      ..lineTo(w * 0.90, h * 0.16)
      ..lineTo(w * 0.96, h * 0.64)
      ..lineTo(w * 0.88, h * 0.96)
      ..lineTo(w * 0.12, h * 0.96)
      ..close();

    canvas.drawPath(
      crown,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [OnboardingStyle.purpleEnd, OnboardingStyle.purpleStart],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // Base band highlight.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.12, h * 0.66, w * 0.76, h * 0.16),
        const Radius.circular(4),
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.18),
    );

    // Jewels on the peak tips + centre band.
    final jewel = Paint()..color = const Color(0xFFFBBF24);
    canvas.drawCircle(Offset(w * 0.10, h * 0.18), 4, jewel);
    canvas.drawCircle(Offset(w * 0.50, h * 0.12), 5, jewel);
    canvas.drawCircle(Offset(w * 0.90, h * 0.18), 4, jewel);
    canvas.drawCircle(Offset(w * 0.50, h * 0.74), 5, jewel);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PerksCard extends StatelessWidget {
  const _PerksCard({required this.perks});

  final List<String> perks;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.lg,
        vertical: AppSizes.sm,
      ),
      decoration: BoxDecoration(
        color: OnboardingStyle.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: OnboardingStyle.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final perk in perks)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: OnboardingStyle.accent, size: AppSizes.iconMd),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: Text(
                      perk,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: OnboardingStyle.ink,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _PriceCard extends StatelessWidget {
  const _PriceCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.lg,
        vertical: AppSizes.md,
      ),
      decoration: BoxDecoration(
        color: OnboardingStyle.selectedFill,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: OnboardingStyle.accent.withValues(alpha: 0.4)),
      ),
      child: const Column(
        children: [
          Text(
            '7-Day Free Trial',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: OnboardingStyle.ink,
            ),
          ),
          SizedBox(height: AppSizes.xs),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '₹299',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: OnboardingStyle.accent,
                  ),
                ),
                TextSpan(
                  text: ' / month after trial',
                  style: TextStyle(
                    fontSize: 14,
                    color: OnboardingStyle.bodyGray,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
