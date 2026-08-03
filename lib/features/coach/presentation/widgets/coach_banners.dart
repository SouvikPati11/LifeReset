import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';

/// The standing safety disclaimer required on the AI Coach surfaces.
class SafetyDisclaimer extends StatelessWidget {
  const SafetyDisclaimer({super.key});

  static const String text =
      'AI Coach provides emotional support but is not a licensed therapist.';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSizes.sm),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded,
              size: AppSizes.iconSm, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Text(
              text,
              style: textTheme.bodySmall
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

/// Emergency support banner shown when a crisis/self-harm message is detected.
class CrisisBanner extends StatelessWidget {
  const CrisisBanner({super.key, required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.all(AppSizes.md),
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.health_and_safety_rounded, color: colorScheme.error),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You are not alone',
                  style: textTheme.titleSmall
                      ?.copyWith(color: colorScheme.onErrorContainer),
                ),
                const SizedBox(height: 2),
                Text(
                  'If you are in crisis, please contact your local emergency '
                  'number or a crisis helpline right now. Real help is '
                  'available.',
                  style: textTheme.bodySmall
                      ?.copyWith(color: colorScheme.onErrorContainer),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDismiss,
            icon: Icon(Icons.close_rounded, color: colorScheme.onErrorContainer),
          ),
        ],
      ),
    );
  }
}

/// Banner shown when the daily free message limit is reached.
class LimitBanner extends StatelessWidget {
  const LimitBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.all(AppSizes.md),
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Row(
        children: [
          Icon(Icons.lock_clock_rounded, color: colorScheme.onSecondaryContainer),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Text(
              "You've reached today's message limit. Upgrade to Premium for "
              'unlimited chats.',
              style: textTheme.bodySmall
                  ?.copyWith(color: colorScheme.onSecondaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}
