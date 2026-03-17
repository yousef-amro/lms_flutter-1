import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lms_app/core/domain/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/data_sources/local_storage_keys.dart';

abstract class BaseStorage {
  SharedPreferences? _sharedPreferences;
  bool _isInitialized = false;

  Future<void> init() async {
    if (!_isInitialized) {
      _sharedPreferences = await SharedPreferences.getInstance();
      _isInitialized = true;
    }
  }

  bool get isInitialized => _isInitialized;

  SharedPreferences? get sharedPreferences => _sharedPreferences;

  Future<void> remove(LocalStorageKeys key) async {
    await _sharedPreferences?.remove(key.key);
  }

  Future<void> clear() async {
    await _sharedPreferences?.clear();
  }
}

class LocalStorageService extends BaseStorage {
  LocalStorageService._();
  static final LocalStorageService _instance = LocalStorageService._();
  factory LocalStorageService() => _instance;

  Future<void> setLocale(String languageCode) async {
    await sharedPreferences?.setString(
      LocalStorageKeys.languageCode.key,
      languageCode,
    );
  }

  // Backwards-compatible setter (not awaitable).
  set locale(String languageCode) => setLocale(languageCode);

  Future<void> setUser(UserModel data) async {
    await sharedPreferences?.setString(
      LocalStorageKeys.user.key,
      jsonEncode(data.toJson()),
    );
  }

  // Backwards-compatible setter (not awaitable).
  set user(UserModel data) => setUser(data);

  UserModel? get user {
    final data = _sharedPreferences?.getString(LocalStorageKeys.user.key);
    if (data != null && data.isNotEmpty) {
      return UserModel.fromJson(jsonDecode(data));
    }
    return null;
  }

  String get versionName =>
      sharedPreferences?.getString(LocalStorageKeys.versionName.key) ?? '1.0.0';

  Future<void> setVersionName(String versionName) async {
    await sharedPreferences?.setString(
      LocalStorageKeys.versionName.key,
      versionName,
    );
  }

  // Backwards-compatible setter (not awaitable).
  set versionName(String versionName) => setVersionName(versionName);

  String get versionNumber =>
      sharedPreferences?.getString(LocalStorageKeys.versionNumber.key) ?? '1';

  Future<void> setVersionNumber(String versionNumber) async {
    await sharedPreferences?.setString(
      LocalStorageKeys.versionNumber.key,
      versionNumber,
    );
  }

  // Backwards-compatible setter (not awaitable).
  set versionNumber(String versionNumber) => setVersionNumber(versionNumber);

  String get deviceTimezone =>
      sharedPreferences?.getString(LocalStorageKeys.deviceTimezone.key) ??
      'Asia/Amman';

  Future<void> setDeviceTimezone(String deviceTimezone) async {
    await sharedPreferences?.setString(
      LocalStorageKeys.deviceTimezone.key,
      deviceTimezone,
    );
  }

  // Backwards-compatible setter (not awaitable).
  set deviceTimezone(String deviceTimezone) => setDeviceTimezone(deviceTimezone);

  String get locale =>
      sharedPreferences?.getString(LocalStorageKeys.languageCode.key) ?? 'ar';

  Future<void> setThemeMode(ThemeMode value) async {
    await sharedPreferences?.setString(
      LocalStorageKeys.themeMode.key,
      value.name,
    );
  }

  // Backwards-compatible setter (not awaitable).
  set themeMode(ThemeMode value) => setThemeMode(value);

  ThemeMode get themeMode {
    // Default: always return light theme.
    // To enable stored/system theme, comment out the next line.
    return ThemeMode.light;

    // -----------------------------------------
    // Uncomment the following code to use stored/system theme:

    /*
    final String? modeString = sharedPreferences?.getString(
      LocalStorageKeys.themeMode.key,
    );

    if (modeString == null ||
        !(ThemeMode.values.map((e) => e.name).contains(modeString))) {
      final Brightness platformBrightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      final ThemeMode systemMode = platformBrightness == Brightness.dark
          ? ThemeMode.dark
          : ThemeMode.light;
      sharedPreferences?.setString(
        LocalStorageKeys.themeMode.key,
        systemMode.name,
      );
      return systemMode;
    }

    try {
      return ThemeMode.values.byName(modeString);
    } catch (_) {
      return ThemeMode.system;
    }
    */
  }

  bool get isDarkMode => themeMode == ThemeMode.dark;
}
