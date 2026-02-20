// ====================================================
// WHY WE NEED EXCEPTION CLASSES:
// 1. Type-safe error handling (not strings/ints)
// 2. Automatic stack traces for debugging
// 3. Structured error hierarchy
// 4. Integration with Dart's error handling system
// ====================================================

// ====================================================
// WHY implements Exception INSTEAD OF extends Exception:
// - implements: We want Exception BEHAVIOR but with OUR structure
// - extends: Would force us to use Exception's optional message parameter
// - implements gives us full control over constructor and fields
// ====================================================

// Base app exception class
// implements Exception = "Behaves like Exception but with our rules"
abstract class AppException implements Exception {
  final String message;       // Required message (Exception's is optional)
  final StackTrace? stackTrace; // Extra field Exception doesn't have
  
  // Our constructor, not forced to call super()
  AppException({required this.message, this.stackTrace});
  
  @override
  String toString() {
    return message;  // Custom toString (Exception adds "Exception: " prefix)
  }
}

// ====================================================
// WHAT super() CONSTRUCTOR DOES:
// - Calls parent class (AppException) constructor
// - Passes values to initialize parent's fields
// - MUST be called if parent has no default constructor
// ====================================================

// Server-specific exception
class ServerException extends AppException {
  // Constructor with parameters
  ServerException(String message, StackTrace? stackTrace)
    // super() = Call AppException constructor with our values
    : super(message: message, stackTrace: stackTrace);
}

// Cache-related exception  
class CacheException extends AppException {
  CacheException(String message, StackTrace? stackTrace)
    : super(message: message, stackTrace: stackTrace);
}

// Network connectivity exception
class NetworkException extends AppException {
  NetworkException(String message, StackTrace? stackTrace)
    : super(message: message, stackTrace: stackTrace);
}

// Data validation exception
class ValidationException extends AppException {
  ValidationException(String message, StackTrace? stackTrace)
    : super(message: message, stackTrace: stackTrace);
}

// ====================================================
// USAGE EXAMPLE:
// try {
//   await fetchData();
// } on NetworkException catch (e) {
//   debugPrint('Network error: ${e.message}');
//   debugPrint('Stack trace: ${e.stackTrace}');
// } on AppException catch (e) {
//   debugPrint('App error: ${e.message}');
// }
// ====================================================