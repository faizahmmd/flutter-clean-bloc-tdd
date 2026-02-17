// Main entry point of the Flutter application
import 'package:flutter/material.dart';
import 'package:tdddemo/app.dart';  // Main app widget
import 'package:tdddemo/injection_container.dart' as di;  // DI setup file

Future<void> main() async {
  // 1. Initialize Flutter engine bindings (REQUIRED before any Flutter code)
  // Ensures native platform channels are ready
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Initialize Dependency Injection (GetIt setup)
  // Sets up all services, repositories, blocs before app starts
  await di.init();
  
  // 3. Launch the Flutter application
  runApp(const MyApp());
}

// ====================================================
// EXECUTION ORDER:
// 1. WidgetsFlutterBinding.ensureInitialized() → Platform ready
// 2. di.init() → Register all dependencies (Dio, BLoCs, Repos, etc.)
// 3. runApp() → Start Flutter UI with MyApp widget
// 
// WHY ASYNC MAIN?
// - di.init() might need async operations (SharedPreferences.getInstance())
// - Need to wait for DI setup before starting UI
// 
// TYPICAL MyApp CONTENTS (in app.dart):
// - MaterialApp/CupertinoApp
// - Theme configuration
// - Route definitions
// - Provider/Bloc wrappers
// ====================================================