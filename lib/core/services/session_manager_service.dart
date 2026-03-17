import 'dart:developer';

import 'package:get/get.dart';
import 'package:lms_app/core/domain/routing/app_routes.dart';

import '../cache/local_storage_service.dart';
import '../cache/secure_storage_service.dart';
import '../presentation/localization/localization_keys.dart';

/// Service responsible for managing user sessions
/// Handles logout, session expiration, and navigation
class SessionManagerService {
  final LocalStorageService _localStorage;
  final SecureStorageService _secureStorage;

  // Flag to prevent multiple logout attempts
  bool _isLoggingOut = false;

  SessionManagerService({
    required LocalStorageService localStorage,
    required SecureStorageService secureStorage,
  }) : _localStorage = localStorage,
       _secureStorage = secureStorage;

  /// Handles session expiration by logging out the user and showing appropriate message
  /// [reason] - The reason for session expiration (optional)
  Future<void> handleSessionExpiration({String? reason}) async {
    if (_isLoggingOut) {
      log('SessionManager: Logout already in progress, skipping...');
      return;
    }

    _isLoggingOut = true;

    try {
      log('SessionManager: Handling session expiration. Reason: $reason');

      // Clear all stored tokens
      await _secureStorage.clearAllTokens();
      await _localStorage.clear();

      // Show session expired message to user
      await _showSessionExpiredMessage(reason);

      // Navigate to login screen
      await _navigateToLogin();

      log('SessionManager: Session expiration handled successfully');
    } catch (e) {
      log('SessionManager: Error handling session expiration: $e');
    } finally {
      _isLoggingOut = false;
    }
  }

  /// Shows appropriate message to user based on session expiration reason
  Future<void> _showSessionExpiredMessage(String? reason) async {
    try {
      String message =
          reason ??
          LocalizationKeys.authenticationRequiredButNoValidTokenAvailable.tr;
      String title =
          LocalizationKeys.authenticationRequiredButNoValidTokenAvailable.tr;

      Get.snackbar(
        title,
        message,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      log('SessionManager: Error showing session expired message: $e');
    }
  }

  /// Navigates user to login screen
  Future<void> _navigateToLogin() async {
    try {
      // Navigate to login screen and clear all previous routes
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      log('SessionManager: Error navigating to login: $e');
    }
  }

  /// Handles logout initiated by user
  /// [showMessage] - Whether to show logout confirmation message
  Future<void> handleUserLogout({bool showMessage = true}) async {
    if (_isLoggingOut) {
      log('SessionManager: Logout already in progress, skipping...');
      return;
    }

    _isLoggingOut = true;

    try {
      log('SessionManager: Handling user logout');

      // Clear all stored tokens
      await _secureStorage.clearAllTokens();
      await _localStorage.clear();

      // Show logout message if requested
      if (showMessage) {
        await _showLogoutMessage();
      }

      // Navigate to login screen
      await _navigateToLogin();

      log('SessionManager: User logout handled successfully');
    } catch (e) {
      log('SessionManager: Error handling user logout: $e');
    } finally {
      _isLoggingOut = false;
    }
  }

  /// Shows logout confirmation message
  Future<void> _showLogoutMessage() async {
    try {
      Get.snackbar(
        LocalizationKeys.sessionExpiredTitle.tr,
        LocalizationKeys.sessionExpiredMessage.tr,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      log('SessionManager: Error showing logout message: $e');
    }
  }

  /// Checks if user is currently logged in
  /// Returns true if user has valid tokens, false otherwise
  Future<bool> isUserLoggedIn() async {
    try {
      final accessToken = await _secureStorage.fetchAccessToken();

      return accessToken!.isNotEmpty;
    } catch (e) {
      log('SessionManager: Error checking login status: $e');
      return false;
    }
  }

  /// Clears all user data and tokens
  Future<void> clearUserData() async {
    try {
      await _secureStorage.clearAllTokens();
      await _localStorage.clear();
      log('SessionManager: User data cleared successfully');
    } catch (e) {
      log('SessionManager: Error clearing user data: $e');
    }
  }
}
