import '../../../domain/errors/failure.dart';

enum NetworkResponseStatus { success, failure }

class NetworkResponse {
  final NetworkResponseStatus status;
  final dynamic data;
  final Failure? failure;

  NetworkResponse({required this.status, this.data, this.failure});
}
