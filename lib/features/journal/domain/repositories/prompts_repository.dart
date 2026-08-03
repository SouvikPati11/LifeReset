import '../../../../core/utils/result.dart';
import '../entities/journal_prompt.dart';

/// Contract for journal writing prompts (`journal_prompts`).
abstract interface class PromptsRepository {
  Future<Result<List<JournalPrompt>>> getPrompts();
}
