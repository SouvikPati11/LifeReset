import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';
import '../../features/home/presentation/widgets/home_style.dart';

/// LifeReset shared UI kit.
///
/// A small set of presentational primitives built on the approved [HomeStyle]
/// design language (off-white background, deep-navy ink, #7C3AED purple accent,
/// lavender surfaces, large radii, soft shadows). Used by Coach, Profile and
/// Notifications so those features share one visual system with Home / Plan /
/// Journey without each screen reimplementing the same containers.
///
/// This intentionally reuses [HomeStyle] tokens rather than introducing a
/// second palette. Journey keeps its own `journey_ui.dart`; both draw from the
/// same tokens, so the app reads as a single system.

/// A screen header: an optional back button, a two-tone title + subtitle, and an
/// optional trailing action. Title/subtitle ellipsize so narrow widths never
/// overflow.
class LsHeader extends StatelessWidget {
  const LsHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.lg,
        AppSizes.md,
        AppSizes.lg,
        0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (onBack != null) ...[
            LsSquareButton(icon: Icons.arrow_back_rounded, onTap: onBack!),
            const SizedBox(width: AppSizes.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: HomeStyle.ink,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      color: HomeStyle.inkSoft,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: AppSizes.sm),
            trailing!,
          ],
        ],
      ),
    );
  }
}

/// A 44×44 lavender square icon button (headers / actions).
class LsSquareButton extends StatelessWidget {
  const LsSquareButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.badgeCount = 0,
  });

  final IconData icon;
  final VoidCallback onTap;

  /// When > 0, a small purple count badge is shown on the corner.
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: HomeStyle.lavender,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: HomeStyle.primary, size: 22),
        ),
      ),
    );
    if (badgeCount <= 0) return button;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        button,
        Positioned(
          right: -4,
          top: -4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            constraints: const BoxConstraints(minWidth: 18),
            decoration: BoxDecoration(
              color: HomeStyle.primary,
              borderRadius: BorderRadius.circular(AppSizes.radiusPill),
              border: Border.all(color: Colors.white, width: 1.5),
            ),
            child: Text(
              badgeCount > 9 ? '9+' : '$badgeCount',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// A section title with an optional trailing widget (e.g. a "View all" button).
class LsSectionTitle extends StatelessWidget {
  const LsSectionTitle(this.text, {super.key, this.trailing});

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

/// A small uppercase group label (settings sections).
class LsGroupLabel extends StatelessWidget {
  const LsGroupLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSizes.xs, bottom: AppSizes.sm),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
          color: HomeStyle.inkSoft,
        ),
      ),
    );
  }
}

/// A white rounded surface with the shared soft border + shadow.
class LsCard extends StatelessWidget {
  const LsCard({super.key, required this.child, this.padding, this.onTap});

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

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

/// A grouped list container: a white rounded card with hairline dividers
/// between its [children] (settings-style sections).
class LsGroup extends StatelessWidget {
  const LsGroup({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: HomeStyle.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: HomeStyle.border),
        boxShadow: HomeStyle.softShadow,
      ),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i != 0)
              const Divider(
                height: 1,
                thickness: 1,
                indent: 56,
                color: HomeStyle.border,
              ),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// A tinted rounded-square icon container.
class LsIconBadge extends StatelessWidget {
  const LsIconBadge({
    super.key,
    required this.icon,
    this.color = HomeStyle.primary,
    this.size = 38,
  });

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Icon(icon, size: size * 0.5, color: color),
    );
  }
}

/// A list row: a tinted icon badge, a title with optional subtitle, and either a
/// custom [trailing] widget or a chevron. Safe at narrow widths (text flexes).
class LsRow extends StatelessWidget {
  const LsRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor = HomeStyle.primary,
    this.titleColor = HomeStyle.ink,
    this.showChevron = true,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color iconColor;
  final Color titleColor;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final row = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: 12,
      ),
      child: Row(
        children: [
          LsIconBadge(icon: icon, color: iconColor, size: 36),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: titleColor,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: HomeStyle.inkSoft,
                      height: 1.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: AppSizes.sm),
            trailing!,
          ] else if (showChevron && onTap != null) ...[
            const SizedBox(width: AppSizes.sm),
            const Icon(Icons.chevron_right_rounded,
                color: HomeStyle.inkSoft, size: 20),
          ],
        ],
      ),
    );
    if (onTap == null) return row;
    return InkWell(onTap: onTap, child: row);
  }
}

/// A pill chip (topic / filter). Purple when [selected], lavender otherwise.
class LsChip extends StatelessWidget {
  const LsChip({
    super.key,
    required this.label,
    this.icon,
    this.selected = false,
    this.onTap,
  });

  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? Colors.white : HomeStyle.primaryDeep;
    return Material(
      color: selected ? HomeStyle.primary : HomeStyle.lavender,
      borderRadius: BorderRadius.circular(AppSizes.radiusPill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md,
            vertical: AppSizes.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 15, color: fg),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The primary purple gradient CTA, with an optional loading state. When
/// [expand] is true it fills its parent width and the label ellipsizes.
class LsButton extends StatelessWidget {
  const LsButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    final child = loading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              valueColor: AlwaysStoppedAnimation(Colors.white),
            ),
          )
        : Row(
            mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: Colors.white, size: 18),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          );

    return Opacity(
      opacity: enabled ? 1 : 0.6,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: HomeStyle.scoreGradient,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          boxShadow: HomeStyle.softShadow,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            onTap: enabled ? onPressed : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.lg,
                vertical: 14,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// A soft secondary (lavender) button.
class LsSecondaryButton extends StatelessWidget {
  const LsSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: HomeStyle.lavender,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.lg,
            vertical: 14,
          ),
          child: Row(
            mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: HomeStyle.primaryDeep, size: 18),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: HomeStyle.primaryDeep,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A soft lavender empty state (icon in a circle, title, message, action).
class LsEmpty extends StatelessWidget {
  const LsEmpty({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
    this.tone = HomeStyle.primary,
  });

  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 92,
              height: 92,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    HomeStyle.lavenderLight,
                    tone.withValues(alpha: 0.18),
                  ],
                ),
              ),
              child: Icon(icon, size: 40, color: tone),
            ),
            const SizedBox(height: AppSizes.lg),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: HomeStyle.ink,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: AppSizes.sm),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: HomeStyle.inkSoft,
                  height: 1.45,
                ),
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: AppSizes.xl),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// A centered purple spinner for section/full-screen loading.
class LsLoader extends StatelessWidget {
  const LsLoader({super.key, this.size = 28});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: const CircularProgressIndicator(
          strokeWidth: 2.6,
          valueColor: AlwaysStoppedAnimation(HomeStyle.primarySoft),
        ),
      ),
    );
  }
}

/// A compact inline error card with a retry action.
class LsErrorState extends StatelessWidget {
  const LsErrorState({
    super.key,
    required this.title,
    this.message,
    this.onRetry,
  });

  final String title;
  final String? message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const LsIconBadge(
              icon: Icons.cloud_off_rounded,
              color: HomeStyle.inkSoft,
              size: 56,
            ),
            const SizedBox(height: AppSizes.md),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: HomeStyle.ink,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: AppSizes.xs),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: HomeStyle.inkSoft),
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: AppSizes.lg),
              LsSecondaryButton(
                label: 'Try again',
                icon: Icons.refresh_rounded,
                expand: false,
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
