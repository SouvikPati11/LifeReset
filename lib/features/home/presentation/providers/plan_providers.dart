import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/daily_task.dart';
import 'home_providers.dart';

/// Streams the admin-authored tasks for a specific program [day], so the Plan
/// screen's day selector can load any day on demand. Reuses the existing
/// `WatchDailyTasks` use case and `program_tasks` data source — no new data.
final planTasksProvider =
    StreamProvider.autoDispose.family<List<DailyTask>, int>((ref, day) {
  return ref.watch(watchDailyTasksUseCaseProvider).call(
        programId: AppConstants.supportedProgram,
        day: day,
      );
});
