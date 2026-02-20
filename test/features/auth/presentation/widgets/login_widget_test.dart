import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formz/formz.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tdddemo/core/utils/input_validators.dart';
import 'package:tdddemo/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:tdddemo/features/auth/presentation/bloc/auth/auth_event.dart';
import 'package:tdddemo/features/auth/presentation/bloc/auth/auth_state.dart';
import 'package:tdddemo/features/auth/presentation/widgets/login_widget.dart';
import 'dart:async';

// Mock classes
class MockAuthBloc extends Mock implements AuthBloc {}

// Fake classes for Freezed types
class AuthEventFake extends Fake implements AuthEvent {}

class AuthStateFake extends Fake implements AuthState {}

void main() {
  late MockAuthBloc mockAuthBloc;

  // Test constants
  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  const tError = 'Invalid credentials';

  // Setup before ALL tests
  setUpAll(() {
    // Register fallback values for Freezed classes
    registerFallbackValue(AuthEventFake());
    registerFallbackValue(AuthStateFake());

    // Register specific event instances
    registerFallbackValue(const AuthEvent.emailChanged(''));
    registerFallbackValue(const AuthEvent.passwordChanged(''));
    registerFallbackValue(const AuthEvent.loginSubmitted());
  });

  // Setup before EACH test
  setUp(() {
    mockAuthBloc = MockAuthBloc();

    // Default initial state
    final initialState = AuthState(
      email: const Email.dirty(''),
      password: const Password.dirty(''),
      status: FormzSubmissionStatus.initial,
    );

    // Mock state getter
    when(() => mockAuthBloc.state).thenReturn(initialState);

    // Mock stream - use a simple stream that completes immediately
    when(
      () => mockAuthBloc.stream,
    ).thenAnswer((_) => Stream.value(initialState));

    // Mock add method
    when(() => mockAuthBloc.add(any())).thenReturn(null);
  });

  // Cleanup after EACH test
  tearDown(() {
    reset(mockAuthBloc);
  });

  // Helper widget - Test LoginForm directly
  Widget createTestableWidget() {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider<AuthBloc>.value(
          value: mockAuthBloc,
          child: const LoginForm(),
        ),
      ),
    );
  }

  // Test 1: Basic rendering
  testWidgets('should render LoginForm with all required widgets', (
    WidgetTester tester,
  ) async {
    // Arrange & Act
    await tester.pumpWidget(createTestableWidget());
    await tester.pump(); // Use pump() instead of pumpAndSettle()

    // Assert
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Sign in to continue'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('Sign Up'), findsOneWidget);
  });

  // Test 2: Initial state shows LOGIN button
  testWidgets('should show LOGIN button in initial state', (
    WidgetTester tester,
  ) async {
    // Arrange & Act
    await tester.pumpWidget(createTestableWidget());
    await tester.pump();

    // Assert
    expect(find.text('LOGIN'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  // Test 3: Loading state - FIXED
  testWidgets('should show loading indicator when status is inProgress', (
    WidgetTester tester,
  ) async {
    // Arrange - Directly set loading state
    final loadingState = AuthState(
      email: Email.dirty(tEmail),
      password: Password.dirty(tPassword),
      status: FormzSubmissionStatus.inProgress,
    );

    // Update mocks for loading state
    when(() => mockAuthBloc.state).thenReturn(loadingState);
    when(
      () => mockAuthBloc.stream,
    ).thenAnswer((_) => Stream.value(loadingState));

    await tester.pumpWidget(createTestableWidget());
    await tester.pump(); // Don't use pumpAndSettle()

    // Debug: Uncomment to see what's rendered
    // debugDumpApp();

    // Assert - Should show CircularProgressIndicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Button text should be replaced
    expect(find.text('LOGIN'), findsNothing);

    // Button should be disabled
    final buttonFinder = find.byType(ElevatedButton);
    final button = tester.widget<ElevatedButton>(buttonFinder);
    expect(button.onPressed, isNull);
  });

  // Test 4: Form validation - valid form enables button
  testWidgets('should enable button when form is valid', (
    WidgetTester tester,
  ) async {
    // Arrange
    final validState = AuthState(
      email: Email.dirty(tEmail),
      password: Password.dirty(tPassword),
      status: FormzSubmissionStatus.initial,
    );

    when(() => mockAuthBloc.state).thenReturn(validState);
    when(() => mockAuthBloc.stream).thenAnswer((_) => Stream.value(validState));

    await tester.pumpWidget(createTestableWidget());
    await tester.pump();

    // Assert
    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNotNull);
  });

  // Test 5: Form validation - invalid form disables button
  testWidgets('should disable button when form is invalid - FIXED', (
    WidgetTester tester,
  ) async {
    // Test with emails that are DEFINITELY invalid according to Formz Email
    final List<Map<String, dynamic>> testCases = [
      {
        'email': 'invalid', // No @ - definitely invalid
        'shouldBeValid': false,
        'reason': 'No @ symbol',
      },
      {
        'email': 'invalid@', // No domain - invalid
        'shouldBeValid': false,
        'reason': 'No domain after @',
      },
      {
        'email': 'test@example.com', // Valid email
        'shouldBeValid': true,
        'reason': 'Valid email',
      },
    ];

    for (final testCase in testCases) {
      final email = testCase['email'] as String;
      final shouldBeValid = testCase['shouldBeValid'] as bool;
      final reason = testCase['reason'] as String;

      print('\nTesting: $reason');
      print('Email: "$email"');

      // Create the state with Formz Email
      final testState = AuthState(
        email: Email.dirty(email),
        password: Password.dirty(tPassword),
        status: FormzSubmissionStatus.initial,
      );

      print('Email isValid (Formz): ${testState.email.isValid}');
      print('Expected: $shouldBeValid');

      when(() => mockAuthBloc.state).thenReturn(testState);
      when(
        () => mockAuthBloc.stream,
      ).thenAnswer((_) => Stream.value(testState));

      await tester.pumpWidget(createTestableWidget());
      await tester.pump();

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));

      // Check button state based on Formz validation
      if (shouldBeValid) {
        print('Button should be ENABLED');
        expect(
          button.onPressed,
          isNotNull,
          reason: 'Button should be enabled for valid email: $email',
        );
      } else {
        print('Button should be DISABLED');
        expect(
          button.onPressed,
          isNull,
          reason: 'Button should be disabled for invalid email: $email',
        );
      }

      // Reset for next test
      reset(mockAuthBloc);
      await tester.pumpWidget(Container()); // Clear previous widget
    }
  });
  // Test 6: Email field interaction
  testWidgets('should dispatch emailChanged event when email field changes', (
    WidgetTester tester,
  ) async {
    // Arrange
    await tester.pumpWidget(createTestableWidget());
    await tester.pump();

    clearInteractions(mockAuthBloc);

    // Act
    final emailFields = find.byType(TextFormField);
    await tester.enterText(emailFields.first, tEmail);

    // Assert
    verify(
      () => mockAuthBloc.add(const AuthEvent.emailChanged(tEmail)),
    ).called(1);
  });

  // Test 7: Password field interaction
  testWidgets(
    'should dispatch passwordChanged event when password field changes',
    (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestableWidget());
      await tester.pump();

      clearInteractions(mockAuthBloc);

      // Act
      final passwordFields = find.byType(TextFormField);
      await tester.enterText(passwordFields.at(1), tPassword);

      // Assert
      verify(
        () => mockAuthBloc.add(const AuthEvent.passwordChanged(tPassword)),
      ).called(1);
    },
  );

  // // Test 8: Form submission
  // testWidgets('should dispatch loginSubmitted when login button is pressed', (
  //   WidgetTester tester,
  // ) async {
  //   // Arrange
  //   final validState = AuthState(
  //     email: Email.dirty(tEmail),
  //     password: Password.dirty(tPassword),
  //     status: FormzSubmissionStatus.initial,
  //   );

  //   when(() => mockAuthBloc.state).thenReturn(validState);
  //   when(() => mockAuthBloc.stream).thenAnswer((_) => Stream.value(validState));

  //   await tester.pumpWidget(createTestableWidget());
  //   await tester.pump();

  //   clearInteractions(mockAuthBloc);

  //   // Act
  //   await tester.tap(find.text('LOGIN'));
  //   await tester.pump();

  //   // Assert
  //   verify(() => mockAuthBloc.add(const AuthEvent.loginSubmitted())).called(1);
  // });

  // Test 9: Error message display
 testWidgets('DEBUG: Check where error is displayed', (
  WidgetTester tester,
) async {
  final errorState = AuthState(
    email: Email.dirty(tEmail),
    password: Password.dirty(tPassword),
    status: FormzSubmissionStatus.failure,
    errorMessage: tError,
  );

  when(() => mockAuthBloc.state).thenReturn(errorState);
  when(() => mockAuthBloc.stream).thenAnswer((_) => Stream.value(errorState));

  await tester.pumpWidget(createTestableWidget());
  await tester.pump();

  // Print widget tree to see what's rendered
  debugDumpApp();

  // Check for different error display methods
  print('\n=== Looking for error message ===');
  print('Text "$tError" found: ${find.text(tError).evaluate().length} times');
  print('SnackBar found: ${find.byType(SnackBar).evaluate().length} times');
  print(
    'Error icon found: ${find.byIcon(Icons.error_outline).evaluate().length} times',
  );
  print(
    'Red container found: ${find.byWidgetPredicate((widget) => widget is Container && widget.decoration != null && (widget.decoration as BoxDecoration).color == Colors.red.shade50).evaluate().length} times',
  );
  
  // Add more specific checks for your custom error container
  print(
    'Pink error container found: ${find.byWidgetPredicate((widget) => 
      widget is Container && 
      widget.decoration != null && 
      widget.decoration is BoxDecoration &&
      (widget.decoration as BoxDecoration).color == const Color.fromRGBO(255, 235, 238, 1) // or your actual pink color
    ).evaluate().length} times',
  );
});
  // Test 10: Button disabled during loading
  testWidgets('button should be disabled during loading', (
    WidgetTester tester,
  ) async {
    // Arrange
    final loadingState = AuthState(
      email: Email.dirty(tEmail),
      password: Password.dirty(tPassword),
      status: FormzSubmissionStatus.inProgress,
    );

    when(() => mockAuthBloc.state).thenReturn(loadingState);
    when(
      () => mockAuthBloc.stream,
    ).thenAnswer((_) => Stream.value(loadingState));

    await tester.pumpWidget(createTestableWidget());
    await tester.pump();

    // Assert
    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNull);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
