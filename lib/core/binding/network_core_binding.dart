import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../cache/local_storage_service.dart';
import '../cache/secure_storage_service.dart';
import '../data/data_sources/core_data_remote_data_source.dart';
import '../data/networking/network_adapter.dart';
import '../services/session_manager_service.dart';
import '../services/token_manager_service.dart';

class NetworkCoreBinding extends Bindings {
  @override
  void dependencies() {
    // Register LocalStorageService as a permanent service
    // This service is needed globally throughout the app lifecycle
    Get.put<LocalStorageService>(LocalStorageService(), permanent: true);

    // Register SessionManagerService
    Get.put<SessionManagerService>(
      SessionManagerService(
        localStorage: LocalStorageService(),
        secureStorage: SecureStorageService(),
      ),
    );

    // Register TokenManagerService
    Get.put<TokenManagerService>(
      TokenManagerService(
        secureStorage: SecureStorageService(),
        networkAdapter: null, // Will be set after NetworkAdapter is created
        sessionManager: Get.find<SessionManagerService>(),
      ),
    );

    // Register NetworkAdapter
    final networkAdapter = NetworkAdapter(
      secureLocalStorage: SecureStorageService(),
      dio: Dio(),
      tokenManager: Get.find<TokenManagerService>(),
      isRTL: (Get.locale?.languageCode ?? 'ar') == 'ar',
    );
    Get.put<NetworkAdapterAbstraction>(networkAdapter);

    // Set the network adapter in TokenManagerService
    Get.find<TokenManagerService>().setNetworkAdapter(networkAdapter);

    // Register CoreDataRemoteDataSource
    Get.put<CoreDataRemoteDataSourceAbstraction>(
      CoreDataRemoteDataSource(networkAdapter),
      permanent: true,
    );
  }
}
