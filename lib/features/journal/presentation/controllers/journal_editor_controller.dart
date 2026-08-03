import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/result.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../domain/entities/mood_type.dart';
import '../providers/journal_providers.dart';

/// Drives creating, editing and deleting a journal entry.
///
/// On create, the AI insight is generated in the background (reusing the AI
/// Coach backend); the detail screen streams the entry and shows it when ready.
class JournalEditorController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<String?> create({
    required String title,
    required String content,
    required MoodType? mood,
    required List<String> tags,
  }) async {
    final uid = ref.read(currentUserProvider)?.id;
    if (uid == null) return null;

    state = const AsyncLoading();
    final result = await ref.read(createJournalEntryUseCaseProvider).call(
          uid,
          title: title,
          content: content,
          mood: mood,
          tags: tags,
        );
    return result.when(
      success: (entryId) {
        state = const AsyncData(null);
        // Best-effort AI insight; failures (e.g. quota) are ignored.
        unawaited(
          ref.read(generateInsightUseCaseProvider).call(
                uid,
                entryId: entryId,
                content: content,
              ),
        );
        return entryId;
      },
      failure: (failure) {
        state = AsyncError(failure, StackTrace.current);
        return null;
      },
    );
  }

  Future<bool> updateEntry({
    required String entryId,
    required String title,
    required String content,
    required MoodType? mood,
    required List<String> tags,
  }) async {
    final uid = ref.read(currentUserProvider)?.id;
    if (uid == null) return false;

    state = const AsyncLoading();
    final result = await ref.read(updateJournalEntryUseCaseProvider).call(
          uid,
          entryId: entryId,
          title: title,
          content: content,
          mood: mood,
          tags: tags,
        );
    return _reflect(result);
  }

  Future<bool> delete(String entryId) async {
    final uid = ref.read(currentUserProvider)?.id;
    if (uid == null) return false;
    state = const AsyncLoading();
    final result =
        await ref.read(deleteJournalEntryUseCaseProvider).call(uid, entryId);
    return _reflect(result);
  }

  bool _reflect(Result<void> result) {
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

final journalEditorControllerProvider =
    AutoDisposeAsyncNotifierProvider<JournalEditorController, void>(
  JournalEditorController.new,
);
