import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../home/presentation/widgets/home_style.dart';
import '../../domain/entities/mood_type.dart';

/// Shared Home-consistent building blocks for the Journey section, so Overview /
/// Journal / Mood / Insights all match Home and Plan exactly (same palette,
/// radius, shadows, spacing). Purely presentational — no data.

/// A white rounded card with a soft border + shadow (Home's card language).
class JCardX extends StatelessWidget {
  const JCardX({super.key, required this.child, this.onTap, this.padding});

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: HomeStyle.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: HomeStyle.border),
        boxShadow: HomeStyle.softShadow,
      ),
      child: child,
    );
    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        child: content,
      ),
    );
  }
}

/// A compact stat card ("4 / Journal Entries").
class JStat extends StatelessWidget {
  const JStat({
    super.key,
    required this.value,
    required this.label,
    this.icon,
    this.accent = HomeStyle.primary,
  });

  final String value;
  final String label;
  final IconData? icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return JCardX(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.sm,
        vertical: AppSizes.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: accent),
            const SizedBox(height: AppSizes.sm),
          ],
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: accent,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              color: HomeStyle.inkSoft,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class JSectionTitle extends StatelessWidget {
  const JSectionTitle(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: HomeStyle.ink,
            ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// A soft lavender empty state used across the Journey tabs.
class JEmptyState extends StatelessWidget {
  const JEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.lg,
        vertical: AppSizes.xl,
      ),
      decoration: BoxDecoration(
        color: HomeStyle.lavenderLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: HomeStyle.border),
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: HomeStyle.lavender,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: HomeStyle.primary, size: 24),
          ),
          const SizedBox(height: AppSizes.md),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w700,
              color: HomeStyle.ink,
            ),
          ),
          const SizedBox(height: AppSizes.xs),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: HomeStyle.inkSoft,
              height: 1.35,
            ),
          ),
          if (action != null) ...[
            const SizedBox(height: AppSizes.lg),
            action!,
          ],
        ],
      ),
    );
  }
}

/// The Home-style purple gradient CTA button (e.g. "+ New Journal").
class JPrimaryButton extends StatelessWidget {
  const JPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.fullWidth = false,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  /// When true the button fills its parent width and the label ellipsizes —
  /// used for empty-state CTAs. When false it's compact (e.g. the header).
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final label0 = Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14.5,
        fontWeight: FontWeight.w700,
      ),
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: HomeStyle.scoreGradient,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        boxShadow: HomeStyle.softShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md,
              vertical: 12,
            ),
            child: Row(
              mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: Colors.white, size: 18),
                  const SizedBox(width: 6),
                ],
                fullWidth ? Flexible(child: label0) : label0,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A small mood pill ("🙂 Good") in the mood's pastel tint.
class MoodPill extends StatelessWidget {
  const MoodPill({super.key, required this.mood});

  final MoodType mood;

  @override
  Widget build(BuildContext context) {
    final tint = journeyMoodColor(mood);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(mood.emoji, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 4),
          Text(
            moodLabel(mood),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color.lerp(tint, Colors.black, 0.35),
            ),
          ),
        ],
      ),
    );
  }
}

/// Friendly display label for a mood (maps the existing enum to the Journey
/// mock's wording without changing stored values).
String moodLabel(MoodType mood) {
  switch (mood) {
    case MoodType.awful:
      return 'Very Bad';
    case MoodType.sad:
      return 'Bad';
    case MoodType.anxious:
      return 'Anxious';
    case MoodType.okay:
      return 'Okay';
    case MoodType.good:
      return 'Good';
    case MoodType.great:
      return 'Great';
  }
}

/// Pastel colour per mood, in the Journey palette (purple/soft supporting hues).
Color journeyMoodColor(MoodType mood) {
  switch (mood) {
    case MoodType.awful:
      return const Color(0xFFEF4444);
    case MoodType.sad:
      return const Color(0xFFF97316);
    case MoodType.anxious:
      return const Color(0xFFF59E0B);
    case MoodType.okay:
      return const Color(0xFFF59E0B);
    case MoodType.good:
      return const Color(0xFF7C3AED);
    case MoodType.great:
      return const Color(0xFF10B981);
  }
}
