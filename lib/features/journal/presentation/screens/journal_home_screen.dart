import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../home/presentation/widgets/home_style.dart';
import '../views/insights_tab.dart';
import '../views/journal_history_tab.dart';
import '../views/mood_tab.dart';
import '../views/overview_tab.dart';
import '../widgets/journey_ui.dart';
import 'new_journal_screen.dart';

/// "LifeReset Journey" — the healing-journey home with Overview / Journal /
/// Mood / Insights tabs, styled to match Home and Plan (HomeStyle). Sits inside
/// the app's bottom-nav shell (the Journey tab stays selected throughout).
class JournalHomeScreen extends ConsumerStatefulWidget {
  const JournalHomeScreen({super.key});

  @override
  ConsumerState<JournalHomeScreen> createState() => _JournalHomeScreenState();
}

class _JournalHomeScreenState extends ConsumerState<JournalHomeScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(length: 4, vsync: this)
    ..addListener(() => setState(() {}));

  static const _tabs = ['Overview', 'Journal', 'Mood', 'Insights'];

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  void _go(int i) => _tab.animateTo(i);

  static const _titles = [
    ('LifeReset Journey', 'Track your healing journey'),
    ('Your Journal', 'A private space for your thoughts.'),
    ('How are you feeling?', 'Track your mood and see your patterns.'),
    ('Your Insights', 'Understand your patterns and growth.'),
  ];

  @override
  Widget build(BuildContext context) {
    final index = _tab.index;
    final (title, subtitle) = _titles[index];

    return Scaffold(
      backgroundColor: HomeStyle.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(
              title: title,
              subtitle: subtitle,
              action: switch (index) {
                0 => _SquareButton(
                    icon: Icons.calendar_month_rounded,
                    onTap: () => _go(2),
                  ),
                1 => JPrimaryButton(
                    label: 'New Journal',
                    icon: Icons.add_rounded,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const NewJournalScreen()),
                    ),
                  ),
                _ => null,
              },
            ),
            const SizedBox(height: AppSizes.md),
            _SegmentedTabs(
              tabs: _tabs,
              current: _tab.index,
              onSelect: _go,
            ),
            const SizedBox(height: AppSizes.sm),
            Expanded(
              child: TabBarView(
                controller: _tab,
                children: [
                  OverviewTab(onSeeAll: () => _go(1)),
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

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.subtitle, this.action});

  final String title;
  final String subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    // "LifeReset Journey" gets the two-tone treatment; the per-tab titles are
    // rendered in solid ink.
    final Widget titleWidget = title == 'LifeReset Journey'
        ? const Text.rich(
            TextSpan(
              children: [
                TextSpan(
                    text: 'LifeReset ', style: TextStyle(color: HomeStyle.ink)),
                TextSpan(
                    text: 'Journey', style: TextStyle(color: HomeStyle.primary)),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          )
        : Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: HomeStyle.ink,
            ),
          );

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSizes.lg, AppSizes.md, AppSizes.lg, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                titleWidget,
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, color: HomeStyle.inkSoft),
                ),
              ],
            ),
          ),
          if (action != null) ...[
            const SizedBox(width: AppSizes.sm),
            action!,
          ],
        ],
      ),
    );
  }
}

class _SquareButton extends StatelessWidget {
  const _SquareButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
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
  }
}

/// A purple segmented control for the four Journey sections (selected = purple
/// filled pill, matching the Home/Plan selected-state language).
class _SegmentedTabs extends StatelessWidget {
  const _SegmentedTabs({
    required this.tabs,
    required this.current,
    required this.onSelect,
  });

  final List<String> tabs;
  final int current;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: HomeStyle.lavenderLight,
          borderRadius: BorderRadius.circular(AppSizes.radiusPill),
          border: Border.all(color: HomeStyle.border),
        ),
        child: Row(
          children: [
            for (var i = 0; i < tabs.length; i++)
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onSelect(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      color: current == i ? HomeStyle.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                    ),
                    child: Text(
                      tabs[i],
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: current == i ? Colors.white : HomeStyle.inkSoft,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
