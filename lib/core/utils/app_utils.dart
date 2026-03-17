import 'dart:io';

import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../cache/local_storage_service.dart';
import '../presentation/localization/app_localization.dart';

/// Handles app info: version, locale, timezone.
class AppUtils {
  final LocalStorageService _storage;
  final PackageInfo _pkg;

  static AppUtils? _instance;

  AppUtils._(this._storage, this._pkg);

  /// Initialize singleton instance and set all info automatically
  static Future<AppUtils> init(LocalStorageService storage) async {
    if (_instance != null) return _instance!;
    final pkg = await PackageInfo.fromPlatform();
    _instance = AppUtils._(storage, pkg);

    // Automatically set version, locale, timezone
    await _instance!._setAll();

    return _instance!;
  }

  /// Set version, locale, timezone
  Future<void> _setAll() async {
    _version();
    _locale();
    await _timezone();
  }

  void _version() {
    _storage.versionName = _pkg.version;
    _storage.versionNumber = _pkg.buildNumber;
  }

  void _locale() {
    String loc = _storage.locale;

    if (loc.isEmpty) {
      loc = Platform.localeName.split('_').first;
      if (loc.isEmpty || !AppLocalization().keys.keys.contains(loc)) {
        loc = 'ar';
      }
      _storage.locale = loc;
    }
  }

  Future<void> _timezone() async {
    _storage.deviceTimezone = await _getTz();
  }

  Future<String> _getTz() async {
    try {
      return (await FlutterTimezone.getLocalTimezone())
          .identifier; // e.g. "Asia/Amman"
    } catch (_) {
      return DateTime.now().timeZoneName;
    }
  }
}
