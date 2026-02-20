import 'package:dio/dio.dart';
import 'package:tdddemo/core/constants/app_constants.dart';
import 'package:tdddemo/core/errors/exceptions.dart';
import 'package:tdddemo/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:tdddemo/features/auth/data/models/user_model.dart';
import 'package:tdddemo/features/auth/domain/entities/user.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl(this.dio);

  @override
  Future<User> login(String email, String password) async {
    try {
      final response = await dio.post(
        '${AppConstants.baseUrl}/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final userData = data['user'] as Map<String, dynamic>;
        // final token = data['token'] as String;
        
        // In a real app, you would cache the token here
        // await localDataSource.cacheToken(token);
        
        return UserModel.fromJson(userData);
      } else {
        throw ServerException('Login failed: ${response.statusCode}', null);
      }
    } on DioException catch (e) {
      throw ServerException('Network error: ${e.message}', null);
    } catch (e) {
      throw ServerException('Unexpected error: $e', null);
    }
  }
}