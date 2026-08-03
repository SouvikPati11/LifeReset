import '../../../../core/utils/result.dart';
import '../entities/recovery_program.dart';
import '../repositories/home_repository.dart';

/// Reads the active recovery program.
class GetRecoveryProgram {
  const GetRecoveryProgram(this._repository);

  final HomeRepository _repository;

  Future<Result<RecoveryProgram>> call() => _repository.getProgram();
}
