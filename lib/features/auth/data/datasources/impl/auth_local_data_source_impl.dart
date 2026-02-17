import 'package:shared_preferences/shared_preferences.dart';
import 'package:tdddemo/core/constants/app_constants.dart';
import 'package:tdddemo/core/errors/exceptions.dart';
import 'package:tdddemo/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:tdddemo/features/auth/data/models/user_model.dart';
import 'package:tdddemo/features/auth/domain/entities/user.dart';
import 'dart:convert';

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<void> cacheUser(User user) async {
    try {
      final userJson = user.toJson();
      await sharedPreferences.setString(
        AppConstants.userKey,
        jsonEncode(userJson),
      );
    } catch (e) {
      throw CacheException('Failed to cache user: $e', null);
    }
  }

  @override
  Future<User> getCachedUser() async {
    try {
      final userJsonString = sharedPreferences.getString(AppConstants.userKey);
      if (userJsonString == null) {
        throw CacheException('No user found in cache', null);
      }
      final userJson = jsonDecode(userJsonString) as Map<String, dynamic>;
      return UserModel.fromJson(userJson);
    } catch (e) {
      throw CacheException('Failed to get cached user: $e', null);
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await sharedPreferences.remove(AppConstants.userKey);
      await sharedPreferences.remove(AppConstants.tokenKey);
    } catch (e) {
      throw CacheException('Failed to clear cache: $e', null);
    }
  }

  @override
  Future<bool> hasToken() async {
    return sharedPreferences.containsKey(AppConstants.tokenKey);
  }

  @override
  Future<void> cacheToken(String token) async {
    try {
      await sharedPreferences.setString(AppConstants.tokenKey, token);
    } catch (e) {
      throw CacheException('Failed to cache token: $e', null);
    }
  }

  @override
  Future<String> getToken() async {
    final token = sharedPreferences.getString(AppConstants.tokenKey);
    if (token == null) {
      throw CacheException('No token found', null);
    }
    return token;
  }
}