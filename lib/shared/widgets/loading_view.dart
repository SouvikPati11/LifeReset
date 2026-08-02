import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';

/// A centered, reusable loading indicator with an optional message.
///
/// Use for full-screen or section-level loading states so spinners look
/// consistent across the app.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: AppSizes.md),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}

/// A small inline spinner sized for buttons and list tiles.
class InlineLoader extends StatelessWidget {
  const InlineLoader({super.key, this.size = AppSizes.iconMd});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: const CircularProgressIndicator(strokeWidth: 2),
    );
  }
}
