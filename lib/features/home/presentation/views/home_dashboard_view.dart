import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../../authentication/presentation/providers/user_providers.dart';
import '../../../coach/presentation/screens/coach_home_screen.dart';
import '../../../journal/presentation/screens/journal_home_screen.dart';
import '../../../journal/presentation/screens/mood_check_screen.dart';
import '../../../notifications/presentation/screens/notifications_inbox_screen.dart';
import '../../../profile/presentation/screens/profile_home_screen.dart';
import '../../../progress/presentation/screens/progress_screen.dart';
import '../../domain/entities/daily_quote.dart';
import '../../domain/entities/daily_task.dart';
import '../../domain/entities/recovery_program.dart';
import '../../domain/entities/user_stats.dart';
import '../providers/home_providers.dart';
import '../screens/todays_plan_screen.dart';
import '../widgets/charts.dart';
import '../widgets/home_style.dart';
import '../widgets/quick_actions_grid.dart';

/// The Home tab: a calm, personal recovery dashboard.
///
/// Sections load independently — each shows a skeleton while its data is
/// loading, a compact retry card on error (keeping any cached data visible),
/// and a designed empty state rather than raw "no data" text. All values are
/// read from the real providers; nothing is faked.
class HomeDashboardView extends ConsumerWidget {
  const HomeDashboardView({super.key});

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  void _openQuickAction(BuildContext context, String title) {
    final Widget screen = switch (title) {
      'Journal' => const JournalHomeScreen(),
      'Mood' => const MoodCheckScreen(),
      'Progress' => const ProgressScreen(),
      'AI Coach' => const CoachHomeScreen(),
      _ => const TodaysPlanScreen(),
    };
    _push(context, screen);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider).valueOrNull;

    return ColoredBox(
      color: HomeStyle.background,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.lg,
            AppSizes.md,
            AppSizes.lg,
            AppSizes.xl,
          ),
          children: [
            _Header(
              name: _firstName(profile?.name),
              photoUrl: profile?.photoUrl,
              onNotifications: () =>
                  _push(context, const NotificationsInboxScreen()),
              onAvatar: () => _push(context, const ProfileHomeScreen()),
            ),
            const SizedBox(height: AppSizes.lg),
            const _ScoreHero(),
            const SizedBox(height: AppSizes.md),
            const _JourneyCard(),
            const SizedBox(height: AppSizes.md),
            const _FocusCard(),
            const SizedBox(height: AppSizes.lg),
            _TodaysPlan(onViewAll: () => _push(context, const TodaysPlanScreen())),
            const SizedBox(height: AppSizes.lg),
            const _InsightCard(),
            const SizedBox(height: AppSizes.lg),
            const _SectionTitle('Quick Actions'),
            const SizedBox(height: AppSizes.md),
            QuickActionsGrid(onOpen: (title) => _openQuickAction(context, title)),
          ],
        ),
      ),
    );
  }

  String _firstName(String? fullName) {
    final name = (fullName ?? '').trim();
    if (name.isEmpty) return 'there';
    return name.split(' ').first;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({
    required this.name,
    required this.photoUrl,
    required this.onNotifications,
    required this.onAvatar,
  });

  final String name;
  final String? photoUrl;
  final VoidCallback onNotifications;
  final VoidCallback onAvatar;

  String get _timeGreeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '$_timeGreeting, ',
                      style: const TextStyle(color: HomeStyle.ink),
                    ),
                    TextSpan(
                      text: name,
                      style: const TextStyle(color: HomeStyle.primary),
                    ),
                    const TextSpan(
                      text: ' 👋',
                      style: TextStyle(color: HomeStyle.ink),
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Let's take one small step forward today.",
                style: TextStyle(fontSize: 14, color: HomeStyle.inkSoft),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSizes.sm),
        _CircleButton(
          onTap: onNotifications,
          child: const Icon(Icons.notifications_none_rounded,
              color: HomeStyle.ink, size: 22),
        ),
        const SizedBox(width: AppSizes.sm),
        _Avatar(name: name, photoUrl: photoUrl, onTap: onAvatar),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: HomeStyle.card,
      shape: const CircleBorder(),
      elevation: 0,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(width: 44, height: 44, child: Center(child: child)),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name, required this.photoUrl, required this.onTap});

  final String name;
  final String? photoUrl;
  final VoidCallback onTap;

  String get _initials {
    final trimmed = name.trim();
    if (trimmed.isEmpty || trimmed == 'there') return '🙂';
    return trimmed.characters.first.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final hasPhoto = (photoUrl ?? '').isNotEmpty;
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: HomeStyle.scoreGradient,
        ),
        clipBehavior: Clip.antiAlias,
        child: hasPhoto
            ? Image.network(
                photoUrl!,
                fit: BoxFit.cover,
                width: 44,
                height: 44,
                errorBuilder: (_, __, ___) => _initialsLabel(),
              )
            : _initialsLabel(),
      ),
    );
  }

  Widget _initialsLabel() => Text(
        _initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Recovery Score hero
// ─────────────────────────────────────────────────────────────────────────────

class _ScoreHero extends ConsumerWidget {
  const _ScoreHero();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(userStatsProvider);
    return _AsyncSection<UserStats>(
      value: statsAsync,
      skeletonHeight: 210,
      onRetry: () => ref.invalidate(userStatsProvider),
      builder: (stats) => _ScoreHeroCard(stats: stats),
    );
  }
}

class _ScoreHeroCard extends StatelessWidget {
  const _ScoreHeroCard({required this.stats});

  final UserStats stats;

  @override
  Widget build(BuildContext context) {
    final history = stats.scoreHistory;
    final hasHistory = history.length >= 2;

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
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              RecoveryScoreRing(
                score: stats.recoveryScore,
                maxScore: 100,
                progressColor: Colors.white,
                trackColor: Colors.white.withValues(alpha: 0.25),
                size: 116,
                strokeWidth: 11,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${stats.recoveryScore}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        height: 1.0,
                      ),
                    ),
                    Text(
                      '/100',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSizes.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'YOUR RECOVERY SCORE',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: AppSizes.sm),
                    Text(
                      HomeStyle.scoreCaption(stats.recoveryScore),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: AppSizes.sm),
                    _DeltaPill(stats: stats, hasHistory: hasHistory),
                  ],
                ),
              ),
            ],
          ),
          if (hasHistory) ...[
            const SizedBox(height: AppSizes.md),
            _WeekStrip(history: history),
          ],
        ],
      ),
    );
  }
}

class _DeltaPill extends StatelessWidget {
  const _DeltaPill({required this.stats, required this.hasHistory});

  final UserStats stats;
  final bool hasHistory;

  @override
  Widget build(BuildContext context) {
    final String label;
    IconData? icon;
    if (!hasHistory) {
      label = 'Your starting point';
    } else {
      final delta = stats.scoreDelta;
      if (delta > 0) {
        icon = Icons.arrow_upward_rounded;
        label = '$delta points from yesterday';
      } else if (delta < 0) {
        icon = Icons.arrow_downward_rounded;
        label = '${delta.abs()} points from yesterday';
      } else {
        label = 'No change from yesterday';
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 15, color: Colors.white),
            const SizedBox(width: 4),
          ],
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekStrip extends StatelessWidget {
  const _WeekStrip({required this.history});

  final List<ScorePoint> history;

  @override
  Widget build(BuildContext context) {
    // Show up to the last 7 real score points (no fabricated data).
    final points = history.length > 7
        ? history.sublist(history.length - 7)
        : history;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.md,
      ),
      decoration: BoxDecoration(
        color: HomeStyle.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Row(
        children: [
          for (var i = 0; i < points.length; i++)
            Expanded(
              child: _DayDot(
                label: points[i].weekdayLabel,
                score: points[i].score,
                highlight: i == points.length - 1,
              ),
            ),
        ],
      ),
    );
  }
}

class _DayDot extends StatelessWidget {
  const _DayDot({
    required this.label,
    required this.score,
    required this.highlight,
  });

  final String label;
  final int score;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: HomeStyle.inkSoft,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: highlight ? HomeStyle.primary : HomeStyle.lavender,
            shape: BoxShape.circle,
          ),
          child: Text(
            '$score',
            style: TextStyle(
              color: highlight ? Colors.white : HomeStyle.primaryDeep,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Recovery Journey
// ─────────────────────────────────────────────────────────────────────────────

class _JourneyCard extends ConsumerWidget {
  const _JourneyCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(userStatsProvider);
    final program = ref.watch(recoveryProgramProvider).valueOrNull ??
        RecoveryProgram.defaultProgram();

    return _AsyncSection<UserStats>(
      value: statsAsync,
      skeletonHeight: 132,
      onRetry: () => ref.invalidate(userStatsProvider),
      builder: (stats) {
        final total = program.totalDays <= 0 ? 30 : program.totalDays;
        final percent = (stats.currentDay / total).clamp(0.0, 1.0);
        return _WhiteCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Your Recovery Journey',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: HomeStyle.ink,
                      ),
                    ),
                  ),
                  Text(
                    '${(percent * 100).round()}% Complete',
                    style: const TextStyle(
                      color: HomeStyle.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.sm),
              Text(
                'Day ${stats.currentDay} of $total',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: HomeStyle.ink,
                ),
              ),
              const SizedBox(height: AppSizes.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: percent),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOut,
                  builder: (context, value, _) => LinearProgressIndicator(
                    value: value,
                    minHeight: 9,
                    backgroundColor: HomeStyle.lavender,
                    valueColor:
                        const AlwaysStoppedAnimation(HomeStyle.primary),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.md),
              const Row(
                children: [
                  Icon(Icons.eco_rounded, size: 18, color: HomeStyle.primary),
                  SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: Text(
                      "Keep going — you're building healthier habits every day.",
                      style: TextStyle(
                        fontSize: 13,
                        color: HomeStyle.inkSoft,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Personalized Focus
// ─────────────────────────────────────────────────────────────────────────────

class _FocusCard extends ConsumerWidget {
  const _FocusCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final focus =
        ref.watch(homeFocusProvider).valueOrNull ?? HomeFocus.fromProblem(null);

    return _WhiteCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: HomeStyle.lavender,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Icon(focus.icon, color: HomeStyle.primary, size: 22),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'YOUR FOCUS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: HomeStyle.inkSoft,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  focus.title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: HomeStyle.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  focus.subtitle,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: HomeStyle.inkSoft,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Today's Plan
// ─────────────────────────────────────────────────────────────────────────────

class _TodaysPlan extends ConsumerWidget {
  const _TodaysPlan({required this.onViewAll});

  final VoidCallback onViewAll;

  Future<void> _toggle(
    WidgetRef ref,
    BuildContext context,
    String taskId,
    bool completed,
  ) async {
    final uid = ref.read(currentUserProvider)?.id;
    if (uid == null) return;
    final result = await ref
        .read(setTaskCompletedUseCaseProvider)
        .call(uid: uid, taskId: taskId, completed: completed);
    result.when(
      success: (_) {},
      failure: (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(content: Text('Could not save. Please try again.')),
            );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(dailyTasksProvider);
    final stats = ref.watch(userStatsProvider).valueOrNull ?? UserStats.initial();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(child: _SectionTitle("Today's Plan")),
            _ViewAll(onTap: onViewAll),
          ],
        ),
        const SizedBox(height: AppSizes.sm),
        _AsyncSection<List<DailyTask>>(
          value: tasksAsync,
          skeletonHeight: 180,
          onRetry: () => ref.invalidate(dailyTasksProvider),
          builder: (tasks) {
            if (tasks.isEmpty) return const _PlanEmptyState();
            final shown = tasks.length > 3 ? tasks.sublist(0, 3) : tasks;
            return Column(
              children: [
                for (var i = 0; i < shown.length; i++) ...[
                  if (i != 0) const SizedBox(height: AppSizes.sm),
                  _PlanTaskRow(
                    task: shown[i],
                    completed: stats.isTaskCompleted(shown[i].id),
                    onToggle: (v) => _toggle(ref, context, shown[i].id, v),
                    onOpen: onViewAll,
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _PlanTaskRow extends StatelessWidget {
  const _PlanTaskRow({
    required this.task,
    required this.completed,
    required this.onToggle,
    required this.onOpen,
  });

  final DailyTask task;
  final bool completed;
  final ValueChanged<bool> onToggle;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: completed ? 0.6 : 1,
      child: Material(
        color: HomeStyle.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: InkWell(
          onTap: onOpen,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          child: Container(
            padding: const EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(color: HomeStyle.border),
            ),
            child: Row(
              children: [
                _CheckDot(completed: completed, onToggle: onToggle),
                const SizedBox(width: AppSizes.md),
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: HomeStyle.lavenderLight,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  child: Icon(_iconFor(task), color: HomeStyle.primary, size: 20),
                ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: HomeStyle.ink,
                          decoration:
                              completed ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      if (task.description.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          task.description,
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
                const SizedBox(width: AppSizes.sm),
                const Icon(Icons.chevron_right_rounded,
                    color: HomeStyle.inkSoft),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _iconFor(DailyTask task) {
    final key = (task.iconKey ?? task.title).toLowerCase();
    if (key.contains('breath') || key.contains('calm')) {
      return Icons.self_improvement_rounded;
    }
    if (key.contains('journal') || key.contains('write') || key.contains('let')) {
      return Icons.edit_note_rounded;
    }
    if (key.contains('reflect') || key.contains('morning')) {
      return Icons.wb_sunny_rounded;
    }
    if (key.contains('walk')) return Icons.directions_walk_rounded;
    if (key.contains('care') || key.contains('self')) {
      return Icons.volunteer_activism_rounded;
    }
    if (key.contains('mood')) return Icons.mood_rounded;
    return Icons.spa_rounded;
  }
}

class _CheckDot extends StatelessWidget {
  const _CheckDot({required this.completed, required this.onToggle});

  final bool completed;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onToggle(!completed),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 26,
        height: 26,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: completed ? HomeStyle.success : Colors.transparent,
          border: Border.all(
            color: completed ? HomeStyle.success : HomeStyle.primarySoft,
            width: 2,
          ),
        ),
        child: completed
            ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
            : null,
      ),
    );
  }
}

/// Designed empty state for Today's Plan — polished, never a bare "no tasks".
class _PlanEmptyState extends StatelessWidget {
  const _PlanEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.lg,
        vertical: AppSizes.xl,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [HomeStyle.lavenderLight, HomeStyle.successSoft],
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: HomeStyle.border),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: HomeStyle.scoreGradient,
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                color: Colors.white, size: 26),
          ),
          const SizedBox(height: AppSizes.md),
          const Text(
            'Your plan is being prepared',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: HomeStyle.ink,
            ),
          ),
          const SizedBox(height: AppSizes.xs),
          const Text(
            'Your personalized recovery activities will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.5, color: HomeStyle.inkSoft, height: 1.35),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Daily Insight
// ─────────────────────────────────────────────────────────────────────────────

class _InsightCard extends ConsumerWidget {
  const _InsightCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quoteAsync = ref.watch(dailyQuoteProvider);
    return _AsyncSection<DailyQuote>(
      value: quoteAsync,
      skeletonHeight: 140,
      onRetry: () => ref.invalidate(dailyQuoteProvider),
      builder: (quote) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSizes.lg),
        decoration: BoxDecoration(
          color: HomeStyle.insightBg,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(color: HomeStyle.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome_rounded,
                    size: 16, color: HomeStyle.primary),
                const SizedBox(width: 6),
                Text(
                  'DAILY INSIGHT',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: HomeStyle.primaryDeep.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.md),
            Text(
              '“${quote.text}”',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: HomeStyle.ink,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              '— ${quote.author}',
              style: const TextStyle(
                fontSize: 13,
                color: HomeStyle.inkSoft,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared building blocks
// ─────────────────────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: HomeStyle.ink,
      ),
    );
  }
}

class _ViewAll extends StatelessWidget {
  const _ViewAll({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: HomeStyle.primary,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('View All',
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
          SizedBox(width: 2),
          Icon(Icons.arrow_forward_rounded, size: 16),
        ],
      ),
    );
  }
}

class _WhiteCard extends StatelessWidget {
  const _WhiteCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: HomeStyle.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: HomeStyle.border),
        boxShadow: HomeStyle.softShadow,
      ),
      child: child,
    );
  }
}

/// Renders [builder] when data is (or was) available, a skeleton while first
/// loading, and a compact retry card on error with no cached value — keeping
/// any previously loaded data visible during a refresh/transient error.
class _AsyncSection<T> extends StatelessWidget {
  const _AsyncSection({
    required this.value,
    required this.builder,
    required this.skeletonHeight,
    required this.onRetry,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) builder;
  final double skeletonHeight;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (value.hasValue) return builder(value.requireValue);
    if (value.isLoading) return _SkeletonCard(height: skeletonHeight);
    return _SectionErrorCard(onRetry: onRetry);
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: HomeStyle.lavenderLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: HomeStyle.border),
      ),
      child: const Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.4,
            valueColor: AlwaysStoppedAnimation(HomeStyle.primarySoft),
          ),
        ),
      ),
    );
  }
}

class _SectionErrorCard extends StatelessWidget {
  const _SectionErrorCard({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: HomeStyle.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: HomeStyle.border),
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_rounded, color: HomeStyle.inkSoft),
          const SizedBox(height: AppSizes.sm),
          const Text(
            "Couldn't refresh your recovery data.",
            textAlign: TextAlign.center,
            style: TextStyle(color: HomeStyle.ink, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSizes.sm),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(foregroundColor: HomeStyle.primary),
            child: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}
