import 'package:get/get.dart';
import 'package:lms_app/core/cache/secure_storage_service.dart';

import '../data/data_source/splash_remote_data_source.dart';
import '../data/repository/splash_repo.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashRemoteDataSourceAbstraction>(
      () => SplashRemoteDataSource(networkInterceptor: Get.find()),
    );

    Get.lazyPut<SplashRepositoryAbstraction>(
      () => SplashRepository(
        secureStorageService: SecureStorageService(),
        remoteDataSource: Get.find(),
      ),
    );
  }
}
