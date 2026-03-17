import 'package:get/get.dart';
import 'package:lms_app/core/cache/local_storage_service.dart';
import 'package:lms_app/core/domain/routing/app_routes.dart';

import '../../../core/domain/utils/alerts.dart';
import '../../../core/presentation/localization/localization_keys.dart';
import '../../../core/services/session_manager_service.dart';
import '../../../core/services/token_manager_service.dart';
import '../data/repository/auth_repo.dart';
import '../domain/models/auth_credentials.dart';
import 'login/login_screen.dart';

enum AuthState { initial, loading, success, failure }

class AuthController extends GetxController with Alerts {
  final AuthRepositoryAbstraction _repository;
  final TokenManagerService _tokenManager;
  final SessionManagerService _sessionManager;
  final LocalStorageService _localStorage;

  AuthController({
    required AuthRepositoryAbstraction repository,
    required TokenManagerService tokenManager,
    required SessionManagerService sessionManager,
    required LocalStorageService localStorage,
  }) : _repository = repository,
       _tokenManager = tokenManager,
       _sessionManager = sessionManager,
       _localStorage = localStorage;

  AuthState authState = AuthState.initial;

  LocalStorageService get localStorage => _localStorage;

  Future<void> login({
    required String username,
    required String password,
  }) async {
    authState = AuthState.loading;
    update([LoginScreen]);

    final response = await _repository.manualLogin(username, password);

    response.fold(
      (failure) {
        authState = AuthState.failure;
        showFailSnackbar(text: failure.message.tr);
        update([LoginScreen]);
      },
      (credentials) async {
        continueToApp(credentials: credentials);
      },
    );
  }

  Future<void> continueAfterFunction({
    String? screen,
    required String mobileNumber,
  }) async {
    if (screen == "login") {
      Get.toNamed(AppRoutes.login, arguments: {'mobileNumber': mobileNumber});
    } else if (screen == "register") {
      Get.toNamed(
        AppRoutes.login,
        arguments: {'mobileNumber': mobileNumber, 'screen': 'register'},
      );
    }
  }

  Future<void> continueToApp({AuthCredentials? credentials}) async {
    if (credentials != null) {
      await _repository.setAccessToken(
        accessToken: credentials.accessToken,
        refreshToken: credentials.refreshToken,
      );
      await _repository.setUserData(credentials.user);

      // Reset refresh attempts counter after successful login
      _tokenManager.resetRefreshAttempts();
    }

    authState = AuthState.success;
    // if (credentials != null) {
    //   await Get.find<ProfileController>().fetchUser();
    // }
    update([LoginScreen]);
    Get.offAllNamed(AppRoutes.dashboard);
  }

  String? emptyValidator(String value) {
    if (value.isNotEmpty) return null;
    return LocalizationKeys.fieldRequired.tr;
  }

  // Oldest

  /// When browsing as a guest, call this method with null params.
  /// With null params (Guest) the access token will not be saved.
  /// If a was token saved before, it will be removed.
  /// And logging in as guest won't count for setting first login.

  /// Handles user logout using the session manager
  Future<void> logout({bool showMessage = true}) async {
    try {
      authState = AuthState.loading;
      update();

      await _sessionManager.handleUserLogout(showMessage: showMessage);

      authState = AuthState.initial;
      update();
    } catch (e) {
      authState = AuthState.failure;
      showFailSnackbar(text: LocalizationKeys.logoutError.tr);
      update();
    }
  }

  /// Checks if user is currently logged in
  Future<bool> isUserLoggedIn() async {
    try {
      return await _sessionManager.isUserLoggedIn();
    } catch (e) {
      return false;
    }
  }

  /// Manually refreshes the token (for testing purposes)
  Future<bool> refreshToken() async {
    try {
      authState = AuthState.loading;
      update();

      final success = await _tokenManager.refreshToken();

      if (success) {
        showSuccessSnackbar(
          text: LocalizationKeys.tokenRefreshedSuccessfully.tr,
        );
      }

      authState = AuthState.success;
      update();
      return success;
    } catch (e) {
      authState = AuthState.failure;
      showFailSnackbar(text: LocalizationKeys.errorDuringTokenRefresh.tr);
      update();
      return false;
    }
  }
}
