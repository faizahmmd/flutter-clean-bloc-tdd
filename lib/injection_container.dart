// Dependency injection setup using GetIt
// This file initializes all dependencies for the app
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tdddemo/core/network/network_info.dart';
import 'package:tdddemo/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:tdddemo/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:tdddemo/features/auth/data/datasources/impl/auth_local_data_source_impl.dart';
import 'package:tdddemo/features/auth/data/datasources/impl/auth_remote_data_source_impl.dart';
import 'package:tdddemo/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:tdddemo/features/auth/domain/repositories/auth_repository.dart';
import 'package:tdddemo/features/auth/domain/usecases/login_usecase.dart';
import 'package:tdddemo/features/auth/presentation/bloc/auth/auth_bloc.dart';

// GetIt service locator instance - central registry for dependencies
final sl = GetIt.instance;

// Initialization function - sets up dependency injection
Future<void> init() async {
  //! External Dependencies - Third-party packages
  // SharedPreferences for local storage (key-value)
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  
  // Dio for HTTP requests with timeout configuration
  final dio = Dio(BaseOptions(
    connectTimeout: const Duration(milliseconds: 5000),  // 5s connection timeout
    receiveTimeout: const Duration(milliseconds: 3000),  // 3s receive timeout
  ));
  sl.registerLazySingleton(() => dio);
  
  // Connectivity for checking network status
  sl.registerLazySingleton(() => Connectivity());

  //! Core Layer - App-wide infrastructure
  // NetworkInfo checks internet connectivity (using Connectivity)
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl<Connectivity>()),
  );

  //! Data Sources Layer - Data access implementations
  // Local data source (SharedPreferences implementation)
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sl<SharedPreferences>()),
  );
  
  // Remote data source (API calls via Dio)
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl<Dio>()),
  );

  //! Repository Layer - Mediates between data sources and domain
  // Main repository combining local, remote, and network check
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl<AuthRemoteDataSource>(),
      localDataSource: sl<AuthLocalDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  //! Use Cases Layer - Business logic (Clean Architecture)
  // Login use case - contains authentication business rules
  sl.registerLazySingleton(() => LoginUseCase(sl<AuthRepository>()));

  //! Presentation Layer - UI/State management
  // AuthBloc (factory = new instance each time, for Flutter widgets)
  sl.registerFactory(
    () => AuthBloc(loginUseCase: sl<LoginUseCase>()),
  );
}

// ====================================================
// KEY CONCEPTS:
// 
// 1. GetIt: Service locator pattern (like DI container)
// 2. registerLazySingleton: Creates once, reuses instance
// 3. registerFactory: Creates new instance each time
// 4. sl<T>(): Gets registered dependency of type T
// 
// DEPENDENCY FLOW:
// AuthBloc → LoginUseCase → AuthRepository → 
// [AuthRemoteDataSource + AuthLocalDataSource + NetworkInfo] → 
// [Dio + SharedPreferences + Connectivity]
// 
// USAGE EXAMPLE:
// In Flutter widget: AuthBloc authBloc = sl<AuthBloc>();
// ====================================================