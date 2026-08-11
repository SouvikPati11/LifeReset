import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../home/domain/entities/user_stats.dart';
import '../../../home/presentation/providers/home_providers.dart';
import '../../../home/presentation/widgets/charts.dart';
import '../../../home/presentation/widgets/home_style.dart';
import '../../domain/entities/journal_entry.dart';
import '../../domain/entities/mood_entry.dart';
import '../providers/journal_providers.dart';
import '../screens/journal_entry_detail_screen.dart';

/// Overview = the recovery **dashboard**. Composition: a slim encouragement
/// banner, a dominant Recovery-Score gradient hero (score + trend + day), a
/// compact single-strip weekly summary, and a vertical **timeline** of recent
/// activity — deliberately different treatments, not a stack of white cards.
class OverviewTab extends ConsumerWidget {
  const OverviewTab({super.key, required this.onSeeAll});

  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(journalStatsProvider);
    final userStats = ref.watch(userStatsProvider).valueOrNull;
    final recent = ref.watch(recentEntriesProvider).valueOrNull ?? const [];
    final todayMood = ref.watch(todayMoodProvider).valueOrNull;

    final score = userStats?.recoveryScore ?? 0;
    final delta = userStats?.scoreDelta ?? 0;
    final hasHistory = (userStats?.scoreHistory.length ?? 0) >= 2;
    final currentDay = userStats?.currentDay ?? 1;
    const totalDays = 30;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.lg,
        AppSizes.sm,
        AppSizes.lg,
        AppSizes.xl,
      ),
      children: [
        const _EncouragementBanner(),
        const SizedBox(height: AppSizes.md),
        _ScoreHero(
          score: score,
          delta: delta,
          hasHistory: hasHistory,
          currentDay: currentDay,
          totalDays: totalDays,
          history: userStats?.scoreHistory ?? const [],
        ),
        const SizedBox(height: AppSizes.lg),
        _WeekStrip(
          entries: stats.entriesThisWeek,
          moodDays: stats.moodDaysThisWeek,
          scoreDelta: hasHistory ? delta : null,
          score: score,
        ),
        const SizedBox(height: AppSizes.lg),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Recent Activity',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: HomeStyle.ink,
                ),
              ),
            ),
            if (recent.isNotEmpty)
              TextButton(
                onPressed: onSeeAll,
                style: TextButton.styleFrom(
                  foregroundColor: HomeStyle.primary,
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('View All',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ),
          ],
        ),
        const SizedBox(height: AppSizes.md),
        _ActivityTimeline(entries: recent, todayMood: todayMood),
      ],
    );
  }
}

/// A slim inline banner — not a full card — so the score hero dominates.
class _EncouragementBanner extends StatelessWidget {
  const _EncouragementBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm,
      ),
      decoration: BoxDecoration(
        color: HomeStyle.lavenderLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
        border: Border.all(color: HomeStyle.border),
      ),
      child: const Row(
        children: [
          Icon(Icons.eco_rounded, size: 16, color: HomeStyle.primary),
          SizedBox(width: AppSizes.sm),
          Expanded(
            child: Text(
              'Every entry makes you stronger',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: HomeStyle.primaryDeep,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The dominant hero: big score, tier caption, trend and day progress, all on
/// the purple gradient. This is the visual centre of the dashboard.
class _ScoreHero extends StatelessWidget {
  const _ScoreHero({
    required this.score,
    required this.delta,
    required this.hasHistory,
    required this.currentDay,
    required this.totalDays,
    required this.history,
  });

  final int score;
  final int delta;
  final bool hasHistory;
  final int currentDay;
  final int totalDays;
  final List<ScorePoint> history;

  String get _caption {
    if (score < 60) return "Let's begin 💜";
    if (score < 75) return 'Good start — keep going 💜';
    if (score < 87) return "You're making progress 💜";
    return "You're on your way 💜";
  }

  @override
  Widget build(BuildContext context) {
    final percent = (currentDay / totalDays).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        gradient: HomeStyle.scoreGradient,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: HomeStyle.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RECOVERY SCORE',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // The big number scales down only if the row gets tight, so the
              // trend chart never gets pushed off the edge on narrow screens.
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$score',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 52,
                          fontWeight: FontWeight.w800,
                          height: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8, left: 4),
                        child: Text(
                          '/100',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (history.length >= 2) ...[
                const SizedBox(width: AppSizes.sm),
                SizedBox(
                  width: 96,
                  height: 44,
                  child: RecoveryLineChart(
                    values: history.map((p) => p.score).toList(),
                    lineColor: Colors.white,
                    height: 44,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Expanded(
                child: Text(
                  _caption,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                ),
                child: Text(
                  hasHistory
                      ? (delta >= 0 ? '↑ $delta this week' : '↓ ${delta.abs()} this week')
                      : 'Starting point',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.lg),
          Row(
            children: [
              Text(
                'Day $currentDay of $totalDays',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '${(percent * 100).round()}%',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusPill),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: percent),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              builder: (context, v, _) => LinearProgressIndicator(
                value: v,
                minHeight: 7,
                backgroundColor: Colors.white.withValues(alpha: 0.25),
                valueColor: const AlwaysStoppedAnimation(Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A single compact strip with three inline metrics — not three separate cards.
class _WeekStrip extends StatelessWidget {
  const _WeekStrip({
    required this.entries,
    required this.moodDays,
    required this.scoreDelta,
    required this.score,
  });

  final int entries;
  final int moodDays;
  final int? scoreDelta;
  final int score;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.md,
      ),
      decoration: BoxDecoration(
        color: HomeStyle.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: HomeStyle.border),
        boxShadow: HomeStyle.softShadow,
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _metric(Icons.menu_book_rounded, '$entries', 'Entries',
                HomeStyle.primary),
            _divider(),
            _metric(Icons.mood_rounded, '$moodDays/7', 'Mood',
                const Color(0xFFF59E0B)),
            _divider(),
            _metric(
              Icons.trending_up_rounded,
              scoreDelta == null
                  ? '$score'
                  : (scoreDelta! >= 0 ? '+$scoreDelta' : '$scoreDelta'),
              'Score',
              const Color(0xFF10B981),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() => Container(
        width: 1,
        margin: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
        color: HomeStyle.border,
      );

  Widget _metric(IconData icon, String value, String label, Color accent) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: accent),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: accent,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 11.5, color: HomeStyle.inkSoft),
          ),
        ],
      ),
    );
  }
}

/// Recent activity rendered as a vertical timeline (rail + dots), not cards.
class _ActivityTimeline extends StatelessWidget {
  const _ActivityTimeline({required this.entries, required this.todayMood});

  final List<JournalEntry> entries;
  final MoodEntry? todayMood;

  @override
  Widget build(BuildContext context) {
    final items = <_Act>[
      for (final e in entries)
        _Act(
          icon: Icons.menu_book_rounded,
          title: 'Journal entry',
          preview: e.content.isNotEmpty
              ? e.content
              : (e.title.isEmpty ? 'Untitled entry' : e.title),
          time: e.createdAt,
          entryId: e.id,
        ),
      if (todayMood != null)
        _Act(
          icon: Icons.mood_rounded,
          title: 'Mood update',
          preview: 'Feeling ${todayMood!.mood.emoji}',
          time: todayMood!.createdAt,
        ),
    ]..sort((a, b) => b.time.compareTo(a.time));

    if (items.isEmpty) {
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
        child: const Column(
          children: [
            Icon(Icons.timeline_rounded, color: HomeStyle.primary, size: 30),
            SizedBox(height: AppSizes.sm),
            Text(
              'No recent activity yet.',
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: HomeStyle.ink,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Write a journal entry or track your mood to see it here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: HomeStyle.inkSoft),
            ),
          ],
        ),
      );
    }

    final shown = items.take(5).toList();
    return Column(
      children: [
        for (var i = 0; i < shown.length; i++)
          _TimelineRow(item: shown[i], isLast: i == shown.length - 1),
      ],
    );
  }
}

class _Act {
  const _Act({
    required this.icon,
    required this.title,
    required this.preview,
    required this.time,
    this.entryId,
  });
  final IconData icon;
  final String title;
  final String preview;
  final DateTime time;
  final String? entryId;
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.item, required this.isLast});

  final _Act item;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : AppSizes.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: HomeStyle.ink,
                  ),
                ),
              ),
              Text(
                _relative(item.time),
                style: const TextStyle(fontSize: 11.5, color: HomeStyle.inkSoft),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            item.preview,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12.5,
              color: HomeStyle.inkSoft,
              height: 1.35,
            ),
          ),
        ],
      ),
    );

    final row = IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 34,
            child: Column(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: HomeStyle.lavender,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(item.icon, size: 15, color: HomeStyle.primary),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(width: 2, color: HomeStyle.border),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(child: content),
        ],
      ),
    );

    if (item.entryId == null) return row;
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => JournalEntryDetailScreen(entryId: item.entryId!),
        ),
      ),
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: row,
    );
  }

  String _relative(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays}d ago';
  }
}
