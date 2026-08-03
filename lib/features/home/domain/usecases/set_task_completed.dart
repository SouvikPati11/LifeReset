import '../../../../core/utils/result.dart';
import '../repositories/home_repository.dart';

/// Marks a task complete/incomplete and saves it immediately.
class SetTaskCompleted {
  const SetTaskCompleted(this._repository);

  final HomeRepository _repository;

  Future<Result<void>> call({
    required String uid,
    required String taskId,
    required bool completed,
  }) {
    return _repository.setTaskCompleted(
      uid: uid,
      taskId: taskId,
      completed: completed,
    );
  }
}
