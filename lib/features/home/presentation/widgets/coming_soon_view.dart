import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';

/// A lightweight placeholder for modules that are not built yet.
///
/// Used by the non-Home bottom-navigation tabs and the Quick Actions, which are
/// navigation-only in this module.
class ComingSoonView extends StatelessWidget {
  const ComingSoonView({
    super.key,
    required this.title,
    this.icon = Icons.hourglass_empty_rounded,
    this.showAppBar = false,
  });

  final String title;
  final IconData icon;
  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final body = Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: colorScheme.primary),
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
    );

    if (!showAppBar) return body;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: body,
    );
  }
}
