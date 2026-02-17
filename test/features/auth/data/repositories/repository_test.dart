import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tdddemo/core/errors/exceptions.dart';
import 'package:tdddemo/core/errors/failures.dart';
import 'package:tdddemo/core/network/network_info.dart';
import 'package:tdddemo/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:tdddemo/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:tdddemo/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:tdddemo/features/auth/domain/entities/user.dart';

// Mock classes
class MockNetworkInfo extends Mock implements NetworkInfo {}

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

// Fake classes for fallback values
class UserFake extends Fake implements User {
  @override
  String get id => 'fake_id';
  
  @override
  String get email => 'fake@example.com';
  
  @override
  String get name => 'Fake User';
  
  @override
  String? get accessToken => 'fake_token';
}

// Option 2: Create a simple instance for fallback
final fakeUser = User(
  id: 'fake_id',
  email: 'fake@example.com',
  name: 'Fake User',
  accessToken: 'fake_token',
);

// Test data
const tEmail = 'test@example.com';
const tPassword = 'password123';
const tAccessToken = 'access_token_123';
const tErrorMessage = 'Server error';
const tCacheErrorMessage = 'Cache error';

final tUser = User(
  id: '1',
  email: tEmail,
  name: 'Test User',
  accessToken: tAccessToken,
);

void main() {
  late AuthRepositoryImpl repository;
  late MockNetworkInfo mockNetworkInfo;
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockAuthLocalDataSource mockLocalDataSource;

  // Set up fallback values for all custom types
  setUpAll(() {
    // Register fallback for User
    registerFallbackValue(fakeUser);
    // OR register the fake class
    // registerFallbackValue(UserFake());
    
    // Register fallback for ServerException (if needed)
    registerFallbackValue(ServerException('', null));
    
    // Register fallback for CacheException (if needed)
    registerFallbackValue(CacheException('', null));
    
    // Register fallback for NetworkFailure
    registerFallbackValue(NetworkFailure(''));
    
    // Register fallback for ServerFailure
    registerFallbackValue(ServerFailure(''));
    
    // Register fallback for CacheFailure
    registerFallbackValue(CacheFailure(''));
  });

  setUp(() {
    mockNetworkInfo = MockNetworkInfo();
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockLocalDataSource = MockAuthLocalDataSource();
    
    repository = AuthRepositoryImpl(
      networkInfo: mockNetworkInfo,
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
  });

  group('login', () {
    test(
      'should check if device is online',
      () async {
        // Arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockRemoteDataSource.login(tEmail, tPassword))
            .thenAnswer((_) async => tUser);
        // Use specific value instead of any()
        when(() => mockLocalDataSource.cacheUser(tUser))
            .thenAnswer((_) async {});
        when(() => mockLocalDataSource.cacheToken(tAccessToken))
            .thenAnswer((_) async {});

        // Act
        await repository.login(tEmail, tPassword);

        // Assert
        verify(() => mockNetworkInfo.isConnected).called(1);
      },
    );

    test(
      'should return NetworkFailure when there is no internet connection',
      () async {
        // Arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

        // Act
        final result = await repository.login(tEmail, tPassword);

        // Assert
        expect(result, equals(const Left(NetworkFailure('No internet connection'))));
        verify(() => mockNetworkInfo.isConnected).called(1);
        verifyNoMoreInteractions(mockRemoteDataSource);
        verifyNoMoreInteractions(mockLocalDataSource);
      },
    );

    test(
      'should call remoteDataSource.login with correct parameters when online',
      () async {
        // Arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockRemoteDataSource.login(tEmail, tPassword))
            .thenAnswer((_) async => tUser);
        // Use specific value instead of any()
        when(() => mockLocalDataSource.cacheUser(tUser))
            .thenAnswer((_) async {});
        when(() => mockLocalDataSource.cacheToken(tAccessToken))
            .thenAnswer((_) async {});

        // Act
        await repository.login(tEmail, tPassword);

        // Assert
        verify(() => mockRemoteDataSource.login(tEmail, tPassword)).called(1);
      },
    );

    test(
      'should cache user when login is successful',
      () async {
        // Arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockRemoteDataSource.login(tEmail, tPassword))
            .thenAnswer((_) async => tUser);
        // Use specific value instead of any()
        when(() => mockLocalDataSource.cacheUser(tUser))
            .thenAnswer((_) async {});
        when(() => mockLocalDataSource.cacheToken(tAccessToken))
            .thenAnswer((_) async {});

        // Act
        await repository.login(tEmail, tPassword);

        // Assert
        verify(() => mockLocalDataSource.cacheUser(tUser)).called(1);
      },
    );

    test(
      'should cache token when login is successful and token exists',
      () async {
        // Arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockRemoteDataSource.login(tEmail, tPassword))
            .thenAnswer((_) async => tUser);
        // Use specific value instead of any()
        when(() => mockLocalDataSource.cacheUser(tUser))
            .thenAnswer((_) async {});
        when(() => mockLocalDataSource.cacheToken(tAccessToken))
            .thenAnswer((_) async {});

        // Act
        await repository.login(tEmail, tPassword);

        // Assert
        verify(() => mockLocalDataSource.cacheToken(tAccessToken)).called(1);
      },
    );

    test(
      'should not cache token when login is successful but token is null',
      () async {
        // Arrange
        final userWithoutToken = tUser.copyWith(accessToken: null);
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockRemoteDataSource.login(tEmail, tPassword))
            .thenAnswer((_) async => userWithoutToken);
        // Use specific value instead of any()
        when(() => mockLocalDataSource.cacheUser(userWithoutToken))
            .thenAnswer((_) async {});

        // Act
        await repository.login(tEmail, tPassword);

        // Assert
        verifyNever(() => mockLocalDataSource.cacheToken(any()));
        verify(() => mockLocalDataSource.cacheUser(userWithoutToken)).called(1);
      },
    );

    test(
      'should return User when login is successful',
      () async {
        // Arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockRemoteDataSource.login(tEmail, tPassword))
            .thenAnswer((_) async => tUser);
        // Use specific value instead of any()
        when(() => mockLocalDataSource.cacheUser(tUser))
            .thenAnswer((_) async {});
        when(() => mockLocalDataSource.cacheToken(tAccessToken))
            .thenAnswer((_) async {});

        // Act
        final result = await repository.login(tEmail, tPassword);

        // Assert
        expect(result, equals(Right(tUser)));
      },
    );

    test(
      'should return ServerFailure when remoteDataSource throws ServerException',
      () async {
        // Arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockRemoteDataSource.login(tEmail, tPassword))
            .thenThrow(ServerException(tErrorMessage, null));

        // Act
        final result = await repository.login(tEmail, tPassword);

        // Assert
        expect(result, equals(Left(ServerFailure(tErrorMessage))));
        verify(() => mockRemoteDataSource.login(tEmail, tPassword)).called(1);
        verifyNoMoreInteractions(mockLocalDataSource);
      },
    );

    test(
      'should return CacheFailure when localDataSource throws CacheException',
      () async {
        // Arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockRemoteDataSource.login(tEmail, tPassword))
            .thenAnswer((_) async => tUser);
        // Use specific value instead of any()
        when(() => mockLocalDataSource.cacheUser(tUser))
            .thenThrow(CacheException(tCacheErrorMessage, null));

        // Act
        final result = await repository.login(tEmail, tPassword);

        // Assert
        expect(result, equals(Left(CacheFailure(tCacheErrorMessage))));
        verify(() => mockRemoteDataSource.login(tEmail, tPassword)).called(1);
        verify(() => mockLocalDataSource.cacheUser(tUser)).called(1);
      },
    );

    test(
      'should return ServerFailure for any other unexpected error',
      () async {
        // Arrange
        const unexpectedError = 'Unexpected error occurred';
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockRemoteDataSource.login(tEmail, tPassword))
            .thenThrow(unexpectedError);

        // Act
        final result = await repository.login(tEmail, tPassword);

        // Assert
        expect(result, equals(Left(ServerFailure('Unexpected error: $unexpectedError'))));
      },
    );
  });

  group('logout', () {
    test(
      'should call localDataSource.clearCache',
      () async {
        // Arrange
        when(() => mockLocalDataSource.clearCache())
            .thenAnswer((_) async {});

        // Act
        await repository.logout();

        // Assert
        verify(() => mockLocalDataSource.clearCache()).called(1);
      },
    );

    test(
      'should return Right(null) when logout is successful',
      () async {
        // Arrange
        when(() => mockLocalDataSource.clearCache())
            .thenAnswer((_) async {});

        // Act
        final result = await repository.logout();

        // Assert
        expect(result, equals(const Right(null)));
      },
    );

    test(
      'should return CacheFailure when localDataSource throws CacheException',
      () async {
        // Arrange
        when(() => mockLocalDataSource.clearCache())
            .thenThrow(CacheException(tCacheErrorMessage, null));

        // Act
        final result = await repository.logout();

        // Assert
        expect(result, equals(Left(CacheFailure(tCacheErrorMessage))));
      },
    );

    test(
      'should return CacheFailure for any other unexpected error',
      () async {
        // Arrange
        const unexpectedError = 'Unexpected logout error';
        when(() => mockLocalDataSource.clearCache())
            .thenThrow(unexpectedError);

        // Act
        final result = await repository.logout();

        // Assert
        expect(result, equals(Left(CacheFailure('Unexpected error: $unexpectedError'))));
      },
    );
  });

  group('getCurrentUser', () {
    test(
      'should call localDataSource.getCachedUser',
      () async {
        // Arrange
        when(() => mockLocalDataSource.getCachedUser())
            .thenAnswer((_) async => tUser);

        // Act
        await repository.getCurrentUser();

        // Assert
        verify(() => mockLocalDataSource.getCachedUser()).called(1);
      },
    );

    test(
      'should return User when user is cached',
      () async {
        // Arrange
        when(() => mockLocalDataSource.getCachedUser())
            .thenAnswer((_) async => tUser);

        // Act
        final result = await repository.getCurrentUser();

        // Assert
        expect(result, equals(Right(tUser)));
      },
    );

    test(
      'should return CacheFailure when localDataSource throws CacheException',
      () async {
        // Arrange
        when(() => mockLocalDataSource.getCachedUser())
            .thenThrow(CacheException(tCacheErrorMessage, null));

        // Act
        final result = await repository.getCurrentUser();

        // Assert
        expect(result, equals(Left(CacheFailure(tCacheErrorMessage))));
      },
    );

    test(
      'should return CacheFailure for any other unexpected error',
      () async {
        // Arrange
        const unexpectedError = 'Unexpected get user error';
        when(() => mockLocalDataSource.getCachedUser())
            .thenThrow(unexpectedError);

        // Act
        final result = await repository.getCurrentUser();

        // Assert
        expect(result, equals(Left(CacheFailure('Unexpected error: $unexpectedError'))));
      },
    );
  });

  group('isLoggedIn', () {
    test(
      'should call localDataSource.hasToken',
      () async {
        // Arrange
        when(() => mockLocalDataSource.hasToken())
            .thenAnswer((_) async => true);

        // Act
        await repository.isLoggedIn();

        // Assert
        verify(() => mockLocalDataSource.hasToken()).called(1);
      },
    );

    test(
      'should return true when token exists',
      () async {
        // Arrange
        when(() => mockLocalDataSource.hasToken())
            .thenAnswer((_) async => true);

        // Act
        final result = await repository.isLoggedIn();

        // Assert
        expect(result, equals(const Right(true)));
      },
    );

    test(
      'should return false when token does not exist',
      () async {
        // Arrange
        when(() => mockLocalDataSource.hasToken())
            .thenAnswer((_) async => false);

        // Act
        final result = await repository.isLoggedIn();

        // Assert
        expect(result, equals(const Right(false)));
      },
    );

    test(
      'should return CacheFailure when localDataSource throws CacheException',
      () async {
        // Arrange
        when(() => mockLocalDataSource.hasToken())
            .thenThrow(CacheException(tCacheErrorMessage, null));

        // Act
        final result = await repository.isLoggedIn();

        // Assert
        expect(result, equals(Left(CacheFailure(tCacheErrorMessage))));
      },
    );

    test(
      'should return CacheFailure for any other unexpected error',
      () async {
        // Arrange
        const unexpectedError = 'Unexpected isLoggedIn error';
        when(() => mockLocalDataSource.hasToken())
            .thenThrow(unexpectedError);

        // Act
        final result = await repository.isLoggedIn();

        // Assert
        expect(result, equals(Left(CacheFailure('Unexpected error: $unexpectedError'))));
      },
    );
  });
}