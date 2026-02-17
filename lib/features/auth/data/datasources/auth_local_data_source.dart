import 'package:tdddemo/features/auth/domain/entities/user.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(User user);
  Future<User> getCachedUser();
  Future<void> clearCache();
  Future<bool> hasToken();
  Future<void> cacheToken(String token);
  Future<String> getToken();
}