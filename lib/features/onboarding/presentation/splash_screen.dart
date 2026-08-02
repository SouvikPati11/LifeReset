import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../../../theme/app_colors.dart';

/// Branded splash placeholder shown at launch.
///
/// This is the only screen implemented in the foundation build. It displays the
/// brand mark and tagline over the brand gradient. Navigation away from the
/// splash (to onboarding / auth / home) will be added once those flows exist;
/// for now it simply presents the brand.
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.brandGradient,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  ),
                  child: const Icon(
                    Icons.self_improvement_rounded,
                    color: Colors.white,
                    size: 56,
                  ),
                ),
                const SizedBox(height: AppSizes.lg),
                Text(
                  l10n.appName,
                  style: textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSizes.sm),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.xl),
                  child: Text(
                    l10n.appTagline,
                    textAlign: TextAlign.center,
                    style: textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.xxl),
                const SizedBox(
                  width: AppSizes.iconMd,
                  height: AppSizes.iconMd,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
                const SizedBox(height: AppSizes.xl),
                Text(
                  // Version 1 program scope.
                  AppConstants.supportedProgram
                      .replaceAll('_', ' ')
                      .toUpperCase(),
                  style: textTheme.labelSmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.6),
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
