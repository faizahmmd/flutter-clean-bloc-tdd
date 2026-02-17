import 'package:tdddemo/features/auth/domain/entities/user.dart';

extension UserModel on User {
  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'avatar': avatar,
        'isVerified': isVerified,
      };

  static User fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      avatar: json['avatar'] as String?,
      isVerified: json['isVerified'] as bool? ?? false,
    );
  }
}