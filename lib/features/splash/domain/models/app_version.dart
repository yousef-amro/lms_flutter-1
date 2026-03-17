enum UpdateStatus { none, soft, hard }

class AppVersion {
  final UpdateStatus status;
  final String? platform;
  final String? url;
  final int? versionNumber;

  AppVersion({
    required this.status,
    this.platform,
    this.url,
    this.versionNumber,
  });

  factory AppVersion.fromJson(Map<String, dynamic> json) {
    return AppVersion(
      status: _appStatusMapper(
        isUpToDate: json['is_uptodate'] ?? true,
        updateString: json['release']?['release_type'],
      ),
      platform: json['release']?['platform'],
      versionNumber: json['release']?['version_number'],
      url: json['release']?['download_url'],
    );
  }

  static UpdateStatus _appStatusMapper({
    required bool isUpToDate,
    required String? updateString,
  }) {
    if (isUpToDate) return UpdateStatus.none;
    return UpdateStatus.values.singleWhere(
      (status) => status.name == updateString,
      orElse: () => UpdateStatus.none,
    );
  }
}
