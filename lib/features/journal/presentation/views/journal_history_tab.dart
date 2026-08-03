import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../domain/entities/journal_entry.dart';
import '../controllers/journal_history_controller.dart';
import '../screens/journal_entry_detail_screen.dart';
import '../screens/new_journal_screen.dart';
import '../widgets/journal_widgets.dart';

/// Journal tab: searchable, filterable, paginated entry history.
class JournalHistoryTab extends ConsumerStatefulWidget {
  const JournalHistoryTab({super.key});

  @override
  ConsumerState<JournalHistoryTab> createState() => _JournalHistoryTabState();
}

class _JournalHistoryTabState extends ConsumerState<JournalHistoryTab> {
  static const List<String> _filters = ['All', 'breakup', 'progress', 'anxiety'];

  final _scroll = ScrollController();
  final _search = TextEditingController();
  String _query = '';
  String _filter = 'All';

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    _search.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.pixels >=
        _scroll.position.maxScrollExtent - 300) {
      ref.read(journalHistoryControllerProvider.notifier).loadMore();
    }
  }

  List<JournalEntry> _apply(List<JournalEntry> entries) {
    return entries.where((e) {
      final matchesFilter =
          _filter == 'All' || e.tags.map((t) => t.toLowerCase()).contains(_filter);
      final q = _query.toLowerCase();
      final matchesQuery = q.isEmpty ||
          e.title.toLowerCase().contains(q) ||
          e.content.toLowerCase().contains(q);
      return matchesFilter && matchesQuery;
    }).toList();
  }

  void _openNew() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NewJournalScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(journalHistoryControllerProvider);

    return async.when(
      loading: () => const LoadingView(),
      error: (_, __) => ErrorView(
        title: 'Could not load your journal',
        onRetry: () => ref.invalidate(journalHistoryControllerProvider),
      ),
      data: (state) {
        if (state.entries.isEmpty) return _EmptyState(onStart: _openNew);
        final filtered = _apply(state.entries);
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.md,
                AppSizes.md,
                AppSizes.md,
                AppSizes.sm,
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _search,
                    onChanged: (v) => setState(() => _query = v),
                    decoration: const InputDecoration(
                      hintText: 'Search entries…',
                      prefixIcon: Icon(Icons.search_rounded),
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  Row(
                    children: [
                      for (final f in _filters) ...[
                        TagChip(
                          label: f == 'All' ? 'All' : '#$f',
                          selected: _filter == f,
                          onTap: () => setState(() => _filter = f),
                        ),
                        const SizedBox(width: AppSizes.sm),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                controller: _scroll,
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                itemCount: filtered.length + (state.loadingMore ? 1 : 0),
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  if (index >= filtered.length) {
                    return const Padding(
                      padding: EdgeInsets.all(AppSizes.md),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final entry = filtered[index];
                  return JournalEntryTile(
                    entry: entry,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            JournalEntryDetailScreen(entryId: entry.id),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.menu_book_rounded, size: 56, color: colorScheme.primary),
            const SizedBox(height: AppSizes.lg),
            Text('Start your healing story', style: textTheme.titleLarge),
            const SizedBox(height: AppSizes.xs),
            Text(
              'Your thoughts matter. Write your first journal entry and take the '
              'first step.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: AppSizes.lg),
            FilledButton(
              onPressed: onStart,
              child: const Text('Write Your First Entry'),
            ),
          ],
        ),
      ),
    );
  }
}
