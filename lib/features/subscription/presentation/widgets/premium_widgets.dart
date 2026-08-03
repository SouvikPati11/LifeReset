import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';

/// Brand accent used across the premium surfaces.
const Color kPremiumGold = Color(0xFFF5A623);
const Color kPremiumIndigo = Color(0xFF1B1B3A);
const Color kSuccessGreen = Color(0xFF2E9E63);

/// A circular gold crown badge (the recurring premium motif).
class CrownBadge extends StatelessWidget {
  const CrownBadge({super.key, this.size = 64, this.icon = Icons.workspace_premium_rounded});
  final double size;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: kPremiumGold.withValues(alpha: 0.15),
      ),
      child: Icon(icon, size: size * 0.55, color: kPremiumGold),
    );
  }
}

/// A rounded surface card used across the premium screens.
class SectionCard extends StatelessWidget {
  const SectionCard({super.key, required this.child, this.padding, this.color});
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: color ?? colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: child,
    );
  }
}

/// A premium-feature row (icon tile + title + subtitle) on the paywall.
class FeatureTile extends StatelessWidget {
  const FeatureTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: textTheme.titleSmall),
                Text(subtitle,
                    style: textTheme.bodySmall
                        ?.copyWith(color: colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A compact benefit chip (e.g. "AI Coach Unlocked") on the welcome screen.
class BenefitChip extends StatelessWidget {
  const BenefitChip({super.key, required this.icon, required this.label, required this.color});
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md, vertical: AppSizes.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Text(label,
                style: textTheme.labelMedium, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

/// State of a single step in the payment-processing checklist.
enum ProcessingStepState { done, active, pending }

/// A row in the "Processing Payment" checklist.
class ProcessingStep extends StatelessWidget {
  const ProcessingStep({super.key, required this.label, required this.state});
  final String label;
  final ProcessingStepState state;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    Widget leading;
    Color labelColor;
    switch (state) {
      case ProcessingStepState.done:
        leading = const Icon(Icons.check_circle_rounded,
            size: 22, color: kSuccessGreen);
        labelColor = colorScheme.onSurface;
      case ProcessingStepState.active:
        leading = SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
              strokeWidth: 2.5, color: colorScheme.primary),
        );
        labelColor = colorScheme.onSurface;
      case ProcessingStepState.pending:
        leading = Icon(Icons.radio_button_unchecked_rounded,
            size: 22, color: colorScheme.outline);
        labelColor = colorScheme.onSurfaceVariant;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
      child: Row(
        children: [
          leading,
          const SizedBox(width: AppSizes.md),
          Text(label,
              style: textTheme.bodyLarge?.copyWith(color: labelColor)),
        ],
      ),
    );
  }
}

/// A small colored status pill (e.g. "Active").
class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
      ),
      child: Text(
        label,
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// A labelled key/value row used on the subscription-details card.
class DetailRow extends StatelessWidget {
  const DetailRow({super.key, required this.label, required this.value, this.valueWidget});
  final String label;
  final String value;
  final Widget? valueWidget;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: textTheme.bodyMedium
                  ?.copyWith(color: colorScheme.onSurfaceVariant)),
          valueWidget ??
              Text(value,
                  style: textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
