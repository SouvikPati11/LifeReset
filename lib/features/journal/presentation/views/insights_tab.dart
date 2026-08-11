import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../home/presentation/providers/home_providers.dart';
import '../../../home/presentation/widgets/charts.dart';
import '../../../home/presentation/widgets/home_style.dart';
import '../../domain/entities/mood_entry.dart';
import '../providers/journal_providers.dart';

/// Insights = **analytics**. A headline insight, then a dominant trend chart as
/// the centrepiece, a compact row of metric tiles, and an encouragement footer —
/// a chart-led composition distinct from the dashboard/diary/tracker screens.
class InsightsTab extends ConsumerWidget {
  const InsightsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(journalStatsProvider);
    final analytics = ref.watch(moodAnalyticsProvider);
    final history = ref.watch(moodHistoryProvider).valueOrNull ?? const [];
    final userStats = ref.watch(userStatsProvider).valueOrNull;
    final tasks = ref.watch(dailyTasksProvider).valueOrNull ?? const [];

    final score = userStats?.recoveryScore ?? 0;
    final completedIds = userStats?.completedTaskIds ?? const <String>{};
    final doneToday = tasks.where((t) => completedIds.contains(t.id)).length;
    final taskPct = tasks.isEmpty ? null : (doneToday / tasks.length * 100).round();
    final moodDelta = _moodDeltaPercent(history);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.lg,
        AppSizes.sm,
        AppSizes.lg,
        AppSizes.xl,
      ),
      children: [
        _RecoveryInsight(
          moodDelta: moodDelta,
          entriesThisWeek: stats.entriesThisWeek,
          streak: analytics.streak,
        ),
        const SizedBox(height: AppSizes.lg),
        _MoodTrendChartCard(history: history, delta: moodDelta),
        const SizedBox(height: AppSizes.md),
        _MetricsRow(
          entriesThisWeek: stats.entriesThisWeek,
          taskPct: taskPct,
          score: score,
        ),
        const SizedBox(height: AppSizes.lg),
        const _Encouragement(),
      ],
    );
  }

  int? _moodDeltaPercent(List<MoodEntry> history) {
    final now = DateTime.now();
    double avg(Iterable<MoodEntry> xs) {
      final l = xs.toList();
      if (l.isEmpty) return 0;
      return l.map((e) => e.mood.score).reduce((a, b) => a + b) / l.length;
    }

    final thisWeek =
        history.where((e) => e.date.isAfter(now.subtract(const Duration(days: 7))));
    final prevWeek = history.where((e) =>
        e.date.isAfter(now.subtract(const Duration(days: 14))) &&
        e.date.isBefore(now.subtract(const Duration(days: 7))));
    final a = avg(thisWeek);
    final b = avg(prevWeek);
    if (a > 0 && b > 0) return ((a - b) / b * 100).round();
    return null;
  }
}

class _RecoveryInsight extends StatelessWidget {
  const _RecoveryInsight({
    required this.moodDelta,
    required this.entriesThisWeek,
    required this.streak,
  });

  final int? moodDelta;
  final int entriesThisWeek;
  final int streak;

  (String, String) get _content {
    if (moodDelta != null && moodDelta! > 0) {
      return (
        "You're making great progress! 🎉",
        'Your mood has improved by $moodDelta% this week and you\'ve been '
            'more consistent.',
      );
    }
    if (streak >= 3) {
      return (
        "You're building a strong habit 💪",
        "You're on a $streak-day tracking streak. Consistency is how healing "
            'sticks.',
      );
    }
    if (entriesThisWeek > 0) {
      return (
        'Keep showing up for yourself 💜',
        "You've journaled $entriesThisWeek "
            "${entriesThisWeek == 1 ? 'time' : 'times'} this week. Small steps "
            'add up.',
      );
    }
    if (moodDelta != null && moodDelta! < 0) {
      return (
        'Be gentle with yourself 💜',
        "This week was tougher — recovery isn't linear. Tomorrow is a fresh "
            'start.',
      );
    }
    return (
      'Your journey starts here 🌱',
      'Track your mood and journal to unlock personalized insights.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final (title, body) = _content;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        gradient: HomeStyle.scoreGradient,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: HomeStyle.softShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome_rounded,
                        color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'RECOVERY INSIGHT',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.sm),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 13.5, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.md),
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.trending_up_rounded,
                color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }
}

/// The analytical centrepiece: a wide mood-trend line chart.
class _MoodTrendChartCard extends StatelessWidget {
  const _MoodTrendChartCard({required this.history, required this.delta});

  final List<MoodEntry> history;
  final int? delta;

  @override
  Widget build(BuildContext context) {
    final sorted = [...history]..sort((a, b) => a.date.compareTo(b.date));
    final enough = sorted.length >= 2;
    final label = delta == null
        ? 'Tracking'
        : (delta! > 0 ? 'Improving' : (delta! < 0 ? 'Dipping' : 'Steady'));
    final color = delta != null && delta! < 0
        ? const Color(0xFFF97316)
        : const Color(0xFF10B981);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: HomeStyle.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: HomeStyle.border),
        boxShadow: HomeStyle.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.show_chart_rounded,
                  size: 18, color: HomeStyle.primary),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'Mood Trend',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: HomeStyle.ink,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                ),
                child: Text(
                  delta == null
                      ? label
                      : '$label · ${delta! >= 0 ? '+' : ''}$delta%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color.lerp(color, Colors.black, 0.25),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          if (enough)
            SizedBox(
              height: 110,
              child: RecoveryLineChart(
                values: sorted.map((e) => e.mood.score).toList(),
                lineColor: color,
                height: 110,
              ),
            )
          else
            const SizedBox(
              height: 110,
              child: Center(
                child: Text(
                  'Track your mood a few days to see your trend.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: HomeStyle.inkSoft),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A compact horizontal row of three small metric tiles.
class _MetricsRow extends StatelessWidget {
  const _MetricsRow({
    required this.entriesThisWeek,
    required this.taskPct,
    required this.score,
  });

  final int entriesThisWeek;
  final int? taskPct;
  final int score;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _Tile(
              icon: Icons.menu_book_rounded,
              value: '$entriesThisWeek',
              label: 'Journaled\nthis week',
              accent: HomeStyle.primary,
            ),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: _Tile(
              icon: Icons.check_circle_rounded,
              value: taskPct == null ? '—' : '$taskPct%',
              label: 'Tasks done\ntoday',
              accent: const Color(0xFF10B981),
              ring: taskPct,
            ),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: _Tile(
              icon: Icons.auto_graph_rounded,
              value: '$score',
              label: 'Recovery\nscore /100',
              accent: HomeStyle.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.value,
    required this.label,
    required this.accent,
    this.ring,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color accent;
  final int? ring;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: HomeStyle.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: HomeStyle.border),
        boxShadow: HomeStyle.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (ring != null)
            RecoveryScoreRing(
              score: ring!,
              maxScore: 100,
              progressColor: accent,
              trackColor: HomeStyle.lavender,
              size: 30,
              strokeWidth: 4,
              child: const SizedBox.shrink(),
            )
          else
            Icon(icon, size: 20, color: accent),
          const SizedBox(height: AppSizes.sm),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: accent,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: HomeStyle.inkSoft,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}

class _Encouragement extends StatelessWidget {
  const _Encouragement();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [HomeStyle.lavenderLight, HomeStyle.lavender],
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: HomeStyle.border),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Keep going! Small steps every day lead to big changes.',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: HomeStyle.ink,
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(width: AppSizes.md),
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.favorite_rounded,
                color: HomeStyle.primary, size: 22),
          ),
        ],
      ),
    );
  }
}
