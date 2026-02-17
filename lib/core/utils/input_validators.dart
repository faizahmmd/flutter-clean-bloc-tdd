import 'package:formz/formz.dart';

// Email validation error types
enum EmailValidationError { invalid, empty }

// Email form field using Formz for validation
class Email extends FormzInput<String, EmailValidationError> {
  // Pure constructor (initial/unmodified state) with optional default value
  const Email.pure([super.value = '']) : super.pure();
  // Dirty constructor (modified/validated state) with optional default value
  const Email.dirty([super.value = '']) : super.dirty();

  // RFC-compliant email regex pattern
  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9.!#$%&"*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$',
  );

  @override
  EmailValidationError? validator(String? value) {
    // Check for empty/null value
    if (value == null || value.isEmpty) {
      return EmailValidationError.empty;
    }
    // Validate against email regex pattern
    return _emailRegex.hasMatch(value) ? null : EmailValidationError.invalid;
  }
}

// Password validation error types
enum PasswordValidationError { invalid, empty }

// Password form field using Formz for validation
class Password extends FormzInput<String, PasswordValidationError> {
  // Pure constructor (initial/unmodified state) with optional default value
  const Password.pure([super.value = '']) : super.pure();
  // Dirty constructor (modified/validated state) with optional default value
  const Password.dirty([super.value = '']) : super.dirty();

  @override
  PasswordValidationError? validator(String? value) {
    // Check for empty/null value
    if (value == null || value.isEmpty) {
      return PasswordValidationError.empty;
    }
    // Validate minimum length (6 characters)
    return value.length >= 6 ? null : PasswordValidationError.invalid;
  }
}