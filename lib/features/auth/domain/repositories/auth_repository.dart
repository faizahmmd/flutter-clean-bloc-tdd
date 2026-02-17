import 'package:dartz/dartz.dart';
import 'package:tdddemo/core/errors/failures.dart';
import 'package:tdddemo/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
    Future<Either<Failure, User>> login(String email, String password);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, User>> getCurrentUser();
  Future<Either<Failure, bool>> isLoggedIn();
}