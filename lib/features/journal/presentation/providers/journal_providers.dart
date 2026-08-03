import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../data/datasources/journal_remote_data_source.dart';
import '../../data/datasources/mood_remote_data_source.dart';
import '../../data/datasources/prompts_remote_data_source.dart';
import '../../data/repositories/journal_repository_impl.dart';
import '../../data/repositories/mood_repository_impl.dart';
import '../../data/repositories/prompts_repository_impl.dart';
import '../../domain/entities/journal_analytics.dart';
import '../../domain/entities/journal_entry.dart';
import '../../domain/entities/journal_prompt.dart';
import '../../domain/entities/mood_entry.dart';
import '../../domain/repositories/journal_repository.dart';
import '../../domain/repositories/mood_repository.dart';
import '../../domain/repositories/prompts_repository.dart';
import '../../domain/usecases/journal_usecases.dart';
import '../../domain/usecases/mood_usecases.dart';

/// Dependency graph for the Journal & Mood feature.

final _firestoreProvider = Provider((ref) => FirebaseFirestore.instance);
final _functionsProvider = Provider((ref) => FirebaseFunctions.instance);

// Repositories.
final journalRepositoryProvider = Provider<JournalRepository>((ref) {
  return JournalRepositoryImpl(
    FirebaseJournalRemoteDataSource(
      ref.watch(_firestoreProvider),
      ref.watch(_functionsProvider),
    ),
  );
});

final moodRepositoryProvider = Provider<MoodRepository>((ref) {
  return MoodRepositoryImpl(
    FirebaseMoodRemoteDataSource(ref.watch(_firestoreProvider)),
  );
});

final promptsRepositoryProvider = Provider<PromptsRepository>((ref) {
  return PromptsRepositoryImpl(
    FirebasePromptsRemoteDataSource(ref.watch(_firestoreProvider)),
  );
});

// Use cases.
final watchRecentEntriesUseCaseProvider =
    Provider((ref) => WatchRecentEntries(ref.watch(journalRepositoryProvider)));
final countEntriesUseCaseProvider =
    Provider((ref) => CountEntries(ref.watch(journalRepositoryProvider)));
final fetchJournalPageUseCaseProvider =
    Provider((ref) => FetchJournalPage(ref.watch(journalRepositoryProvider)));
final watchJournalEntryUseCaseProvider =
    Provider((ref) => WatchJournalEntry(ref.watch(journalRepositoryProvider)));
final createJournalEntryUseCaseProvider =
    Provider((ref) => CreateJournalEntry(ref.watch(journalRepositoryProvider)));
final updateJournalEntryUseCaseProvider =
    Provider((ref) => UpdateJournalEntry(ref.watch(journalRepositoryProvider)));
final deleteJournalEntryUseCaseProvider =
    Provider((ref) => DeleteJournalEntry(ref.watch(journalRepositoryProvider)));
final generateInsightUseCaseProvider =
    Provider((ref) => GenerateInsight(ref.watch(journalRepositoryProvider)));
final getPromptsUseCaseProvider =
    Provider((ref) => GetPrompts(ref.watch(promptsRepositoryProvider)));
final watchTodayMoodUseCaseProvider =
    Provider((ref) => WatchTodayMood(ref.watch(moodRepositoryProvider)));
final watchMoodHistoryUseCaseProvider =
    Provider((ref) => WatchMoodHistory(ref.watch(moodRepositoryProvider)));
final saveMoodUseCaseProvider =
    Provider((ref) => SaveMood(ref.watch(moodRepositoryProvider)));

// Section data.

/// Recent entries (windowed for the dashboard + weekly stats).
final recentEntriesProvider = StreamProvider<List<JournalEntry>>((ref) {
  final uid = ref.watch(currentUserProvider)?.id;
  if (uid == null) return Stream.value(const []);
  return ref.watch(watchRecentEntriesUseCaseProvider).call(uid, limit: 20);
});

/// Total journal entry count.
final entryCountProvider = FutureProvider<int>((ref) async {
  final uid = ref.watch(currentUserProvider)?.id;
  if (uid == null) return 0;
  final result = await ref.watch(countEntriesUseCaseProvider).call(uid);
  return result.when(success: (n) => n, failure: (_) => 0);
});

/// Live single entry (used by the detail screen).
final entryDetailProvider =
    StreamProvider.family<JournalEntry?, String>((ref, entryId) {
  final uid = ref.watch(currentUserProvider)?.id;
  if (uid == null) return Stream.value(null);
  return ref.watch(watchJournalEntryUseCaseProvider).call(uid, entryId);
});

/// Today's mood.
final todayMoodProvider = StreamProvider<MoodEntry?>((ref) {
  final uid = ref.watch(currentUserProvider)?.id;
  if (uid == null) return Stream.value(null);
  return ref.watch(watchTodayMoodUseCaseProvider).call(uid);
});

/// The last 30 days of mood entries.
final moodHistoryProvider = StreamProvider<List<MoodEntry>>((ref) {
  final uid = ref.watch(currentUserProvider)?.id;
  if (uid == null) return Stream.value(const []);
  return ref.watch(watchMoodHistoryUseCaseProvider).call(uid, days: 30);
});

/// Aggregated mood analytics derived from history.
final moodAnalyticsProvider = Provider<MoodAnalytics>((ref) {
  final history = ref.watch(moodHistoryProvider).valueOrNull ?? const [];
  return MoodAnalytics.fromHistory(history);
});

/// Headline journal/mood stats for the overview and healing progress.
final journalStatsProvider = Provider<JournalStats>((ref) {
  final entries = ref.watch(recentEntriesProvider).valueOrNull ?? const [];
  final total = ref.watch(entryCountProvider).valueOrNull ?? entries.length;
  final analytics = ref.watch(moodAnalyticsProvider);

  final weekAgo = DateTime.now().subtract(const Duration(days: 7));
  final entriesThisWeek =
      entries.where((e) => e.createdAt.isAfter(weekAgo)).length;
  final moodDaysThisWeek = analytics.trend
      .where((p) => p.date.isAfter(weekAgo))
      .map((p) => DateTime(p.date.year, p.date.month, p.date.day))
      .toSet()
      .length;

  return JournalStats(
    totalEntries: total,
    entriesThisWeek: entriesThisWeek,
    moodDaysThisWeek: moodDaysThisWeek.clamp(0, 7),
    moodStreak: analytics.streak,
  );
});

/// Read-only view of the user document, for cross-cutting values (recovery
/// score, current day) owned by other modules but displayed here.
final _userDocProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final uid = ref.watch(currentUserProvider)?.id;
  if (uid == null) return Stream.value(const {});
  return ref
      .watch(_firestoreProvider)
      .collection(AppConstants.usersCollection)
      .doc(uid)
      .snapshots()
      .map((doc) => doc.data() ?? const <String, dynamic>{});
});

final recoveryScoreProvider = Provider<int>((ref) {
  return (ref.watch(_userDocProvider).valueOrNull?['recoveryScore'] as num?)
          ?.toInt() ??
      0;
});

final currentDayProvider = Provider<int>((ref) {
  return (ref.watch(_userDocProvider).valueOrNull?['currentDay'] as num?)
          ?.toInt() ??
      1;
});

/// Writing prompts (loaded once, cached).
final promptsProvider = FutureProvider<List<JournalPrompt>>((ref) async {
  final result = await ref.watch(getPromptsUseCaseProvider).call();
  return result.when(success: (p) => p, failure: (_) => const []);
});
