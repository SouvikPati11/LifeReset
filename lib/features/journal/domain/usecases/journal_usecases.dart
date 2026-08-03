import '../../../../core/utils/result.dart';
import '../entities/journal_entry.dart';
import '../entities/journal_prompt.dart';
import '../entities/mood_type.dart';
import '../repositories/journal_repository.dart';
import '../repositories/prompts_repository.dart';

class WatchRecentEntries {
  const WatchRecentEntries(this._repo);
  final JournalRepository _repo;
  Stream<List<JournalEntry>> call(String uid, {int limit = 5}) =>
      _repo.watchRecentEntries(uid, limit: limit);
}

class CountEntries {
  const CountEntries(this._repo);
  final JournalRepository _repo;
  Future<Result<int>> call(String uid) => _repo.countEntries(uid);
}

class FetchJournalPage {
  const FetchJournalPage(this._repo);
  final JournalRepository _repo;
  Future<Result<JournalPage>> call(String uid, {DateTime? before, int limit = 15}) =>
      _repo.fetchPage(uid, before: before, limit: limit);
}

class GetJournalEntry {
  const GetJournalEntry(this._repo);
  final JournalRepository _repo;
  Future<Result<JournalEntry?>> call(String uid, String entryId) =>
      _repo.getEntry(uid, entryId);
}

class WatchJournalEntry {
  const WatchJournalEntry(this._repo);
  final JournalRepository _repo;
  Stream<JournalEntry?> call(String uid, String entryId) =>
      _repo.watchEntry(uid, entryId);
}

class CreateJournalEntry {
  const CreateJournalEntry(this._repo);
  final JournalRepository _repo;
  Future<Result<String>> call(
    String uid, {
    required String title,
    required String content,
    required MoodType? mood,
    required List<String> tags,
  }) =>
      _repo.createEntry(uid, title: title, content: content, mood: mood, tags: tags);
}

class UpdateJournalEntry {
  const UpdateJournalEntry(this._repo);
  final JournalRepository _repo;
  Future<Result<void>> call(
    String uid, {
    required String entryId,
    required String title,
    required String content,
    required MoodType? mood,
    required List<String> tags,
  }) =>
      _repo.updateEntry(uid,
          entryId: entryId, title: title, content: content, mood: mood, tags: tags);
}

class DeleteJournalEntry {
  const DeleteJournalEntry(this._repo);
  final JournalRepository _repo;
  Future<Result<void>> call(String uid, String entryId) =>
      _repo.deleteEntry(uid, entryId);
}

class GenerateInsight {
  const GenerateInsight(this._repo);
  final JournalRepository _repo;
  Future<Result<String>> call(String uid,
          {required String entryId, required String content}) =>
      _repo.generateInsight(uid, entryId: entryId, content: content);
}

class GetPrompts {
  const GetPrompts(this._repo);
  final PromptsRepository _repo;
  Future<Result<List<JournalPrompt>>> call() => _repo.getPrompts();
}
