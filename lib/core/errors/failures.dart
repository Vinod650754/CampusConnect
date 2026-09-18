import 'package:equatable/equatable.dart';

/// Failures are what the Repository layer returns to Controllers — they
/// never leak raw exceptions upward. This keeps error handling in the UI
/// layer uniform regardless of whether the root cause was a network,
/// server, cache, or validation problem.
abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure(this.message, {this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.statusCode});
}

class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'No internet connection. Please check your network.'])
      : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure([String message = 'Failed to read local data.']) : super(message);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([String message = 'Session expired. Please log in again.'])
      : super(message, statusCode: 401);
}

class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;
  const ValidationFailure(super.message, {this.fieldErrors, super.statusCode});

  @override
  List<Object?> get props => [message, statusCode, fieldErrors];
}

class UnknownFailure extends Failure {
  const UnknownFailure([String message = 'Something went wrong. Please try again.'])
      : super(message);
}
