import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';

/// A rounded surface used across the profile UI.
class PCard extends StatelessWidget {
  const PCard({super.key, required this.child, this.padding, this.onTap});

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final content = Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: child,
    );
    if (onTap == null) return content;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      child: content,
    );
  }
}

/// A tappable settings/list row with a leading icon and optional trailing.
class SettingTile extends StatelessWidget {
  const SettingTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor,
    this.titleColor,
    this.showChevron = true,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? titleColor;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.sm,
          vertical: AppSizes.md,
        ),
        child: Row(
          children: [
            Icon(icon, size: AppSizes.iconMd,
                color: iconColor ?? colorScheme.primary),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: textTheme.bodyLarge?.copyWith(color: titleColor)),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
            if (showChevron && onTap != null)
              Padding(
                padding: const EdgeInsets.only(left: AppSizes.sm),
                child: Icon(Icons.chevron_right_rounded,
                    color: colorScheme.onSurfaceVariant),
              ),
          ],
        ),
      ),
    );
  }
}

/// A section title.
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.sm, top: AppSizes.md),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
