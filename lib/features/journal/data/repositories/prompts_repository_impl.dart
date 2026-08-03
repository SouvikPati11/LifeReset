import '../../../../core/utils/result.dart';
import '../../../../shared/repositories/base_repository.dart';
import '../../domain/entities/journal_prompt.dart';
import '../../domain/repositories/prompts_repository.dart';
import '../datasources/prompts_remote_data_source.dart';

class PromptsRepositoryImpl extends BaseRepository implements PromptsRepository {
  PromptsRepositoryImpl(this._remote);

  final PromptsRemoteDataSource _remote;

  @override
  Future<Result<List<JournalPrompt>>> getPrompts() =>
      guard<List<JournalPrompt>>(() => _remote.getPrompts());
}
