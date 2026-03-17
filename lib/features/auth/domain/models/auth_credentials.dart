import '../../../../core/domain/models/user_model.dart';

enum LoginMethod {
  credentials,
  google,
  facebook,
  apple;

  const LoginMethod();
}

class AuthCredentials {
  final String accessToken;
  final String refreshToken;
  final UserModel user;

  AuthCredentials({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthCredentials.fromJson(Map<String, dynamic> json) {
    return AuthCredentials(
      accessToken: json['access'],
      refreshToken: json['refresh'],
      user: UserModel.fromJson(json['user']),
    );
  }
}
