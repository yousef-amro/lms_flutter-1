import 'package:dartz/dartz.dart';
import 'package:get/get.dart';
import 'package:lms_app/core/domain/models/core_model.dart';
import 'package:lms_app/features/auth/domain/models/request/register_device_request.dart';
import 'package:lms_app/features/auth/domain/models/request/register_model.dart';

import '../../../../core/data/networking/data/network_request.dart';
import '../../../../core/data/networking/data/network_response.dart';
import '../../../../core/data/networking/data/network_router.dart';
import '../../../../core/data/networking/network_adapter.dart';
import '../../../../core/domain/errors/failure.dart';
import '../../../../core/presentation/localization/localization_keys.dart';
import '../../domain/models/auth_credentials.dart';
import '../../domain/models/refresh_token_model.dart';

abstract class AuthRemoteDataSourceAbstraction {
  Future<Either<Failure, RefreshTokenModel>> refreshToken(String refresh);
  Future<Either<Failure, AuthCredentials>> manualLogin(
    String username,
    String password,
  );
  Future<Either<Failure, bool>> register(RegisterApiModel data);
  Future<Either<Failure, List<CoreModel>>> fetchGenerations();
  Future<Either<Failure, List<CoreModel>>> fetchCities();
  Future<Either<Failure, void>> registerDevice(RegisterDeviceRequest request);
}

class AuthRemoteDataSource implements AuthRemoteDataSourceAbstraction {
  final NetworkAdapterAbstraction _networkAdapter;

  AuthRemoteDataSource(this._networkAdapter);

  @override
  Future<Either<Failure, RefreshTokenModel>> refreshToken(
    String refresh,
  ) async {
    final request = NetworkRequest(
      route: NetworkRouter.refreshToken,
      requestType: RequestType.post,
      data: {'refresh': refresh},
    );
    final response = await _networkAdapter.request(request);
    if (response.status == NetworkResponseStatus.success) {
      return Right(RefreshTokenModel.fromJson(response.data));
    } else {
      return Left(response.failure!);
    }
  }

  @override
  Future<Either<Failure, AuthCredentials>> manualLogin(
    String username,
    String password,
  ) async {
    final request = NetworkRequest(
      route: NetworkRouter.login,
      requestType: RequestType.post,
      data: {
        'mobile_number': username,
        'username': username,
        'password': password,
      },
    );

    final response = await _networkAdapter.request(request);
    if (response.status == NetworkResponseStatus.success) {
      try {
        if (response.data is! Map<String, dynamic>) {
          return Left(
            UnAuthenticatedFailure(
              failureMessage: LocalizationKeys.somethingWentWrong.tr,
            ),
          );
        }

        final json = response.data as Map<String, dynamic>;
        final hasExpectedShape = json['access'] != null &&
            json['refresh'] != null &&
            json['user'] != null;
        if (!hasExpectedShape) {
          return Left(
            UnAuthenticatedFailure(
              failureMessage: _extractErrorMessage(json),
            ),
          );
        }

        return Right(AuthCredentials.fromJson(json));
      } catch (_) {
        return Left(
          UnAuthenticatedFailure(
            failureMessage: _extractErrorMessage(response.data),
          ),
        );
      }
    } else {
      return Left(response.failure!);
    }
  }

  @override
  Future<Either<Failure, bool>> register(RegisterApiModel data) async {
    final request = NetworkRequest(
      route: NetworkRouter.register,
      requestType: RequestType.post,
      data: data.toJson(),
    );
    final response = await _networkAdapter.request(request);
    if (response.status == NetworkResponseStatus.success) {
      return const Right(true);
    } else {
      return Left(response.failure!);
    }
  }

  @override
  Future<Either<Failure, List<CoreModel>>> fetchGenerations() async {
    final request = NetworkRequest(
      route: NetworkRouter.generations,
      requestType: RequestType.get,
    );

    final response = await _networkAdapter.request(request);
    if (response.status == NetworkResponseStatus.success) {
      final items = _extractList(response.data)
          .whereType<Map<String, dynamic>>()
          .map(CoreModel.fromJson)
          .toList();
      return Right(items);
    } else {
      return Left(response.failure!);
    }
  }

  @override
  Future<Either<Failure, List<CoreModel>>> fetchCities() async {
    final request = NetworkRequest(
      route: NetworkRouter.cities,
      requestType: RequestType.get,
    );

    final response = await _networkAdapter.request(request);
    if (response.status == NetworkResponseStatus.success) {
      final items = _extractList(response.data)
          .whereType<Map<String, dynamic>>()
          .map(CoreModel.fromJson)
          .toList();
      return Right(items);
    } else {
      return Left(response.failure!);
    }
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      const keys = ['results', 'data', 'items', 'payload'];
      for (final key in keys) {
        final value = data[key];
        if (value is List) return value;
      }
    }
    return const [];
  }

  String _extractErrorMessage(dynamic responseData) {
    if (responseData == null) {
      return LocalizationKeys.somethingWentWrong.tr;
    }

    if (responseData is String) {
      return responseData;
    }

    if (responseData is Map<String, dynamic>) {
      final error = responseData['error'];
      if (error is String && error.isNotEmpty) return error;

      final detail = responseData['detail'];
      if (detail is String && detail.isNotEmpty) return detail;

      final message = responseData['message'];
      if (message is String && message.isNotEmpty) return message;

      final nonFieldErrors =
          (error is Map<String, dynamic>) ? error['non_field_errors'] : null;
      if (nonFieldErrors is List && nonFieldErrors.isNotEmpty) {
        final first = nonFieldErrors.first;
        if (first is String && first.isNotEmpty) return first;
      }
    }

    return LocalizationKeys.somethingWentWrong.tr;
  }

  @override
  Future<Either<Failure, void>> registerDevice(
    RegisterDeviceRequest request,
  ) async {
    final networkRequest = NetworkRequest(
      route: NetworkRouter.registerDevice,
      requestType: RequestType.post,
      data: request.toJson(),
      isAuthorizationRequired: true,
    );
    final response = await _networkAdapter.request(networkRequest);
    if (response.status == NetworkResponseStatus.success) {
      return const Right(null);
    } else {
      return Left(response.failure!);
    }
  }
}
