import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../home/presentation/widgets/home_style.dart';
import '../providers/admin_providers.dart';
import '../widgets/admin_charts.dart';
import '../widgets/admin_widgets.dart';

/// Distinct colours for the recovery-area bars, in enum order.
const List<Color> _problemColors = [
  Color(0xFF7C3AED),
  Color(0xFF9F7AEA),
  Color(0xFF10B981),
  Color(0xFFF59E0B),
];

/// Read-only analytics for the fixed onboarding problem set. Shows how many
/// users chose each recovery area and the share of the whole. No collection is
/// created and the onboarding enum is never mutated.
class ProblemsView extends ConsumerWidget {
  const ProblemsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final problems = ref.watch(problemDistributionProvider).valueOrNull ?? const [];
    final total = problems.fold<int>(0, (a, p) => a + p.count);

    return ListView(
      padding: const EdgeInsets.all(AppSizes.md),
      children: [
        MetricGrid(
          tiles: [
            MetricTile(
                icon: Icons.groups_rounded,
                value: '$total',
                label: 'Users Onboarded'),
            MetricTile(
                icon: Icons.category_rounded,
                value: '${problems.length}',
                label: 'Recovery Areas',
                color: colorScheme.tertiary),
          ],
        ),
        const SizedBox(height: AppSizes.md),
        ACard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Distribution by Problem', style: textTheme.titleMedium),
              const SizedBox(height: 2),
              Text('Read-only — reflects each user\'s onboarding selection.',
                  style: textTheme.bodySmall
                      ?.copyWith(color: colorScheme.onSurfaceVariant)),
              const SizedBox(height: AppSizes.md),
              if (total == 0)
                Text('No user data yet.', style: textTheme.bodySmall)
              else
                StatBars(
                  items: [
                    for (var i = 0; i < problems.length; i++)
                      (
                        problems[i].label,
                        problems[i].count,
                        _problemColors[i % _problemColors.length]
                      ),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.md),
        if (total > 0)
          ACard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Share of Users', style: textTheme.titleMedium),
                const SizedBox(height: AppSizes.md),
                for (var i = 0; i < problems.length; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: _problemColors[i % _problemColors.length],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: AppSizes.sm),
                        Expanded(
                          child: Text(problems[i].label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.bodyMedium),
                        ),
                        Text('${problems[i].count}',
                            style: textTheme.titleSmall),
                        const SizedBox(width: 6),
                        Text('(${(problems[i].count / total * 100).round()}%)',
                            style: textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        const SizedBox(height: AppSizes.md),
        Text(
          'Problem categories are fixed by onboarding and cannot be created or '
          'edited here.',
          style: textTheme.labelSmall?.copyWith(color: HomeStyle.inkSoft),
        ),
      ],
    );
  }
}
