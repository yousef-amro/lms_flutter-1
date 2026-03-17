import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../core/data/networking/data/network_request.dart';
import '../../../../core/data/networking/data/network_response.dart';
import '../../../../core/data/networking/data/network_router.dart';
import '../../../../core/data/networking/network_adapter.dart';
import '../../../../core/domain/errors/failure.dart';
import '../../domain/models/app_version.dart';

abstract class SplashRemoteDataSourceAbstraction {
  Future<Either<Failure, AppVersion>> checkAvailableUpdates(
    PackageInfo packageInfo,
  );
}

class SplashRemoteDataSource implements SplashRemoteDataSourceAbstraction {
  final NetworkAdapterAbstraction _networkAdapter;

  SplashRemoteDataSource({
    required NetworkAdapterAbstraction networkInterceptor,
  }) : _networkAdapter = networkInterceptor;

  @override
  Future<Either<Failure, AppVersion>> checkAvailableUpdates(
    PackageInfo packageInfo,
  ) async {
    final response = await _networkAdapter.request(
      NetworkRequest(
        requestType: RequestType.get,
        route: NetworkRouter.checkUpdate,
        isAuthorizationRequired: false,
        parameters: {
          'platform': Platform.isIOS ? 'ios' : 'android',
          'version_number': packageInfo.buildNumber,
        },
      ),
    );

    switch (response.status) {
      case NetworkResponseStatus.success:
        return Right(AppVersion.fromJson(response.data));
      case NetworkResponseStatus.failure:
        return Left(response.failure!);
    }
  }
}
