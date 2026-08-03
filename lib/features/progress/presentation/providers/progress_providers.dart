import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../data/datasources/progress_remote_data_source.dart';
import '../../data/repositories/progress_repository_impl.dart';
import '../../domain/entities/progress_models.dart';
import '../../domain/repositories/progress_repository.dart';

/// Dependency graph for the Progress feature.

final _dataSourceProvider = Provider<ProgressRemoteDataSource>((ref) {
  return ProgressRemoteDataSource(FirebaseFirestore.instance);
});

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  return ProgressRepositoryImpl(ref.watch(_dataSourceProvider));
});

/// Scalar recovery stats for the signed-in user.
final progressStatsProvider = StreamProvider<ProgressStats>((ref) {
  final uid = ref.watch(currentUserProvider)?.id;
  if (uid == null) return Stream.value(ProgressStats.empty());
  return ref.watch(progressRepositoryProvider).watchStats(uid);
});

/// Recent mood samples (oldest → newest).
final moodHistoryProvider = StreamProvider<List<MoodSample>>((ref) {
  final uid = ref.watch(currentUserProvider)?.id;
  if (uid == null) return Stream.value(const []);
  return ref.watch(progressRepositoryProvider).watchMoodHistory(uid);
});

/// Total journal entries written (graceful 0 on failure).
final journalCountProvider = FutureProvider<int>((ref) async {
  final uid = ref.watch(currentUserProvider)?.id;
  if (uid == null) return 0;
  final result = await ref.watch(progressRepositoryProvider).journalCount(uid);
  return result.when(success: (n) => n, failure: (_) => 0);
});

/// Average mood over the recent window (0–10; 0 when there is no data).
final averageMoodProvider = Provider<double>((ref) {
  final moods = ref.watch(moodHistoryProvider).valueOrNull ?? const [];
  if (moods.isEmpty) return 0;
  final total = moods.fold<int>(0, (acc, m) => acc + m.score);
  return total / moods.length;
});
