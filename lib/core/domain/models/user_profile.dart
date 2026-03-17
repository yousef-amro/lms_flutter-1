class UserProfile {
  UserProfile({
    required this.id,
    this.firstName,
    this.name,
    this.lastName,
    this.nickname,
    this.nationality,
    this.placeOfResidence,
    this.gender,
    this.birthDate,
    this.email,
    this.hasCar,
    this.carType,
    this.hobbies = const [],
    this.interests = const [],
    this.hasBusiness,
    this.subscribedNewsletter,
    this.hasNotification = false,
    required this.points,
    required this.nextRankPoints,
    required this.isVerified,
    required this.sendNotification,
    this.photo,
    this.isOnboarded,
  });

  final int id;
  final int points;
  final int nextRankPoints;
  final bool isVerified;
  final bool hasNotification;
  final bool sendNotification;
  final String? photo;
  final String? name;
  final String? firstName;
  final String? lastName;
  final String? nickname;
  final DateTime? birthDate;
  final String? nationality;
  final String? placeOfResidence;
  final String? gender;
  final String? email;
  final bool? hasCar;
  final bool? isOnboarded;
  final String? carType;
  final List<String> hobbies;
  final List<String> interests;
  final bool? hasBusiness;
  final bool? subscribedNewsletter;

  String fullName() {
    if (nickname != null) {
      return nickname!;
    }
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return '';
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      firstName: json['first_name'],
      hasNotification: json['has_notification'] ?? false,
      lastName: json['last_name'],
      nickname: json['nick_name'],
      birthDate: DateTime.tryParse(json['birth_date'] ?? ''),
      gender: json['gender'],
      nationality: json['nationality'],
      placeOfResidence: json['country'],
      email: json['email'],

      hasCar: json['has_car'],
      carType: json['car_type'],
      isOnboarded: json['is_onboarded'],
      hobbies: List.from(json['hobbies'] ?? []),
      interests: List.from(json['interests'] ?? []),
      hasBusiness: json['has_business'],
      subscribedNewsletter: json['subscribe_newsletter'],
      points: json['point'],
      isVerified: json['is_verified'] ?? false,
      sendNotification: json['send_notification'] ?? false,
      photo: json['profile_photo'],
      nextRankPoints: json['next_rank_value'] ?? 0,
    );
  }

  factory UserProfile.fromOther(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      name: json['username'],
      nickname: json['nick_name'],
      placeOfResidence: json['country_display'],
      hobbies: List.from(json['hobbies'] ?? []),
      points: json['point'],
      isVerified: json['is_verified'] ?? false,
      photo: json['profile_image'],
      nextRankPoints: json['next_rank'] ?? 0,
      sendNotification: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (firstName != null) "first_name": firstName,
      if (lastName != null) "last_name": lastName,
      if (nickname != null) "nick_name": nickname,
      if (gender != null) "gender": gender,
      if (nationality != null) "nationality": nationality,
      if (placeOfResidence != null) "country": placeOfResidence,
      if (email != null) "email": email,
      if (hasBusiness != null) "has_business": hasBusiness ?? false,
      if (hasCar != null) "has_car": hasCar ?? false,
      if (carType != null) "car_type": carType,
      if (hobbies.isNotEmpty) "hobbies": hobbies,
      if (interests.isNotEmpty) "interests": interests,
      if (isOnboarded != null) 'is_onboarded': isOnboarded,
      if (subscribedNewsletter != null) "newsletter": subscribedNewsletter,
    };
  }

  UserProfile copyWith({
    String? firstName,
    String? lastName,
    String? nickname,
    DateTime? birthDate,
    String? nationality,
    String? placeOfResidence,
    String? gender,
    String? email,
    bool? hasCar,
    String? carType,
    List<String>? hobbies,
    List<String>? interests,
    bool? hasBusiness,
    bool? hasNotification,
    bool? subscribedNewsletter,
    int? points,
    int? nextRankPoints,
    bool? isVerified,
    bool? isOnboarded,
    bool? sendNotification,
    String? photo,
  }) {
    return UserProfile(
      id: id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      nickname: nickname ?? this.nickname,
      nationality: nationality ?? this.nationality,
      placeOfResidence: placeOfResidence ?? this.placeOfResidence,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      email: email ?? this.email,
      hasCar: hasCar ?? this.hasCar,
      carType: carType ?? this.carType,
      isOnboarded: isOnboarded ?? this.isOnboarded,
      hobbies: hobbies ?? this.hobbies,
      interests: interests ?? this.interests,
      hasBusiness: hasBusiness ?? this.hasBusiness,
      hasNotification: hasNotification ?? this.hasNotification,
      subscribedNewsletter: subscribedNewsletter ?? this.subscribedNewsletter,
      sendNotification: sendNotification ?? this.sendNotification,
      isVerified: isVerified ?? this.isVerified,
      points: points ?? this.points,
      photo: photo ?? this.photo,
      nextRankPoints: nextRankPoints ?? this.nextRankPoints,
    );
  }

  bool checkIsOnboarded() {
    return [
      firstName,
      lastName,
      nickname,
      nationality,
      placeOfResidence,
      gender,
      birthDate,
      email,
      hasCar,
      carType,
      hobbies,
      interests,
      hasBusiness,
      subscribedNewsletter,
    ].every((element) {
      final hasValue = element != null;
      bool isNotEmpty = true;
      if (element is String?) {
        isNotEmpty = element?.isNotEmpty ?? false;
      } else if (element is List) {
        isNotEmpty = element.isNotEmpty;
      }
      return hasValue && isNotEmpty;
    });
  }
}
