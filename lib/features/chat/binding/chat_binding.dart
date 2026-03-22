import 'package:get/get.dart';

import '../../../core/cache/secure_storage_service.dart';
import '../../../core/data/networking/network_adapter.dart';
import '../../../core/services/chat_websocket_service.dart';
import '../../../core/services/token_manager_service.dart';
import '../presentation/controllers/chat_controller.dart';

class ChatBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ChatWebSocketService>()) {
      Get.put<ChatWebSocketService>(
        ChatWebSocketService(
          secureStorage: SecureStorageService(),
          tokenManager: Get.find<TokenManagerService>(),
        ),
        permanent: true,
      );
    }

    if (!Get.isRegistered<ChatController>()) {
      Get.put<ChatController>(
        ChatController(
          ws: Get.find<ChatWebSocketService>(),
          network: Get.find<NetworkAdapterAbstraction>(),
        ),
        permanent: true,
      );
    }
  }
}

