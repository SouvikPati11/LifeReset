import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';
import '../../theme/app_colors.dart';

/// A reusable success confirmation state.
///
/// Use after a flow completes successfully (e.g. subscription activated,
/// journal saved) to give clear positive feedback with an optional next step.
class SuccessView extends StatelessWidget {
  const SuccessView({
    super.key,
    required this.title,
    this.message,
    this.action,
  });

  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_rounded,
              size: AppSizes.iconLg + 12,
              color: AppColors.success,
            ),
            const SizedBox(height: AppSizes.md),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            if (message != null) ...[
              const SizedBox(height: AppSizes.sm),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: AppSizes.lg),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
