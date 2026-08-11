import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../home/presentation/widgets/home_style.dart';
import '../../domain/entities/journal_entry.dart';
import '../controllers/journal_history_controller.dart';
import '../screens/journal_entry_detail_screen.dart';
import '../screens/new_journal_screen.dart';
import '../widgets/journey_ui.dart';

/// Journal = a **diary timeline**. Entries flow down a continuous left rail with
/// date nodes and a reading-focused body — intentionally unlike the dashboard's
/// cards. New-Journal lives in the Journey header.
class JournalHistoryTab extends ConsumerStatefulWidget {
  const JournalHistoryTab({super.key});

  @override
  ConsumerState<JournalHistoryTab> createState() => _JournalHistoryTabState();
}

class _JournalHistoryTabState extends ConsumerState<JournalHistoryTab> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 300) {
        ref.read(journalHistoryControllerProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _openNew() => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const NewJournalScreen()),
      );

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(journalHistoryControllerProvider);

    return async.when(
      loading: () => const Center(
        child: SizedBox(
          width: 26,
          height: 26,
          child: CircularProgressIndicator(
            strokeWidth: 2.6,
            valueColor: AlwaysStoppedAnimation(HomeStyle.primarySoft),
          ),
        ),
      ),
      error: (_, __) => ListView(
        padding: const EdgeInsets.fromLTRB(
            AppSizes.lg, AppSizes.sm, AppSizes.lg, AppSizes.xl),
        children: [
          JEmptyState(
            icon: Icons.cloud_off_rounded,
            title: "Couldn't load your journal.",
            message: 'Please try again.',
            action: JPrimaryButton(
              label: 'Try again',
              fullWidth: true,
              onPressed: () =>
                  ref.invalidate(journalHistoryControllerProvider),
            ),
          ),
        ],
      ),
      data: (state) {
        if (state.entries.isEmpty) return _EmptyDiary(onStart: _openNew);

        final entries = state.entries;
        return ListView.builder(
          controller: _scroll,
          padding: const EdgeInsets.fromLTRB(
            AppSizes.lg,
            AppSizes.md,
            AppSizes.lg,
            AppSizes.xl,
          ),
          itemCount: entries.length + (state.loadingMore ? 1 : 0),
          itemBuilder: (context, i) {
            if (i >= entries.length) {
              return const Padding(
                padding: EdgeInsets.all(AppSizes.md),
                child: Center(
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
            return _DiaryEntry(
              entry: entries[i],
              isLast: i == entries.length - 1 && !state.loadingMore,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      JournalEntryDetailScreen(entryId: entries[i].id),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// A single diary entry on the timeline rail: a date node + a reading body.
class _DiaryEntry extends StatelessWidget {
  const _DiaryEntry({
    required this.entry,
    required this.isLast,
    required this.onTap,
  });

  final JournalEntry entry;
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final mood = entry.mood;
    final body = Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : AppSizes.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  DateFormat('EEEE, MMM d').format(entry.createdAt),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: HomeStyle.ink,
                  ),
                ),
              ),
              Text(
                DateFormat('h:mm a').format(entry.createdAt),
                style: const TextStyle(fontSize: 11.5, color: HomeStyle.inkSoft),
              ),
            ],
          ),
          if (mood != null) ...[
            const SizedBox(height: 6),
            MoodPill(mood: mood),
          ],
          const SizedBox(height: AppSizes.sm),
          // The entry body reads like a diary page: a soft left-accent quote.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
              AppSizes.md,
              AppSizes.sm,
              AppSizes.sm,
              AppSizes.sm,
            ),
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(color: HomeStyle.lavender, width: 3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    entry.content.isNotEmpty
                        ? entry.content
                        : (entry.title.isEmpty ? 'Untitled entry' : entry.title),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF3B3B52),
                      height: 1.5,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: HomeStyle.inkSoft, size: 20),
              ],
            ),
          ),
        ],
      ),
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 30,
              child: Column(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    margin: const EdgeInsets.only(top: 3),
                    decoration: BoxDecoration(
                      color: HomeStyle.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: HomeStyle.softShadow,
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(width: 2, color: HomeStyle.border),
                    ),
                ],
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}

/// A warm, emotional empty state for an untouched journal.
class _EmptyDiary extends StatelessWidget {
  const _EmptyDiary({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
          AppSizes.lg, AppSizes.xl, AppSizes.lg, AppSizes.xl),
      children: [
        const SizedBox(height: AppSizes.xl),
        Center(
          child: Container(
            width: 108,
            height: 108,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [HomeStyle.lavenderLight, HomeStyle.lavender],
              ),
            ),
            child: const Icon(Icons.auto_stories_rounded,
                size: 48, color: HomeStyle.primary),
          ),
        ),
        const SizedBox(height: AppSizes.lg),
        const Text(
          'No journal entries yet.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: HomeStyle.ink,
          ),
        ),
        const SizedBox(height: AppSizes.sm),
        const Text(
          'Start writing to reflect on your day. Your thoughts are safe here — '
          'a private space that grows with you.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: HomeStyle.inkSoft, height: 1.45),
        ),
        const SizedBox(height: AppSizes.xl),
        JPrimaryButton(
          label: 'Write your first journal',
          icon: Icons.edit_rounded,
          fullWidth: true,
          onPressed: onStart,
        ),
      ],
    );
  }
}
