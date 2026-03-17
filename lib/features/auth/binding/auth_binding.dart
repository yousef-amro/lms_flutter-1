import 'package:get/get.dart';
import 'package:lms_app/core/cache/local_storage_service.dart';

import '../../../core/cache/secure_storage_service.dart';
import '../../../core/services/session_manager_service.dart';
import '../../../core/services/token_manager_service.dart';
import '../data/data_source/auth_remote_data_source.dart';
import '../data/repository/auth_repo.dart';
import '../presentation/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthRemoteDataSourceAbstraction>(
      () => AuthRemoteDataSource(Get.find()),
    );

    Get.lazyPut<AuthRepositoryAbstraction>(
      () => AuthRepository(
        Get.find(),
        SecureStorageService(),
        LocalStorageService(),
      ),
    );

    Get.lazyPut<AuthController>(
      () => AuthController(
        repository: Get.find(),
        tokenManager: Get.find<TokenManagerService>(),
        sessionManager: Get.find<SessionManagerService>(),
        localStorage: LocalStorageService(),
      ),
    );
  }
}
