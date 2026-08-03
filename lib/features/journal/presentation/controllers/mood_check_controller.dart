import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../domain/entities/mood_type.dart';
import '../providers/journal_providers.dart';

/// Saves (or updates) today's mood.
class MoodCheckController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<bool> save({
    required MoodType mood,
    required String note,
    required List<String> factors,
    DateTime? date,
  }) async {
    final uid = ref.read(currentUserProvider)?.id;
    if (uid == null) return false;

    state = const AsyncLoading();
    final result = await ref.read(saveMoodUseCaseProvider).call(
          uid,
          date: date ?? DateTime.now(),
          mood: mood,
          note: note,
          factors: factors,
        );
    return result.when(
      success: (_) {
        state = const AsyncData(null);
        return true;
      },
      failure: (failure) {
        state = AsyncError(failure, StackTrace.current);
        return false;
      },
    );
  }
}

final moodCheckControllerProvider =
    AutoDisposeAsyncNotifierProvider<MoodCheckController, void>(
  MoodCheckController.new,
);
