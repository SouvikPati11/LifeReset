import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_sizes.dart';

/// Screen 1 — Welcome.
///
/// Full-bleed branded hero with the app mark, tagline and a "Get Started"
/// call-to-action. (The illustration asset can be dropped in behind the
/// gradient; until then the brand gradient stands in.)
class WelcomeStep extends StatelessWidget {
  const WelcomeStep({super.key, required this.onGetStarted});

  final VoidCallback onGetStarted;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final gradientEnd = Color.lerp(colorScheme.primary, Colors.black, 0.35)!;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [colorScheme.primary, gradientEnd],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          children: [
            const SizedBox(height: AppSizes.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.favorite_rounded, color: Colors.white),
                const SizedBox(width: AppSizes.sm),
                Text(
                  AppConstants.appName,
                  style: textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.md),
            Text(
              'Your journey starts today.\nBuild your personalized recovery plan.',
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
            const Spacer(),
            Icon(
              Icons.self_improvement_rounded,
              size: 120,
              color: Colors.white.withValues(alpha: 0.9),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onGetStarted,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: colorScheme.primary,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Get Started'),
                    SizedBox(width: AppSizes.sm),
                    Icon(Icons.arrow_forward_rounded, size: AppSizes.iconSm),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            Text(
              "You're not alone. We're here for you.",
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.75),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
