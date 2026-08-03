import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';

/// Placeholder destination for navigation-only profile items (Help Center,
/// FAQ, Privacy Policy, Terms, Billing History, etc.).
class ProfilePlaceholderScreen extends StatelessWidget {
  const ProfilePlaceholderScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.info_outline_rounded,
                  size: 48, color: colorScheme.primary),
              const SizedBox(height: AppSizes.md),
              Text(title, style: textTheme.titleLarge),
              const SizedBox(height: AppSizes.xs),
              Text(
                'Coming soon.',
                style: textTheme.bodyMedium
                    ?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
