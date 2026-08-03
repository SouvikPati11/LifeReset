import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../domain/entities/daily_quote.dart';
import '../providers/home_providers.dart';

/// The Daily Inspiration card: today's motivational quote on a branded surface.
class DailyInspirationCard extends ConsumerWidget {
  const DailyInspirationCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final quote = ref.watch(dailyQuoteProvider).valueOrNull ?? DailyQuote.fallback;
    final gradientEnd = Color.lerp(colorScheme.primary, Colors.black, 0.45)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorScheme.primary, gradientEnd],
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: const Icon(Icons.format_quote_rounded, color: Colors.white),
          ),
          const SizedBox(height: AppSizes.md),
          Text(
            quote.text,
            style: textTheme.titleMedium?.copyWith(
              color: Colors.white,
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSizes.md),
          Text(
            '— ${quote.author}',
            style: textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
