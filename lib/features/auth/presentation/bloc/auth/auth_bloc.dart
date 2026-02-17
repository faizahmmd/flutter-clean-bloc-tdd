import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:tdddemo/core/utils/input_validators.dart';
import 'package:tdddemo/features/auth/domain/usecases/login_usecase.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;

  AuthBloc({required this.loginUseCase}) : super(const AuthState()) {
    on<EmailChanged>(_onEmailChanged);
    on<PasswordChanged>(_onPasswordChanged);
    on<LoginSubmitted>(_onLoginSubmitted);
  }

  void _onEmailChanged(EmailChanged event, Emitter<AuthState> emit) {
    // 1. Takes the string "test@email.com"
    // 2. Creates Email.dirty("test@email.com")
    // 3. Email.dirty() constructor calls Email validator internally
    // 4. Validator checks: empty? regex match? → sets isValid flag

    //super.dirty() marks isPure = false
    final email = Email.dirty(event.email);
    emit(
      state.copyWith(
        email: email
      ),
    );
  }

  void _onPasswordChanged(PasswordChanged event, Emitter<AuthState> emit) {
    // 1. Takes the string "dsfsdfds"
    // 2. Creates Password.dirty("test@email.com")
    // 3. Password.dirty() constructor calls Password validator internally
    // 4. Validator checks: empty? regex match? → sets isValid flag

    //super.dirty() marks isPure = false
    final password = Password.dirty(event.password);
    emit(
      state.copyWith(
        password: password,
      ),
    );
  }

  void _onLoginSubmitted(LoginSubmitted event, Emitter<AuthState> emit) async {
    // Check if form is valid before submission
    if (state.email.isValid && state.password.isValid) {
      emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

      final result = await loginUseCase(
        state.email.value,
        state.password.value,
      );

      result.fold(
        (failure) => emit(
          state.copyWith(
            status: FormzSubmissionStatus.failure,
            errorMessage: failure.message,
          ),
        ),
        (user) => emit(
          state.copyWith(
            status: FormzSubmissionStatus.success,
            user: user,
            errorMessage: null, // Clear any previous errors
          ),
        ),
      );
    } else {
      // Mark both fields as dirty to show validation errors
      emit(
        state.copyWith(
          email: Email.dirty(state.email.value),
          password: Password.dirty(state.password.value),
          status: FormzSubmissionStatus.failure,
          errorMessage: 'Please fix validation errors',
        ),
      );
    }
  }

  // Helper method to validate form
  FormzSubmissionStatus _validateForm(Email email, Password password) {
    return email.isValid && password.isValid
        ? FormzSubmissionStatus
              .success // Or .initial for just validated
        : FormzSubmissionStatus.failure;
  }
}
