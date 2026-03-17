class RegisterApiModel {
  final String fullName;
  final String mobileNumber;
  final String generation;
  final String city;
  final String password;

  RegisterApiModel({
    required this.fullName,
    required this.mobileNumber,
    required this.generation,
    required this.city,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'mobile_number': mobileNumber,
      'password': password,
      'generation': generation,
      'city': city,
    };
  }
}
