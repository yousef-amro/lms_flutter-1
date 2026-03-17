class RegisterApiModel {
  final String firstName;
  final String lastName;
  final String mobileNumber;
  final String otpCode;
  final String storeName;
  final String password;

  RegisterApiModel({
    required this.firstName,
    required this.lastName,
    required this.mobileNumber,
    required this.otpCode,
    required this.storeName,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'mobile_number': mobileNumber,
      'otp_code': otpCode,
      'store_name': storeName,
      'password': password,
    };
  }
}
