import 'dart:async';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/app_logger.dart';
import '../../core/utils/result.dart';

/// Base class for repositories that centralizes exception → [Failure] mapping.
///
/// Concrete repositories wrap their data-source calls in [guard], keeping the
/// try/catch boilerplate in one place and guaranteeing the presentation layer
/// only ever sees a [Result].
abstract class BaseRepository {
  const BaseRepository();

  Future<Result<T>> guard<T>(Future<T> Function() action) async {
    try {
      final value = await action();
      return Success(value);
    } on AuthException catch (e) {
      return FailureResult(AuthFailure(e.message, code: e.code));
    } on NetworkException catch (e) {
      return FailureResult(NetworkFailure(e.message));
    } on PaymentException catch (e) {
      return FailureResult(PaymentFailure(e.message, code: e.code));
    } on CacheException catch (e) {
      return FailureResult(CacheFailure(e.message, code: e.code));
    } on ServerException catch (e) {
      return FailureResult(ServerFailure(e.message, code: e.code));
    } catch (e, stackTrace) {
      AppLogger.error('Unhandled repository error', e, stackTrace);
      return FailureResult(UnknownFailure(e.toString()));
    }
  }
}
