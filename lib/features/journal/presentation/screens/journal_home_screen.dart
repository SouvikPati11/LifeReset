import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../views/insights_tab.dart';
import '../views/journal_history_tab.dart';
import '../views/mood_tab.dart';
import '../views/overview_tab.dart';
import 'new_journal_screen.dart';

/// Journal & Mood home ("LifeReset Journey") with Overview / Journal / Mood /
/// Insights tabs. Designed to sit inside the app's bottom-nav shell.
class JournalHomeScreen extends ConsumerStatefulWidget {
  const JournalHomeScreen({super.key});

  @override
  ConsumerState<JournalHomeScreen> createState() => _JournalHomeScreenState();
}

class _JournalHomeScreenState extends ConsumerState<JournalHomeScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(length: 4, vsync: this);

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const NewJournalScreen()),
        ),
        child: const Icon(Icons.edit_rounded),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.md,
                AppSizes.sm,
                AppSizes.md,
                0,
              ),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome_rounded, color: colorScheme.primary),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('LifeReset Journey', style: textTheme.titleMedium),
                        Text(
                          'Track your healing journey',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _tab.animateTo(2),
                    icon: const Icon(Icons.calendar_month_rounded),
                  ),
                ],
              ),
            ),
            TabBar(
              controller: _tab,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Journal'),
                Tab(text: 'Mood'),
                Tab(text: 'Insights'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tab,
                children: [
                  OverviewTab(onSeeAll: () => _tab.animateTo(1)),
                  const JournalHistoryTab(),
                  const MoodTab(),
                  const InsightsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
