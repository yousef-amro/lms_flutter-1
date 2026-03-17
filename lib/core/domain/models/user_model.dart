import 'package:lms_app/core/domain/models/json_response_model.dart';

class UserModel {
  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
  });
  final String id;
  final String username;
  final String email;
  final String? firstName;
  final String? lastName;

  factory UserModel.guest() {
    return UserModel(
      id: '',
      username: '',
      email: '',
      firstName: '',
      lastName: '',
    );
  }

  factory UserModel.empty() {
    return UserModel(
      id: '',
      firstName: '',
      lastName: '',
      username: '',
      email: '',
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final jsonHelper = JsonResponseModel.instance();

    return UserModel(
      id: jsonHelper.getStringJson(json, 'id') ?? '',
      firstName: jsonHelper.getStringJson(json, 'first_name'),
      lastName: jsonHelper.getStringJson(json, 'last_name'),
      username: jsonHelper.getStringJson(json, 'username') ?? '',
      email: jsonHelper.getStringJson(json, 'email') ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'first_name': firstName,
    'last_name': lastName,
    'username': username,
    'email': email,
  };

  Map<String, dynamic> toJsonUpdateMode() => {
    'first_name': firstName,
    'last_name': lastName,
    'username': username,
    'email': email,
  };
}
