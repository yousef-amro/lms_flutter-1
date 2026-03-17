import 'dart:developer';
import 'dart:io';

import 'package:curl_logger_dio_interceptor/curl_logger_dio_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide FormData, Response;
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../../../environments/app_environments.dart';
import '../../cache/secure_storage_service.dart';
import '../../domain/errors/failure.dart';
import '../../presentation/localization/localization_keys.dart';
import '../../services/token_manager_service.dart';
import 'data/network_request.dart';
import 'data/network_response.dart';
import 'data/network_router.dart';

abstract class NetworkAdapterAbstraction {
  Future<NetworkResponse> request(
    NetworkRequest request, [
    Function(double progress)? onProgress,
    String? savePath,
  ]);
}

class NetworkAdapter implements NetworkAdapterAbstraction {
  final Dio _dio;
  final SecureStorageService _secureLocalStorage;
  final TokenManagerService _tokenManager;
  final bool isRTL;

  NetworkAdapter({
    required Dio dio,
    required SecureStorageService secureLocalStorage,
    required TokenManagerService tokenManager,
    required this.isRTL,
  }) : _dio = dio,
       _secureLocalStorage = secureLocalStorage,
       _tokenManager = tokenManager {
    if (kDebugMode) {
      _dio.interceptors.addAll([
        PrettyDioLogger(
          maxWidth: 300,
          requestHeader: true,
          logPrint: (networkLog) => log(networkLog.toString()),
        ),
        CurlLoggerDioInterceptor(printOnSuccess: true),
      ]);
    }
  }

  @override
  Future<NetworkResponse> request(
    NetworkRequest request, [
    Function(double progress)? onProgress,
    String? savePath,
  ]) async {
    try {
      // For requests that require authorization, ensure we have a valid token
      if (request.isAuthorizationRequired) {
        final tokenValid = await _tokenManager.ensureValidToken();
        if (!tokenValid) {
          log(
            'NetworkAdapter: Failed to ensure valid token for authorized request',
          );
          return NetworkResponse(
            status: NetworkResponseStatus.failure,
            failure: UnAuthenticatedFailure(
              failureMessage: LocalizationKeys
                  .authenticationRequiredButNoValidTokenAvailable
                  .tr,
            ),
          );
        }
      }

      Response response;
      String? accessToken;

      if (request.isAuthorizationRequired) {
        accessToken = await _secureLocalStorage.fetchAccessToken();
      }

      if (request.isAuthorizationResetPassword) {
        accessToken = await _secureLocalStorage
            .fetchAccessTokenForResetPassword();
      }

      final options = _dioOptions(
        accessToken,
        request.additionalHeaders,
        isRTL,
      );
      final url = _urlBuilder(request.route, request.urlIdentifier);
      final data = request.isFormData
          ? FormData.fromMap(request.data!)
          : request.data;

      if (request.isFormData && request.files != null) {
        (data as FormData).files.addAll(request.files!);
      }

      switch (request.requestType) {
        case RequestType.post:
          response = await _dio.post(
            url,
            data: data,
            queryParameters: request.parameters,
            options: options,
            onSendProgress: (int sent, int total) =>
                _onSendProgress(sent, total, onProgress),
          );
          break;
        case RequestType.get:
          response = await _dio.get(
            url,
            queryParameters: request.parameters,
            data: request.data,
            options: options,
          );
          break;
        case RequestType.patch:
          response = await _dio.patch(
            url,
            data: data,
            queryParameters: request.parameters,
            options: options,
            onSendProgress: (int sent, int total) =>
                _onSendProgress(sent, total, onProgress),
          );
          break;
        case RequestType.delete:
          response = await _dio.delete(
            url,
            data: data,
            queryParameters: request.parameters,
            options: options,
          );
          break;
        case RequestType.put:
          response = await _dio.put(
            url,
            data: data,
            queryParameters: request.parameters,
            options: options,
          );
        case RequestType.download:
          response = await _dio.download(
            request.urlIdentifier!,
            savePath,
            queryParameters: request.parameters,
            data: request.data,
          );
          break;
      }

      return _responseMapper(response);
    } catch (exception) {
      final failure =
          exception is DioException &&
              (exception.type == DioExceptionType.receiveTimeout ||
                  exception.type == DioExceptionType.connectionError)
          ? InternetFailure()
          : ServerFailure();
      return NetworkResponse(
        status: NetworkResponseStatus.failure,
        failure: failure,
      );
    }
  }

  String _urlBuilder(NetworkRouter route, [String? urlIdentifier]) {
    return '${AppEnvironmentHelper().getEnvironmentVariable('BASE_URL')}${route.path}${urlIdentifier ?? ''}';
  }

  void _onSendProgress(
    int sent,
    int total,
    Function(double progress)? onProgress,
  ) {
    if (onProgress == null) return;
    double progress = sent / total;
    onProgress.call(progress);
  }

  NetworkResponse _responseMapper(Response response) {
    switch (response.statusCode) {
      case HttpStatus.ok:
      case HttpStatus.created:
      case HttpStatus.accepted:
      case HttpStatus.noContent:
      case HttpStatus.movedPermanently:
        return NetworkResponse(
          status: NetworkResponseStatus.success,
          data: response.data,
        );
      case HttpStatus.unauthorized:
        // Handle unauthorized response by attempting token refresh
        _handleUnauthorizedResponse();
        return NetworkResponse(
          status: NetworkResponseStatus.failure,
          data: response.data,
          failure: UnAuthenticatedFailure(
            failureMessage: extractErrorMessage(response.data),
          ),
        );
      default:
        return NetworkResponse(
          status: NetworkResponseStatus.failure,
          data: response.data,
          failure: ServerFailure(
            failureMessage: extractErrorMessage(response.data),
          ),
        );
    }
  }

  /// Extracts error message from response data dynamically
  /// Handles various error formats including validation errors and nested error objects
  String extractErrorMessage(dynamic responseData) {
    if (responseData == null) {
      return 'Server error occurred';
    }

    // Handle simple error message
    if (responseData is String) {
      return responseData;
    }

    // Handle Map response
    if (responseData is Map<String, dynamic>) {
      // Check for simple error field
      if (responseData.containsKey('error') &&
          responseData['error'] is String) {
        return responseData['error'];
      }

      // Check for nested error object (like {"error": {"non_field_errors": ["Invalid otp"]}})
      if (responseData.containsKey('error') &&
          responseData['error'] is Map<String, dynamic>) {
        final errorObject = responseData['error'] as Map<String, dynamic>;

        // Handle non_field_errors specifically
        if (errorObject.containsKey('non_field_errors') &&
            errorObject['non_field_errors'] is List) {
          final nonFieldErrors = errorObject['non_field_errors'] as List;
          if (nonFieldErrors.isNotEmpty && nonFieldErrors.first is String) {
            return nonFieldErrors.first as String;
          }
        }

        // Handle other nested error structures
        List<String> nestedErrorMessages = [];
        errorObject.forEach((key, value) {
          if (value is List) {
            // Handle array of errors for a field
            for (var error in value) {
              if (error is String) {
                nestedErrorMessages.add(error);
              }
            }
          } else if (value is String) {
            // Handle single error message for a field
            nestedErrorMessages.add(value);
          }
        });

        if (nestedErrorMessages.isNotEmpty) {
          return nestedErrorMessages.join('\n');
        }
      }

      // Check for detail field
      if (responseData.containsKey('detail') &&
          responseData['detail'] is String) {
        return responseData['detail'];
      }

      // Check for message field
      if (responseData.containsKey('message') &&
          responseData['message'] is String) {
        return responseData['message'];
      }

      // Handle validation errors (like phone_number: ["error message"])
      List<String> errorMessages = [];
      responseData.forEach((key, value) {
        if (value is List) {
          // Handle array of errors for a field
          for (var error in value) {
            if (error is String) {
              errorMessages.add(error);
            }
          }
        } else if (value is String) {
          // Handle single error message for a field
          errorMessages.add(value);
        }
      });

      if (errorMessages.isNotEmpty) {
        return errorMessages.join('\n');
      }

      // If no specific error format found, return a generic message
      return 'Server error occurred';
    }

    return 'Server error occurred';
  }

  /// Handles unauthorized responses by attempting to refresh the token
  /// This method is called when a 401 response is received
  Future<void> _handleUnauthorizedResponse() async {
    try {
      log('NetworkAdapter: Received 401 response, attempting token refresh...');
      final refreshSuccess = await _tokenManager.refreshToken();
      if (!refreshSuccess) {
        log('NetworkAdapter: Token refresh failed after 401 response');
      }
    } catch (e) {
      log('NetworkAdapter: Error handling unauthorized response: $e');
    }
  }

  Options _dioOptions(
    String? accessToken,
    Map<String, String>? additionalHeaders,
    bool isRTL,
  ) {
    final headers = {
      if (accessToken != null)
        HttpHeaders.authorizationHeader: "Bearer $accessToken",

      HttpHeaders.acceptLanguageHeader: "ar",
    };
    if (additionalHeaders != null && additionalHeaders.isNotEmpty) {
      headers.addAll(additionalHeaders);
    }

    return Options(
      headers: headers,
      validateStatus: (status) => true,
      contentType: "application/json",
    );
  }
}
