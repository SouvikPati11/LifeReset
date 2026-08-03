import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../providers/journal_providers.dart';
import '../screens/journal_entry_detail_screen.dart';
import '../screens/mood_check_screen.dart';
import '../screens/new_journal_screen.dart';
import '../widgets/journal_widgets.dart';

/// Overview tab: hero, quick actions, weekly stats and recent entries.
class OverviewTab extends ConsumerWidget {
  const OverviewTab({super.key, required this.onSeeAll});

  final VoidCallback onSeeAll;

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final stats = ref.watch(journalStatsProvider);
    final recovery = ref.watch(recoveryScoreProvider);
    final recent = ref.watch(recentEntriesProvider).valueOrNull ?? const [];

    return ListView(
      padding: const EdgeInsets.all(AppSizes.md),
      children: [
        _HeroCard(),
        const SizedBox(height: AppSizes.md),
        Row(
          children: [
            Expanded(
              child: _QuickAction(
                icon: Icons.edit_note_rounded,
                title: 'New Journal',
                subtitle: 'Write your thoughts',
                onTap: () => _push(context, const NewJournalScreen()),
              ),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: _QuickAction(
                icon: Icons.mood_rounded,
                title: 'Add Mood',
                subtitle: 'How are you feeling?',
                onTap: () => _push(context, const MoodCheckScreen()),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.lg),
        Text('This Week', style: textTheme.titleMedium),
        const SizedBox(height: AppSizes.sm),
        Row(
          children: [
            Expanded(
              child: StatCard(
                value: '${stats.entriesThisWeek}',
                label: 'Journal Entries',
              ),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: StatCard(
                value: '${stats.moodDaysThisWeek}/7',
                label: 'Mood Tracked',
              ),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: StatCard(
                value: '$recovery',
                label: 'Recovery Score',
                valueColor: colorScheme.tertiary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.lg),
        Row(
          children: [
            Text('Recent Entries', style: textTheme.titleMedium),
            const Spacer(),
            TextButton(onPressed: onSeeAll, child: const Text('See All')),
          ],
        ),
        if (recent.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
            child: Text(
              'No entries yet. Start writing above.',
              style: textTheme.bodyMedium
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          )
        else
          for (final entry in recent.take(3))
            JournalEntryTile(
              entry: entry,
              onTap: () => _push(
                context,
                JournalEntryDetailScreen(entryId: entry.id),
              ),
            ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final end = Color.lerp(colorScheme.primary, Colors.black, 0.35)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorScheme.primary, end],
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Every entry\nmakes you stronger',
            style: textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            'Your mental health is improving step by step',
            style: textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return JCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: colorScheme.primaryContainer.withValues(alpha: 0.5),
            child: Icon(icon, size: 18, color: colorScheme.primary),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(title, style: textTheme.titleSmall),
          Text(
            subtitle,
            style: textTheme.bodySmall
                ?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
