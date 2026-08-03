import '../errors/failures.dart';

/// A lightweight functional result type used across the domain layer.
///
/// Repositories return `Result<T>` instead of throwing, forcing callers to
/// handle both the success ([Success]) and failure ([FailureResult]) paths.
sealed class Result<T> {
  const Result();

  /// Returns `true` when this result holds a value.
  bool get isSuccess => this is Success<T>;

  /// Returns `true` when this result holds a [Failure].
  bool get isFailure => this is FailureResult<T>;

  /// Folds both branches into a single value of type [R].
  R when<R>({
    required R Function(T value) success,
    required R Function(Failure failure) failure,
  }) {
    final self = this;
    if (self is Success<T>) return success(self.value);
    return failure((self as FailureResult<T>).failure);
  }
}

class Success<T> extends Result<T> {
  const Success(this.value);
  final T value;
}

class FailureResult<T> extends Result<T> {
  const FailureResult(this.failure);
  final Failure failure;
}
