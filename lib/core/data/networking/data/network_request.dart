import 'package:dio/dio.dart';

import 'network_router.dart';

enum RequestType { get, post, put, patch, delete, download }

class NetworkRequest {
  final NetworkRouter route;
  final String? urlIdentifier;
  final RequestType requestType;
  final bool isAuthorizationRequired;
  final bool isAuthorizationResetPassword;
  final List<MapEntry<String, MultipartFile>>? files;
  final Map<String, dynamic>? parameters;
  final Map<String, dynamic>? data;
  final Map<String, String>? additionalHeaders;
  final bool isFormData;

  NetworkRequest({
    required this.requestType,
    required this.route,
    this.parameters,
    this.files,
    this.data,
    this.additionalHeaders,
    this.urlIdentifier,
    this.isAuthorizationRequired = false,
    this.isAuthorizationResetPassword = false,
    this.isFormData = false,
  }) : assert(
         !isFormData || data != null,
         '"data" must be non null if "isFormData" is true',
       );
}
