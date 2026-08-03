import '../../../../core/utils/result.dart';
import '../../../../shared/repositories/base_repository.dart';
import '../../domain/entities/journal_entry.dart';
import '../../domain/entities/mood_type.dart';
import '../../domain/repositories/journal_repository.dart';
import '../datasources/journal_remote_data_source.dart';
import '../models/journal_entry_model.dart';

class JournalRepositoryImpl extends BaseRepository implements JournalRepository {
  JournalRepositoryImpl(this._remote);

  final JournalRemoteDataSource _remote;

  @override
  Stream<List<JournalEntry>> watchRecentEntries(String uid, {int limit = 5}) =>
      _remote.watchRecentEntries(uid, limit: limit);

  @override
  Future<Result<int>> countEntries(String uid) =>
      guard<int>(() => _remote.countEntries(uid));

  @override
  Future<Result<JournalPage>> fetchPage(String uid,
          {DateTime? before, int limit = 15}) =>
      guard<JournalPage>(() => _remote.fetchPage(uid, before: before, limit: limit));

  @override
  Future<Result<JournalEntry?>> getEntry(String uid, String entryId) =>
      guard<JournalEntry?>(() => _remote.getEntry(uid, entryId));

  @override
  Stream<JournalEntry?> watchEntry(String uid, String entryId) =>
      _remote.watchEntry(uid, entryId);

  @override
  Future<Result<String>> createEntry(
    String uid, {
    required String title,
    required String content,
    required MoodType? mood,
    required List<String> tags,
    String? photoUrl,
  }) {
    return guard<String>(() => _remote.createEntry(
          uid,
          JournalEntryModel.toCreateMap(
            title: title,
            content: content,
            mood: mood,
            tags: tags,
            photoUrl: photoUrl,
          ),
        ));
  }

  @override
  Future<Result<void>> updateEntry(
    String uid, {
    required String entryId,
    required String title,
    required String content,
    required MoodType? mood,
    required List<String> tags,
  }) {
    return guard<void>(() => _remote.updateEntry(
          uid,
          entryId,
          JournalEntryModel.toUpdateMap(
            title: title,
            content: content,
            mood: mood,
            tags: tags,
          ),
        ));
  }

  @override
  Future<Result<void>> deleteEntry(String uid, String entryId) =>
      guard<void>(() => _remote.deleteEntry(uid, entryId));

  @override
  Future<Result<String>> generateInsight(String uid,
          {required String entryId, required String content}) =>
      guard<String>(
          () => _remote.generateInsight(uid, entryId: entryId, content: content));
}
