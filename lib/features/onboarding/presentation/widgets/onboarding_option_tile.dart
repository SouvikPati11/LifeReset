import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_sizes.dart';
import 'onboarding_style.dart';

/// A single-select option row used by the question steps, matching the Figma:
/// an optional leading icon chip, a bold title with a muted description, and a
/// trailing radio. Selection turns the border/title purple and tints the fill.
class OnboardingOptionTile extends StatelessWidget {
  const OnboardingOptionTile({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.description,
    this.icon,
  });

  final String label;
  final String? description;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.sm + 4),
      child: Material(
        color: selected ? OnboardingStyle.selectedFill : OnboardingStyle.surface,
        borderRadius: BorderRadius.circular(OnboardingStyle.fieldRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(OnboardingStyle.fieldRadius),
          child: AnimatedContainer(
            duration: AppConstants.shortAnimation,
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md,
              vertical: AppSizes.md,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(OnboardingStyle.fieldRadius),
              border: Border.all(
                color: selected ? OnboardingStyle.accent : OnboardingStyle.border,
                width: selected ? 1.8 : 1,
              ),
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: OnboardingStyle.chipBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, size: 22, color: OnboardingStyle.accent),
                  ),
                  const SizedBox(width: AppSizes.md),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: selected
                              ? OnboardingStyle.accent
                              : OnboardingStyle.ink,
                        ),
                      ),
                      if (description != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          description!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: OnboardingStyle.bodyGray,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                _Radio(selected: selected),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Radio extends StatelessWidget {
  const _Radio({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppConstants.shortAnimation,
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? OnboardingStyle.accent : const Color(0xFFCBC7DA),
          width: 2,
        ),
        color: selected ? OnboardingStyle.accent : Colors.transparent,
      ),
      child: selected
          ? const Center(
              child: Icon(Icons.check_rounded, size: 14, color: Colors.white),
            )
          : null,
    );
  }
}
