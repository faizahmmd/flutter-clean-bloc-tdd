import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tdddemo/core/errors/failures.dart';
import 'package:tdddemo/features/auth/domain/entities/user.dart';
import 'package:tdddemo/features/auth/domain/repositories/auth_repository.dart';
import 'package:tdddemo/features/auth/domain/usecases/login_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LoginUseCase useCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    useCase = LoginUseCase(mockAuthRepository);
  });

  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  const tUser = User(id: '1', email: tEmail, name: 'Test User');

  test('should return User when repository call is successful', () async {
    // arrange

    // when(): Tells mocktail "when this method is called..."

    // thenAnswer(): "...return this value"

    // async =>: Repository returns Future, so we use async

    // Right(tUser): Simulate successful repository call

    // We're mocking the repository to return a specific response
    when(
      () => mockAuthRepository.login(tEmail, tPassword),
    ).thenAnswer((_) async => const Right(tUser));

    // act

    // Actually call the use case with test data

    // useCase() works because it's a callable class

    // Equivalent to: useCase.call(tEmail, tPassword)

    final result = await useCase(tEmail, tPassword);

    // assert

    // Check result: Use case returns what repository returned

    // Verify call happened: Confirm repository method was called with correct params

    // No extra calls: Ensure no unexpected repository calls

    expect(result, const Right(tUser));
    verify(() => mockAuthRepository.login(tEmail, tPassword));
    verifyNoMoreInteractions(mockAuthRepository);
  });

  test('should return ServerFailure when repository call fails', () async {
    // arrange
    when(
      () => mockAuthRepository.login(tEmail, tPassword),
    ).thenAnswer((_) async => const Left(ServerFailure('Server error')));

    // act
    final result = await useCase(tEmail, tPassword);

    // assert
    expect(result, const Left(ServerFailure('Server error')));
    verify(() => mockAuthRepository.login(tEmail, tPassword));
  });
}
