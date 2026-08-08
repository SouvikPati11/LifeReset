import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../widgets/onboarding_style.dart';

/// Screen 1 — Welcome.
///
/// "Welcome to LifeReset" heading, the meditating-sunrise hero (shared with the
/// login screen), a translucent feature card, and the purple "Start Your
/// Journey" call-to-action.
class WelcomeStep extends StatelessWidget {
  const WelcomeStep({super.key, required this.onGetStarted});

  final VoidCallback onGetStarted;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: AppSizes.sm),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSizes.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Welcome to\n',
                      style: TextStyle(color: OnboardingStyle.ink),
                    ),
                    TextSpan(
                      text: 'LifeReset',
                      style: TextStyle(color: OnboardingStyle.accent),
                    ),
                  ],
                ),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: AppSizes.sm),
              Text(
                "Let's heal, grow and become the best version of you.",
                style: OnboardingStyle.subtitle,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.md),
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/auth/hero_login.webp',
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  errorBuilder: (context, error, stackTrace) =>
                      const DecoratedBox(
                    decoration:
                        BoxDecoration(gradient: OnboardingStyle.pageGradient),
                  ),
                ),
              ),
              const Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.all(AppSizes.md),
                  child: _FeatureCard(),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.lg,
            AppSizes.md,
            AppSizes.lg,
            AppSizes.sm,
          ),
          child: OnboardingButton(
            label: 'Start Your Journey',
            onPressed: onGetStarted,
          ),
        ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.lg,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF3A2E6B).withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          _Feature(icon: Icons.favorite_rounded, label: 'Personalized\nfor you'),
          _Feature(icon: Icons.auto_awesome_rounded, label: 'AI-Powered\nsupport'),
          _Feature(
              icon: Icons.trending_up_rounded, label: 'Track your\nprogress'),
        ],
      ),
    );
  }
}

class _Feature extends StatelessWidget {
  const _Feature({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
