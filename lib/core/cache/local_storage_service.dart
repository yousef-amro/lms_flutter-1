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

  void remove(LocalStorageKeys key) {
    _sharedPreferences?.remove(key.key);
  }

  void clear() {
    _sharedPreferences?.clear();
  }
}

class LocalStorageService extends BaseStorage {
  LocalStorageService._();
  static final LocalStorageService _instance = LocalStorageService._();
  factory LocalStorageService() => _instance;

  set locale(String languageCode) => sharedPreferences?.setString(
    LocalStorageKeys.languageCode.key,
    languageCode,
  );

  set user(UserModel data) {
    _sharedPreferences?.setString(
      LocalStorageKeys.user.key,
      jsonEncode(data.toJson()),
    );
  }

  UserModel? get user {
    final data = _sharedPreferences?.getString(LocalStorageKeys.user.key);
    if (data != null && data.isNotEmpty) {
      return UserModel.fromJson(jsonDecode(data));
    }
    return null;
  }

  String get versionName =>
      sharedPreferences?.getString(LocalStorageKeys.versionName.key) ?? '1.0.0';

  set versionName(String versionName) => sharedPreferences?.setString(
    LocalStorageKeys.versionName.key,
    versionName,
  );

  String get versionNumber =>
      sharedPreferences?.getString(LocalStorageKeys.versionNumber.key) ?? '1';

  set versionNumber(String versionNumber) => sharedPreferences?.setString(
    LocalStorageKeys.versionNumber.key,
    versionNumber,
  );

  String get deviceTimezone =>
      sharedPreferences?.getString(LocalStorageKeys.deviceTimezone.key) ??
      'Asia/Amman';

  set deviceTimezone(String deviceTimezone) => sharedPreferences?.setString(
    LocalStorageKeys.deviceTimezone.key,
    deviceTimezone,
  );

  String get locale =>
      sharedPreferences?.getString(LocalStorageKeys.languageCode.key) ?? 'en';

  set themeMode(ThemeMode value) =>
      sharedPreferences?.setString(LocalStorageKeys.themeMode.key, value.name);

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
