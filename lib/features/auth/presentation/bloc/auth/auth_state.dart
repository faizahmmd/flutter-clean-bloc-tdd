import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:formz/formz.dart';
import 'package:tdddemo/core/utils/input_validators.dart';
import 'package:tdddemo/features/auth/domain/entities/user.dart';

part 'auth_state.freezed.dart';

@freezed
abstract class AuthState with _$AuthState {
  const factory AuthState({
    @Default(Email.pure()) Email email,
    @Default(Password.pure()) Password password,
    @Default(FormzSubmissionStatus.initial) FormzSubmissionStatus status,
    String? errorMessage,
    User? user,
  }) = _AuthState;

  // Add custom getters for convenience
  factory AuthState.initial() => const AuthState();
}