import 'package:dartz/dartz.dart';
import 'package:tdddemo/core/errors/failures.dart';
import 'package:tdddemo/features/auth/domain/entities/user.dart';
import 'package:tdddemo/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<Failure, User>> call(String email, String password) async {
    return await repository.login(email, password);
  }
}