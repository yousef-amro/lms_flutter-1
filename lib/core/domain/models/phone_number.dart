class PhoneNumber {
  final String? number;
  final String? countryCode;

  PhoneNumber({
    required this.number,
    required this.countryCode,
  });

  factory PhoneNumber.fromJson(Map<String, dynamic> json) => PhoneNumber(
        number: json["number"] ?? '',
        countryCode: json["country_code"],
      );

  Map<String, dynamic> toJson() => {
        "number": number,
        "country_code": countryCode,
      };
}
