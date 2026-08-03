import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../domain/entities/journal_entry.dart';
import '../providers/journal_providers.dart';

/// Paginated journal history state.
class JournalHistoryState {
  const JournalHistoryState({
    required this.entries,
    required this.hasMore,
    this.loadingMore = false,
  });

  final List<JournalEntry> entries;
  final bool hasMore;
  final bool loadingMore;

  JournalHistoryState copyWith({
    List<JournalEntry>? entries,
    bool? hasMore,
    bool? loadingMore,
  }) {
    return JournalHistoryState(
      entries: entries ?? this.entries,
      hasMore: hasMore ?? this.hasMore,
      loadingMore: loadingMore ?? this.loadingMore,
    );
  }
}

/// Loads journal entries page-by-page (keyset pagination on `createdAtMs`).
class JournalHistoryController
    extends AutoDisposeAsyncNotifier<JournalHistoryState> {
  static const int _pageSize = 15;

  @override
  Future<JournalHistoryState> build() async {
    final uid = ref.watch(currentUserProvider)?.id;
    if (uid == null) {
      return const JournalHistoryState(entries: [], hasMore: false);
    }
    final result = await ref
        .read(fetchJournalPageUseCaseProvider)
        .call(uid, limit: _pageSize);
    return result.when(
      success: (page) =>
          JournalHistoryState(entries: page.entries, hasMore: page.hasMore),
      failure: (failure) => throw Exception(failure.message),
    );
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.loadingMore) return;
    final uid = ref.read(currentUserProvider)?.id;
    if (uid == null) return;

    state = AsyncData(current.copyWith(loadingMore: true));
    final before =
        current.entries.isEmpty ? null : current.entries.last.createdAt;
    final result = await ref
        .read(fetchJournalPageUseCaseProvider)
        .call(uid, before: before, limit: _pageSize);

    result.when(
      success: (page) {
        state = AsyncData(
          JournalHistoryState(
            entries: [...current.entries, ...page.entries],
            hasMore: page.hasMore,
          ),
        );
      },
      failure: (_) {
        state = AsyncData(current.copyWith(loadingMore: false));
      },
    );
  }
}

final journalHistoryControllerProvider = AutoDisposeAsyncNotifierProvider<
    JournalHistoryController, JournalHistoryState>(
  JournalHistoryController.new,
);
