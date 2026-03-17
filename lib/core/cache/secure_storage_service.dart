import 'dart:convert';
import 'dart:developer';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../data/data_sources/local_storage_keys.dart';

abstract class BaseSecureStorage {
  FlutterSecureStorage? _secureStorage;
  bool _isInitialized = false;

  Future<void> init() async {
    if (!_isInitialized) {
      _secureStorage = const FlutterSecureStorage();
      _isInitialized = true;
    }
  }

  bool get isInitialized => _isInitialized;

  FlutterSecureStorage? get secureStorage => _secureStorage;

  Future<void> remove(LocalStorageKeys key) async {
    await _secureStorage?.delete(key: key.key);
  }

  Future<void> clear() async {
    await _secureStorage?.deleteAll();
  }
}

class SecureStorageService extends BaseSecureStorage {
  SecureStorageService._();
  static final SecureStorageService _instance = SecureStorageService._();
  factory SecureStorageService() => _instance;

  Future<void> cacheAccessToken(String accessToken) async {
    // Store the access token
    await secureStorage?.write(
      key: LocalStorageKeys.accessToken.key,
      value: accessToken,
    );

    // Extract and store token expiration from JWT
    await _extractAndStoreTokenExpiration(accessToken);
  }

  Future<void> cacheAccessTokenForResetPassword(String accessToken) async {
    await secureStorage?.write(
      key: LocalStorageKeys.accessTokenForResetPassword.key,
      value: accessToken,
    );
  }

  Future<String?> fetchAccessTokenForResetPassword() async =>
      await secureStorage?.read(
        key: LocalStorageKeys.accessTokenForResetPassword.key,
      ) ??
      "";

  Future<String?> fetchAccessToken() async =>
      await secureStorage?.read(key: LocalStorageKeys.accessToken.key) ?? "";

  Future<void> cacheRefreshToken(String refreshToken) async =>
      await secureStorage?.write(
        key: LocalStorageKeys.refreshToken.key,
        value: refreshToken,
      );

  Future<String?> fetchRefreshToken() async =>
      await secureStorage?.read(key: LocalStorageKeys.refreshToken.key);

  void cacheTokenExpiration(int expirationTimestamp) => secureStorage?.write(
    key: LocalStorageKeys.tokenExpiration.key,
    value: expirationTimestamp.toString(),
  );

  Future<int?> fetchTokenExpiration() async {
    final value = await secureStorage?.read(
      key: LocalStorageKeys.tokenExpiration.key,
    );
    return value != null ? int.tryParse(value) : null;
  }

  Future<bool> isTokenExpired() async {
    final expiration = await fetchTokenExpiration();
    if (expiration == null) return true;
    final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return currentTime >= expiration;
  }

  Future<bool> isTokenExpiringSoon({int minutesThreshold = 1}) async {
    final expiration = await fetchTokenExpiration();
    if (expiration == null) return true;

    final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final thresholdSeconds = minutesThreshold * 60;
    return (expiration - currentTime) <= thresholdSeconds;
  }

  Future<void> clearAllTokens() async {
    await remove(LocalStorageKeys.accessToken);
    await remove(LocalStorageKeys.refreshToken);
    await remove(LocalStorageKeys.accessTokenForResetPassword);
    await remove(LocalStorageKeys.tokenExpiration);
  }

  Future<void> clearAllTokensForResetPassword() async {
    await remove(LocalStorageKeys.accessTokenForResetPassword);
  }

  /// Extracts expiration time from JWT token and stores it
  Future<void> _extractAndStoreTokenExpiration(String accessToken) async {
    try {
      // JWT tokens have 3 parts separated by dots
      final parts = accessToken.split('.');
      if (parts.length != 3) {
        log('SecureStorage: Invalid JWT token format');
        return;
      }

      // Decode the payload (second part)
      final payload = parts[1];
      // Add padding if needed for base64 decoding
      final paddedPayload = payload.padRight(
        payload.length + (4 - payload.length % 4) % 4,
        '=',
      );

      // Decode base64
      final decodedBytes = base64Url.decode(paddedPayload);
      final decodedString = String.fromCharCodes(decodedBytes);

      // Parse JSON to get expiration
      final payloadMap = Map<String, dynamic>.from(jsonDecode(decodedString));

      final exp = payloadMap['exp'];
      if (exp != null && exp is int) {
        cacheTokenExpiration(exp);
        log('SecureStorage: Token expiration stored: $exp');
      } else {
        log('SecureStorage: No expiration found in token payload');
      }
    } catch (e) {
      log('SecureStorage: Error extracting token expiration: $e');
      // Don't throw here as this is not critical for token functionality
    }
  }
}
