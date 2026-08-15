import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../home/presentation/widgets/home_style.dart';

/// Parses a `#RRGGBB` hex string to a [Color] (falls back to a violet).
Color hexColor(String hex) {
  var h = hex.replaceAll('#', '').trim();
  if (h.length == 6) h = 'FF$h';
  final value = int.tryParse(h, radix: 16);
  return value == null ? const Color(0xFF7C4DFF) : Color(value);
}

/// Maps a stored icon key to a Material icon.
IconData programIcon(String key) {
  switch (key) {
    case 'favorite':
      return Icons.favorite_rounded;
    case 'eco':
      return Icons.eco_rounded;
    case 'star':
      return Icons.star_rounded;
    case 'shield':
      return Icons.shield_rounded;
    case 'psychology':
      return Icons.psychology_rounded;
    case 'bedtime':
      return Icons.bedtime_rounded;
    case 'phone':
      return Icons.phone_iphone_rounded;
    case 'spa':
    default:
      return Icons.spa_rounded;
  }
}

/// Icon keys offered in the program form.
const List<String> kProgramIconKeys = [
  'spa',
  'favorite',
  'eco',
  'star',
  'shield',
  'psychology',
  'bedtime',
  'phone',
];

/// Confirms a destructive action.
Future<bool> confirmDelete(BuildContext context,
    {String message = 'This cannot be undone.'}) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Delete?'),
      content: Text(message),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel')),
        FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete')),
      ],
    ),
  );
  return ok ?? false;
}

/// A rounded surface used across the admin UI.
class ACard extends StatelessWidget {
  const ACard({super.key, required this.child, this.padding, this.onTap});
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
        boxShadow: HomeStyle.softShadow,
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

/// A responsive grid of [MetricTile]s: 4-across on desktop, 2-up on tablet and
/// mobile, with a fixed tile height so content never overflows at narrow
/// widths. Shared by the Dashboard and every analytics view.
class MetricGrid extends StatelessWidget {
  const MetricGrid({super.key, required this.tiles, this.tileHeight = 168});

  final List<Widget> tiles;
  final double tileHeight;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final cols = c.maxWidth >= 900 ? 4 : 2;
        final tileW = (c.maxWidth - (cols - 1) * AppSizes.md) / cols;
        return GridView.count(
          crossAxisCount: cols,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSizes.md,
          crossAxisSpacing: AppSizes.md,
          childAspectRatio: tileW / tileHeight,
          children: tiles,
        );
      },
    );
  }
}

/// A metric tile (icon, value, label, optional delta).
class MetricTile extends StatelessWidget {
  const MetricTile({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.delta,
    this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final String? delta;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final c = color ?? colorScheme.primary;
    return ACard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: c.withValues(alpha: 0.15),
            child: Icon(icon, size: 18, color: c),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(value,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              )),
          Text(label,
              style: textTheme.bodySmall
                  ?.copyWith(color: colorScheme.onSurfaceVariant)),
          if (delta != null) ...[
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.arrow_upward_rounded,
                    size: 12, color: Color(0xFF2E9E63)),
                Text(delta!,
                    style: textTheme.labelSmall
                        ?.copyWith(color: const Color(0xFF2E9E63))),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// A small colored status chip.
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
      ),
    );
  }
}
