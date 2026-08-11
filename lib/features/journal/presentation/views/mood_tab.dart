import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../home/presentation/widgets/home_style.dart';
import '../../domain/entities/mood_entry.dart';
import '../../domain/entities/mood_type.dart';
import '../controllers/mood_check_controller.dart';
import '../providers/journal_providers.dart';
import '../widgets/journey_ui.dart';

/// Mood = a **tracker**. The large 5-level selector is the primary focus,
/// followed by a horizontal weekly bar visualization and a compact, dense mood
/// history — a different shape from the dashboard and analytics screens.
class MoodTab extends ConsumerWidget {
  const MoodTab({super.key});

  Future<void> _save(WidgetRef ref, BuildContext context, MoodType mood) async {
    final ok = await ref
        .read(moodCheckControllerProvider.notifier)
        .save(mood: mood, note: '', factors: const []);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Could not save your mood. Try again.')),
        );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(todayMoodProvider).valueOrNull;
    final history = ref.watch(moodHistoryProvider).valueOrNull ?? const [];

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.lg,
        AppSizes.sm,
        AppSizes.lg,
        AppSizes.xl,
      ),
      children: [
        _MoodSelector(
          selected: today?.mood,
          onSelect: (m) => _save(ref, context, m),
        ),
        const SizedBox(height: AppSizes.lg),
        const Text(
          'This Week',
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w700, color: HomeStyle.ink),
        ),
        const SizedBox(height: AppSizes.md),
        _WeeklyBars(history: history),
        const SizedBox(height: AppSizes.lg),
        const Text(
          'Mood History',
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w700, color: HomeStyle.ink),
        ),
        const SizedBox(height: AppSizes.md),
        if (history.isEmpty)
          const JEmptyState(
            icon: Icons.insights_rounded,
            title: 'No mood history yet.',
            message: 'Record how you feel to start seeing your patterns.',
          )
        else
          _HistoryList(history: history),
      ],
    );
  }
}

/// The large, expressive mood selector — the hero of the Mood tab.
class _MoodSelector extends StatelessWidget {
  const _MoodSelector({required this.selected, required this.onSelect});

  final MoodType? selected;
  final ValueChanged<MoodType> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [HomeStyle.lavenderLight, HomeStyle.card],
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: HomeStyle.border),
        boxShadow: HomeStyle.softShadow,
      ),
      child: Column(
        children: [
          Text(
            selected == null
                ? 'How are you feeling today?'
                : "Today you're feeling ${moodLabel(selected!).toLowerCase()}",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: HomeStyle.ink,
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final mood in MoodType.journalScale)
                Expanded(
                  child: _BigFace(
                    mood: mood,
                    selected: selected == mood,
                    onTap: () => onSelect(mood),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BigFace extends StatelessWidget {
  const _BigFace({
    required this.mood,
    required this.selected,
    required this.onTap,
  });

  final MoodType mood;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tint = journeyMoodColor(mood);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? tint.withValues(alpha: 0.18) : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? tint : HomeStyle.border,
                width: selected ? 2.5 : 1,
              ),
              boxShadow: selected ? HomeStyle.softShadow : null,
            ),
            child: Text(mood.emoji,
                style: TextStyle(fontSize: selected ? 27 : 24)),
          ),
          const SizedBox(height: 6),
          Text(
            moodLabel(mood),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? Color.lerp(tint, Colors.black, 0.3) : HomeStyle.inkSoft,
            ),
          ),
        ],
      ),
    );
  }
}

/// A horizontal weekly bar chart (Mon–Sun) — mood score as bar height, coloured
/// per mood. Missing days stay empty; nothing is fabricated.
class _WeeklyBars extends StatelessWidget {
  const _WeeklyBars({required this.history});

  final List<MoodEntry> history;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final monday = today.subtract(Duration(days: today.weekday - 1));
    final byDay = <DateTime, MoodType>{
      for (final e in history)
        DateTime(e.date.year, e.date.month, e.date.day): e.mood,
    };
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Container(
      height: 156,
      padding: const EdgeInsets.fromLTRB(
        AppSizes.md,
        AppSizes.md,
        AppSizes.md,
        AppSizes.sm,
      ),
      decoration: BoxDecoration(
        color: HomeStyle.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: HomeStyle.border),
        boxShadow: HomeStyle.softShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < 7; i++)
            Expanded(
              child: _Bar(
                label: labels[i],
                mood: byDay[monday.add(Duration(days: i))],
              ),
            ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.label, required this.mood});

  final String label;
  final MoodType? mood;

  @override
  Widget build(BuildContext context) {
    final tint = mood == null ? null : journeyMoodColor(mood!);
    final factor = mood == null ? 0.0 : (mood!.score / 10).clamp(0.12, 1.0);
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          height: 14,
          child: mood == null
              ? const SizedBox.shrink()
              : Text(mood!.emoji, style: const TextStyle(fontSize: 12)),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: factor),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
              builder: (context, v, _) => FractionallySizedBox(
                heightFactor: mood == null ? 1 : v,
                child: Container(
                  width: 12,
                  decoration: BoxDecoration(
                    color: tint?.withValues(alpha: 0.85) ??
                        HomeStyle.lavenderLight,
                    borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                    border: mood == null
                        ? Border.all(color: HomeStyle.border)
                        : null,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: HomeStyle.inkSoft,
          ),
        ),
      ],
    );
  }
}

/// A compact, dense chronological list — small rows, not full cards.
class _HistoryList extends StatelessWidget {
  const _HistoryList({required this.history});

  final List<MoodEntry> history;

  @override
  Widget build(BuildContext context) {
    final sorted = [...history]..sort((a, b) => b.date.compareTo(a.date));
    final items = sorted.take(12).toList();
    final now = DateTime.now();

    return Container(
      decoration: BoxDecoration(
        color: HomeStyle.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: HomeStyle.border),
        boxShadow: HomeStyle.softShadow,
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i != 0)
              const Divider(height: 1, thickness: 1, color: HomeStyle.border),
            _HistoryRow(entry: items[i], now: now),
          ],
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.entry, required this.now});

  final MoodEntry entry;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final isToday = entry.date.year == now.year &&
        entry.date.month == now.month &&
        entry.date.day == now.day;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: 10,
      ),
      child: Row(
        children: [
          Text(entry.mood.emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Text(
              isToday
                  ? 'Today'
                  : DateFormat('EEE, MMM d').format(entry.date),
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: HomeStyle.ink,
              ),
            ),
          ),
          Text(
            moodLabel(entry.mood),
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: Color.lerp(journeyMoodColor(entry.mood), Colors.black, 0.3),
            ),
          ),
        ],
      ),
    );
  }
}
