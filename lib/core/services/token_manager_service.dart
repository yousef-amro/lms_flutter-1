import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';

import '../../features/auth/domain/models/refresh_token_model.dart';
import '../cache/secure_storage_service.dart';
import '../data/networking/data/network_request.dart';
import '../data/networking/data/network_response.dart';
import '../data/networking/data/network_router.dart';
import '../data/networking/network_adapter.dart';
import '../presentation/localization/localization_keys.dart';
import 'session_manager_service.dart';

/// Service responsible for managing authentication tokens
/// Handles automatic token refresh, expiration checking, and logout functionality
class TokenManagerService {
  final SecureStorageService _secureStorage;
  NetworkAdapterAbstraction? _networkAdapter;
  final SessionManagerService _sessionManager;

  // Flag to prevent multiple simultaneous refresh attempts
  bool _isRefreshing = false;

  // Counter for refresh attempts to prevent infinite loops
  int _refreshAttempts = 0;
  static const int _maxRefreshAttempts = 1;

  TokenManagerService({
    required SecureStorageService secureStorage,
    NetworkAdapterAbstraction? networkAdapter,
    required SessionManagerService sessionManager,
  }) : _secureStorage = secureStorage,
       _networkAdapter = networkAdapter,
       _sessionManager = sessionManager;

  /// Sets the network adapter (used for dependency injection)
  void setNetworkAdapter(NetworkAdapterAbstraction networkAdapter) {
    _networkAdapter = networkAdapter;
  }

  /// Checks if the current access token is valid and not expired
  /// Returns true if token is valid, false otherwise
  Future<bool> isTokenValid() async {
    try {
      final accessToken = await _secureStorage.fetchAccessToken();
      if (accessToken!.isEmpty) {
        log('TokenManager: No access token found');
        return false;
      }

      final isExpired = await _secureStorage.isTokenExpired();
      if (isExpired) {
        log('TokenManager: Access token is expired');
        return false;
      }

      return true;
    } catch (e) {
      log('TokenManager: Error checking token validity: $e');
      return false;
    }
  }

  /// Checks if the token is expiring soon (within the specified threshold)
  /// [minutesThreshold] - Number of minutes before expiration to consider "expiring soon"
  /// Returns true if token is expiring soon, false otherwise
  Future<bool> isTokenExpiringSoon({int minutesThreshold = 1}) async {
    try {
      return await _secureStorage.isTokenExpiringSoon(
        minutesThreshold: minutesThreshold,
      );
    } catch (e) {
      log('TokenManager: Error checking if token is expiring soon: $e');
      return true; // Assume it's expiring soon if we can't check
    }
  }

  /// Refreshes the access token using the refresh token
  /// Returns true if refresh was successful, false otherwise
  Future<bool> refreshToken() async {
    // Check if network adapter is available
    if (_networkAdapter == null) {
      log('TokenManager: Network adapter not available');
      await _handleRefreshFailure('Network adapter not available');
      return false;
    }

    // Check if we've exceeded maximum refresh attempts
    if (_refreshAttempts >= _maxRefreshAttempts) {
      log('TokenManager: Maximum refresh attempts reached, logging out user');
      await _sessionManager.handleSessionExpiration(
        reason: LocalizationKeys.sessionRenewalFailedAfterMultipleAttempts.tr,
      );
      return false;
    }

    // Prevent multiple simultaneous refresh attempts
    if (_isRefreshing) {
      log('TokenManager: Token refresh already in progress, waiting...');
      // Wait for the current refresh to complete
      while (_isRefreshing) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      return await isTokenValid();
    }

    _isRefreshing = true;
    _refreshAttempts++;

    try {
      log(
        'TokenManager: Starting token refresh (attempt $_refreshAttempts)...',
      );

      final refreshToken = await _secureStorage.fetchRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        log('TokenManager: No refresh token available');
        await _handleRefreshFailure(
          LocalizationKeys.noRefreshTokenAvailable.tr,
        );
        return false;
      }

      final request = NetworkRequest(
        route: NetworkRouter.refreshToken,
        requestType: RequestType.post,
        data: {'refresh': refreshToken},
        isAuthorizationRequired: false,
      );

      final response = await _networkAdapter!.request(request);

      if (response.status == NetworkResponseStatus.success) {
        await _handleSuccessfulRefresh(response.data);
        log('TokenManager: Token refresh successful');
        // Reset refresh attempts counter on successful refresh
        _refreshAttempts = 0;
        return true;
      } else {
        log('TokenManager: Token refresh failed: ${response.failure?.message}');
        await _handleRefreshFailure(
          response.failure?.message ?? LocalizationKeys.unknownError.tr,
        );
        return false;
      }
    } catch (e) {
      log('TokenManager: Exception during token refresh: $e');
      await _handleRefreshFailure(LocalizationKeys.errorDuringTokenRefresh.tr);
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  /// Handles successful token refresh by storing new tokens
  Future<void> _handleSuccessfulRefresh(dynamic responseData) async {
    try {
      final refreshTokenModel = RefreshTokenModel.fromJson(responseData);

      // Store new tokens
      await _secureStorage.cacheAccessToken(refreshTokenModel.access);
      await _secureStorage.cacheRefreshToken(refreshTokenModel.refresh);

      // Extract and store token expiration (assuming JWT format)
      await _extractAndStoreTokenExpiration(refreshTokenModel.access);

      log('TokenManager: New tokens stored successfully');
    } catch (e) {
      log('TokenManager: Error storing refreshed tokens: $e');
      throw Exception('Failed to store refreshed tokens: $e');
    }
  }

  /// Extracts expiration time from JWT token and stores it
  Future<void> _extractAndStoreTokenExpiration(String accessToken) async {
    try {
      // JWT tokens have 3 parts separated by dots
      final parts = accessToken.split('.');
      if (parts.length != 3) {
        log('TokenManager: Invalid JWT token format');
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
        _secureStorage.cacheTokenExpiration(exp);
        log('TokenManager: Token expiration stored: $exp');
      } else {
        log('TokenManager: No expiration found in token payload');
      }
    } catch (e) {
      log('TokenManager: Error extracting token expiration: $e');
      // Don't throw here as this is not critical for token functionality
    }
  }

  /// Handles refresh token failure by logging out the user
  Future<void> _handleRefreshFailure(String reason) async {
    log('TokenManager: Refresh failed, logging out user. Reason: $reason');
    await _sessionManager.handleSessionExpiration(reason: reason);
  }

  /// Ensures a valid token is available before making authenticated requests
  /// Returns true if token is valid or was successfully refreshed, false otherwise
  Future<bool> ensureValidToken() async {
    try {
      // Check if token is valid
      if (await isTokenValid()) {
        // Check if token is expiring soon
        if (await isTokenExpiringSoon()) {
          log('TokenManager: Token expiring soon, refreshing...');
          return await refreshToken();
        }
        return true;
      } else {
        log('TokenManager: Token invalid, attempting refresh...');
        return await refreshToken();
      }
    } catch (e) {
      log('TokenManager: Error ensuring valid token: $e');
      return false;
    }
  }

  /// Resets the refresh attempts counter
  /// This should be called after successful authentication
  void resetRefreshAttempts() {
    _refreshAttempts = 0;
    log('TokenManager: Refresh attempts counter reset');
  }

  /// Clears all stored tokens and logs out the user
  Future<void> logout() async {
    await _sessionManager.handleUserLogout();
  }
}
