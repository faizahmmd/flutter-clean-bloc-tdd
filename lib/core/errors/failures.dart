import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message]; // ← THIS is key!
  // Equatable compares ALL values in props list
  // So: Failures with same message = equal
  //     Failures with different message = not equal
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
  // Inherits Equatable behavior automatically
  // ServerFailure("X") == ServerFailure("X") → true
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
