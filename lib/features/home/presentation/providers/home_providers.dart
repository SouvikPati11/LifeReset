import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../data/datasources/home_remote_data_source.dart';
import '../widgets/home_style.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../domain/entities/daily_quote.dart';
import '../../domain/entities/daily_task.dart';
import '../../domain/entities/recovery_program.dart';
import '../../domain/entities/user_stats.dart';
import '../../domain/repositories/home_repository.dart';
import '../../domain/usecases/get_daily_quote.dart';
import '../../domain/usecases/get_recovery_program.dart';
import '../../domain/usecases/set_task_completed.dart';
import '../../domain/usecases/watch_daily_tasks.dart';
import '../../domain/usecases/watch_user_stats.dart';

/// Dependency graph for the Home Dashboard.
///
/// The section providers below are kept alive (not auto-disposed) so their data
/// is cached across tab switches; each Firestore read is issued lazily the
/// first time a section is watched.

final _homeRemoteDataSourceProvider = Provider<HomeRemoteDataSource>((ref) {
  return FirestoreHomeRemoteDataSource(FirebaseFirestore.instance);
});

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepositoryImpl(ref.watch(_homeRemoteDataSourceProvider));
});

// Use cases.

final watchUserStatsUseCaseProvider = Provider<WatchUserStats>((ref) {
  return WatchUserStats(ref.watch(homeRepositoryProvider));
});

final watchDailyTasksUseCaseProvider = Provider<WatchDailyTasks>((ref) {
  return WatchDailyTasks(ref.watch(homeRepositoryProvider));
});

final getDailyQuoteUseCaseProvider = Provider<GetDailyQuote>((ref) {
  return GetDailyQuote(ref.watch(homeRepositoryProvider));
});

final getRecoveryProgramUseCaseProvider = Provider<GetRecoveryProgram>((ref) {
  return GetRecoveryProgram(ref.watch(homeRepositoryProvider));
});

final setTaskCompletedUseCaseProvider = Provider<SetTaskCompleted>((ref) {
  return SetTaskCompleted(ref.watch(homeRepositoryProvider));
});

// Section data (consumed by the UI).

/// The signed-in user's recovery stats (score, streak, day, completed tasks,
/// score history). Emits defaults when signed out or when no document exists.
final userStatsProvider = StreamProvider<UserStats>((ref) {
  final uid = ref.watch(currentUserProvider)?.id;
  if (uid == null) return Stream.value(UserStats.initial());
  return ref.watch(watchUserStatsUseCaseProvider).call(uid);
});

/// Today's recovery tasks.
final dailyTasksProvider = StreamProvider<List<DailyTask>>((ref) {
  return ref.watch(watchDailyTasksUseCaseProvider).call();
});

/// Today's motivational quote (falls back to a default when unavailable).
final dailyQuoteProvider = FutureProvider<DailyQuote>((ref) async {
  final result = await ref.watch(getDailyQuoteUseCaseProvider).call();
  return result.when(success: (quote) => quote, failure: (_) => DailyQuote.fallback);
});

/// The active recovery program (falls back to the default 30-day program).
final recoveryProgramProvider = FutureProvider<RecoveryProgram>((ref) async {
  final result = await ref.watch(getRecoveryProgramUseCaseProvider).call();
  return result.when(
    success: (program) => program,
    failure: (_) => RecoveryProgram.defaultProgram(),
  );
});

/// The user's personalized Focus, derived from `users/{uid}.problem` (saved at
/// onboarding). Uses the real stored value; falls back to a generic focus when
/// signed out or the field is absent — never a raw enum string.
final homeFocusProvider = StreamProvider<HomeFocus>((ref) {
  final uid = ref.watch(currentUserProvider)?.id;
  if (uid == null) return Stream.value(HomeFocus.fromProblem(null));
  return FirebaseFirestore.instance
      .collection(AppConstants.usersCollection)
      .doc(uid)
      .snapshots()
      .map((doc) => HomeFocus.fromProblem(doc.data()?['problem'] as String?));
});
