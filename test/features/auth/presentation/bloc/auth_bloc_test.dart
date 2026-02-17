import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formz/formz.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tdddemo/core/errors/failures.dart';
import 'package:tdddemo/core/utils/input_validators.dart';
import 'package:tdddemo/features/auth/domain/entities/user.dart';
import 'package:tdddemo/features/auth/domain/usecases/login_usecase.dart';
import 'package:tdddemo/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:tdddemo/features/auth/presentation/bloc/auth/auth_event.dart';
import 'package:tdddemo/features/auth/presentation/bloc/auth/auth_state.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

void main() {
  late MockLoginUseCase mockLoginUseCase;
  
  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  const tUser = User(id: '1', email: tEmail, name: 'Test User');

  group('AuthBloc', () {
    blocTest<AuthBloc, AuthState>(
      'should emit [AuthState] when EmailChanged is added',
      build: () => AuthBloc(loginUseCase: MockLoginUseCase()),
      act: (bloc) => bloc.add(const AuthEvent.emailChanged(tEmail)),
      expect: () => [
        isA<AuthState>()
            .having((s) => s.email.value, 'email', tEmail)
            .having((s) => s.email.isPure, 'isPure', false)
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'should emit [AuthState] when PasswordChanged is added',
      build: () => AuthBloc(loginUseCase: MockLoginUseCase()),
      act: (bloc) => bloc.add(const AuthEvent.passwordChanged(tPassword)),
      expect: () => [
        isA<AuthState>()
            .having((s) => s.password.value, 'password', tPassword)
            .having((s) => s.password.isPure, 'isPure', false)
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'should emit [submissionInProgress, submissionSuccess] when login succeeds',
      setUp: () {
        mockLoginUseCase = MockLoginUseCase();
        when(() => mockLoginUseCase.call(tEmail, tPassword))
            .thenAnswer((_) async => const Right(tUser));
      },
      build: () => AuthBloc(loginUseCase: mockLoginUseCase),
      seed: () => const AuthState(
        email: Email.dirty(tEmail),
        password: Password.dirty(tPassword),
      ),
      act: (bloc) => bloc.add(const AuthEvent.loginSubmitted()),
      expect: () => [
        isA<AuthState>()
            .having((s) => s.status.isInProgress, 'loading', true),
        isA<AuthState>()
            .having((s) => s.status.isSuccess, 'success', true)
            .having((s) => s.user, 'user', tUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'should emit [submissionInProgress, submissionFailure] when login fails',
      setUp: () {
        mockLoginUseCase = MockLoginUseCase();
        when(() => mockLoginUseCase.call(tEmail, tPassword))
            .thenAnswer((_) async => const Left(ServerFailure('Error')));
      },
      build: () => AuthBloc(loginUseCase: mockLoginUseCase),
      seed: () => const AuthState(
        email: Email.dirty(tEmail),
        password: Password.dirty(tPassword),
      ),
      act: (bloc) => bloc.add(const AuthEvent.loginSubmitted()),
      expect: () => [
        isA<AuthState>()
            .having((s) => s.status.isInProgress, 'loading', true),
        isA<AuthState>()
            .having((s) => s.status.isFailure, 'failure', true)
            .having((s) => s.errorMessage, 'error', 'Error'),
      ],
    );
  });
}