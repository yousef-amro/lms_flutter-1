class RegisterDeviceRequest {
  final String token;
  final String? platform;

  const RegisterDeviceRequest({required this.token, this.platform});

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      if (platform != null) 'platform': platform,
    };
  }
}

