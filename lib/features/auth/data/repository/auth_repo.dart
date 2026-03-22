import 'package:dartz/dartz.dart' show Either;
import 'package:lms_app/core/cache/local_storage_service.dart';
import 'package:lms_app/core/domain/models/user_model.dart';
import 'package:lms_app/features/auth/domain/models/request/register_device_request.dart';

import '../../../../core/cache/secure_storage_service.dart';
import '../../../../core/domain/errors/failure.dart';
import '../../domain/models/auth_credentials.dart';
import '../data_source/auth_remote_data_source.dart';

abstract class AuthRepositoryAbstraction {
  Future<Either<Failure, AuthCredentials>> manualLogin(
    String username,
    String password,
  );
  Future<void> setAccessToken({String? accessToken, String? refreshToken});
  Future<void> setAccessTokenForResetPassword({String? accessToken});
  Future<void> setUserData(UserModel user);
  Future<void> clearAllTokens();
  Future<Either<Failure, void>> registerDevice(RegisterDeviceRequest request);
}

class AuthRepository implements AuthRepositoryAbstraction {
  final AuthRemoteDataSourceAbstraction _remoteDataSource;
  final SecureStorageService _secureStorage;
  final LocalStorageService _localStorage;

  AuthRepository(
    this._remoteDataSource,
    this._secureStorage,
    this._localStorage,
  );

  @override
  Future<Either<Failure, AuthCredentials>> manualLogin(
    String username,
    String password,
  ) => _remoteDataSource.manualLogin(username, password);

  @override
  Future<void> setAccessToken({
    String? accessToken,
    String? refreshToken,
  }) async {
    if (accessToken != null && accessToken.isNotEmpty) {
      // Save access token
      await _secureStorage.cacheAccessToken(accessToken);
    }

    if (refreshToken != null && refreshToken.isNotEmpty) {
      // Save refresh token
      await _secureStorage.cacheRefreshToken(refreshToken);
    }

    // If neither token is provided or both are empty, remove both from storage
    if ((accessToken == null || accessToken.isEmpty) &&
        (refreshToken == null || refreshToken.isEmpty)) {
      await _secureStorage.clearAllTokens();
    }
  }

  @override
  Future<void> setAccessTokenForResetPassword({String? accessToken}) async {
    if (accessToken != null && accessToken.isNotEmpty) {
      // Save access token
      await _secureStorage.cacheAccessTokenForResetPassword(accessToken);
    }
  }

  @override
  Future<void> setUserData(UserModel user) async {
    await _localStorage.setUser(user);
  }

  @override
  Future<void> clearAllTokens() async {
    await _secureStorage.clearAllTokens();
  }

  @override
  Future<Either<Failure, void>> registerDevice(RegisterDeviceRequest request) =>
      _remoteDataSource.registerDevice(request);
}
