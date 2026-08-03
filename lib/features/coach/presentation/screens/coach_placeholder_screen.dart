import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';

/// Placeholder destination for the AI Coach's navigation-only actions
/// (quick actions / suggested tools whose modules are not built yet).
class CoachPlaceholderScreen extends StatelessWidget {
  const CoachPlaceholderScreen({super.key, required this.title});

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
              Icon(Icons.spa_rounded, size: 48, color: colorScheme.primary),
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
