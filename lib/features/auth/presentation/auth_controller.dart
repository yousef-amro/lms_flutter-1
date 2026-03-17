import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms_app/core/cache/local_storage_service.dart';
import 'package:lms_app/core/domain/routing/app_routes.dart';
import 'package:lms_app/features/chat/presentation/controllers/chat_controller.dart';

import '../../../core/domain/utils/alerts.dart';
import '../../../core/presentation/localization/localization_keys.dart';
import '../../../core/services/session_manager_service.dart';
import '../../../core/services/token_manager_service.dart';
import '../data/repository/auth_repo.dart';
import '../domain/models/auth_credentials.dart';

enum AuthState { initial, loading, success, failure }

class AuthController extends GetxController with Alerts {
  final AuthRepositoryAbstraction _repository;
  final TokenManagerService _tokenManager;
  final SessionManagerService _sessionManager;
  final LocalStorageService _localStorage;

  static const String loginScreenId = 'login_screen';

  final TextEditingController phoneController = TextEditingController(
    text: kDebugMode ? "0791234567" : "",
  );
  final TextEditingController passwordController =
      TextEditingController(text: kDebugMode ? "Test@123" : "");

  bool obscurePassword = true;

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

  bool get isLoading => authState == AuthState.loading;
  static const double _tabletBreakpoint = 600.0;
  static const double _maxAuthContentWidth = 430.0;
  static const double _authDesignWidth = 393.0;

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    update([loginScreenId]);
  }

  double loginScreenWidth(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= _tabletBreakpoint) return _maxAuthContentWidth;
    return width;
  }

  double loginContentMinHeight(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.size.height -
        mediaQuery.padding.top -
        mediaQuery.padding.bottom;
  }

  double authScale(BuildContext context) {
    return loginScreenWidth(context) / _authDesignWidth;
  }

  void _updateAuthScreens() {
    update([loginScreenId]);
  }

  void submitLogin(GlobalKey<FormState> formKey) {
    if (formKey.currentState?.validate() ?? false) {
      login(
        username: phoneController.text.trim(),
        password: passwordController.text.trim(),
      );
    }
  }

  Future<void> login({
    required String username,
    required String password,
  }) async {
    authState = AuthState.loading;
    _updateAuthScreens();

    try {
      final response = await _repository.manualLogin(
        username,
        password,
      );
      await response.fold(
        (failure) async {
          authState = AuthState.failure;
          showFailSnackbar(text: failure.message.tr);
          _updateAuthScreens();
        },
        (credentials) async {
          await continueToApp(credentials: credentials);
        },
      );
    } catch (e) {
      authState = AuthState.failure;
      showFailSnackbar(text: LocalizationKeys.somethingWentWrong.tr);
      _updateAuthScreens();
      if (kDebugMode) {
        debugPrint('AuthController.login exception: $e');
      }
    }
  }

  Future<void> continueAfterFunction({
    String? screen,
    required String mobileNumber,
  }) async {
    if (screen == "login") {
      Get.toNamed(
        AppRoutes.login,
        arguments: {'mobileNumber': mobileNumber},
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
    _updateAuthScreens();

    // Start chat socket after successful login so incoming student messages arrive
    try {
      await Get.find<ChatController>().connect();
    } catch (_) {}

    Get.offAllNamed(AppRoutes.home);
  }

  String? emptyValidator(String value) {
    if (value.isNotEmpty) return null;
    return LocalizationKeys.fieldRequired.tr;
  }

  String? phoneNumberValidator(String value) {
    final phone = value.trim();
    if (phone.isEmpty) return LocalizationKeys.fieldRequired.tr;

    final isOnlyDigits = RegExp(r'^\d+$').hasMatch(phone);
    final hasValidPrefix =
        phone.startsWith('077') ||
        phone.startsWith('078') ||
        phone.startsWith('079');
    final hasValidLength = phone.length == 10;

    if (!isOnlyDigits || !hasValidPrefix || !hasValidLength) {
      return LocalizationKeys.enterValidPhoneNumber.tr;
    }

    return null;
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

      await _sessionManager.handleUserLogout(
        showMessage: showMessage,
      );

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
      showFailSnackbar(
        text: LocalizationKeys.errorDuringTokenRefresh.tr,
      );
      update();
      return false;
    }
  }

  @override
  void onClose() {
    phoneController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
