class CheckMobileModel {
  final bool isRegistered;
  final String message;
  final String formattedNumber;

  CheckMobileModel({
    required this.isRegistered,
    required this.message,
    required this.formattedNumber,
  });

  factory CheckMobileModel.fromJson(Map<String, dynamic> json) {
    return CheckMobileModel(
      isRegistered: json['is_registered'],
      message: json['message'],
      formattedNumber: json['formatted_number'],
    );
  }
}
