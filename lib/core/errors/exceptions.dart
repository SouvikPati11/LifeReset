/// Low-level exceptions thrown by the data layer (services / data sources).
///
/// These are caught at the repository boundary and mapped into [Failure]s so
/// that the presentation layer never depends on infrastructure error types.
library;

/// Base class for all app-specific exceptions.
abstract class AppException implements Exception {
  const AppException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => '$runtimeType(code: $code, message: $message)';
}

/// Thrown when a remote server / cloud call fails.
class ServerException extends AppException {
  const ServerException(super.message, {super.code});
}

/// Thrown for network connectivity problems.
class NetworkException extends AppException {
  const NetworkException([super.message = 'No internet connection']);
}

/// Thrown for authentication / authorization failures.
class AuthException extends AppException {
  const AuthException(super.message, {super.code});
}

/// Thrown for local cache / storage failures.
class CacheException extends AppException {
  const CacheException(super.message, {super.code});
}

/// Thrown when a payment / subscription operation fails.
class PaymentException extends AppException {
  const PaymentException(super.message, {super.code});
}
