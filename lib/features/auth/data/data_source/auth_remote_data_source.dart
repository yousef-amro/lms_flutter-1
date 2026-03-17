import 'package:dartz/dartz.dart';

import '../../../../core/data/networking/data/network_request.dart';
import '../../../../core/data/networking/data/network_response.dart';
import '../../../../core/data/networking/data/network_router.dart';
import '../../../../core/data/networking/network_adapter.dart';
import '../../../../core/domain/errors/failure.dart';
import '../../domain/models/auth_credentials.dart';
import '../../domain/models/refresh_token_model.dart';

abstract class AuthRemoteDataSourceAbstraction {
  Future<Either<Failure, RefreshTokenModel>> refreshToken(String refresh);
  Future<Either<Failure, AuthCredentials>> manualLogin(
    String username,
    String password,
  );
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
      isFormData: true,
      data: {'username': username, 'password': password},
    );

    final response = await _networkAdapter.request(request);
    if (response.status == NetworkResponseStatus.success) {
      return Right(AuthCredentials.fromJson(response.data));
    } else {
      return Left(response.failure!);
    }
  }
}
