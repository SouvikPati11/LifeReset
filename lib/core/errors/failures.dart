import 'package:equatable/equatable.dart';

/// Domain-level error type surfaced to the presentation layer.
///
/// Repositories convert infrastructure [Exception]s into [Failure]s so the UI
/// can react to a small, stable set of error cases without knowing about
/// Firebase, HTTP, or any other implementation detail.
sealed class Failure extends Equatable {
  const Failure(this.message, {this.code});

  final String message;
  final String? code;

  @override
  List<Object?> get props => [message, code];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code});
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.code});
}

class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.code});
}

class PaymentFailure extends Failure {
  const PaymentFailure(super.message, {super.code});
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'An unexpected error occurred']);
}
