import '../../../../core/utils/result.dart';
import '../entities/journal_entry.dart';
import '../entities/mood_type.dart';

/// A page of journal entries plus whether more remain (keyset pagination).
class JournalPage {
  const JournalPage({required this.entries, required this.hasMore});
  final List<JournalEntry> entries;
  final bool hasMore;
}

/// Contract for journal entries (`users/{uid}/journal_entries`).
abstract interface class JournalRepository {
  /// Streams the most recent entries (cached, for the dashboard).
  Stream<List<JournalEntry>> watchRecentEntries(String uid, {int limit});

  /// Total entry count (aggregate).
  Future<Result<int>> countEntries(String uid);

  /// Loads a page of entries older than [before] (newest first).
  Future<Result<JournalPage>> fetchPage(
    String uid, {
    DateTime? before,
    int limit,
  });

  Future<Result<JournalEntry?>> getEntry(String uid, String entryId);

  /// Streams a single entry (so a generated AI insight appears live).
  Stream<JournalEntry?> watchEntry(String uid, String entryId);

  /// Creates an entry and returns its id.
  Future<Result<String>> createEntry(
    String uid, {
    required String title,
    required String content,
    required MoodType? mood,
    required List<String> tags,
    String? photoUrl,
  });

  Future<Result<void>> updateEntry(
    String uid, {
    required String entryId,
    required String title,
    required String content,
    required MoodType? mood,
    required List<String> tags,
  });

  Future<Result<void>> deleteEntry(String uid, String entryId);

  /// Generates a short AI insight (via the AI Coach backend) and stores it on
  /// the entry.
  Future<Result<String>> generateInsight(
    String uid, {
    required String entryId,
    required String content,
  });
}
