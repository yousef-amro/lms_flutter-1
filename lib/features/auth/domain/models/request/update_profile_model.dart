class UpdateProfileModel {
  final String firstName;
  final String lastName;
  final String storeName;

  UpdateProfileModel({
    required this.firstName,
    required this.lastName,
    required this.storeName,
  });

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'store_name': storeName,
    };
  }
}
