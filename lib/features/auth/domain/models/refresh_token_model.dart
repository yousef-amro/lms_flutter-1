class RefreshTokenModel {
  final String access;
  final String refresh;

  RefreshTokenModel({
    required this.access,
    required this.refresh,
  });

  factory RefreshTokenModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return RefreshTokenModel(
      access: json['access'],
      refresh: json['refresh'],
    );
  }
}
