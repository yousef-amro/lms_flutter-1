import 'package:dartz/dartz.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../core/cache/secure_storage_service.dart';
import '../../../../core/domain/errors/failure.dart';
import '../../domain/models/app_version.dart';
import '../data_source/splash_remote_data_source.dart';

abstract class SplashRepositoryAbstraction {
  Future<Either<Failure, AppVersion>> checkAvailableUpdate(
    PackageInfo packageInfo,
  );

  Future<String> fetchAccessToken();
}

class SplashRepository implements SplashRepositoryAbstraction {
  final SplashRemoteDataSourceAbstraction _remoteDataSource;
  final SecureStorageService _secureStorageService;

  SplashRepository({
    required SplashRemoteDataSourceAbstraction remoteDataSource,
    required SecureStorageService secureStorageService,
  }) : _remoteDataSource = remoteDataSource,
       _secureStorageService = secureStorageService;

  @override
  Future<Either<Failure, AppVersion>> checkAvailableUpdate(
    PackageInfo packageInfo,
  ) async => await _remoteDataSource.checkAvailableUpdates(packageInfo);

  @override
  Future<String> fetchAccessToken() async {
    return await _secureStorageService.fetchAccessToken() ?? "";
  }
}
