import 'package:get/get.dart';
import 'package:lms_app/core/domain/routing/app_routes.dart';
import 'package:lms_app/features/chat/presentation/controllers/chat_controller.dart';

class HomeController extends GetxController {
  void onSearch() {}

  void openLiveChat() {
    Get.toNamed(AppRoutes.chatInbox);
  }

  bool get hasChatController => Get.isRegistered<ChatController>();

  ChatController? get chatControllerOrNull =>
      hasChatController ? Get.find<ChatController>() : null;

  HomeChatItem assignedToChatItem(Map<String, String> session) {
    final name = session['peer_name']?.isNotEmpty == true
        ? session['peer_name']!
        : 'محادثة';
    final message = session['node_title']?.isNotEmpty == true
        ? session['node_title']!
        : 'محادثة نشطة';
    return HomeChatItem(
      name: name,
      message: message,
      timeText: '',
      dateText: '',
      isOnline: true,
      unreadCount: 0,
    );
  }

  HomeChatItem requestToChatItem(Map<String, dynamic> request) {
    final student = request['student'];
    final studentName = student is Map
        ? (student['full_name']?.toString() ?? 'طالب')
        : 'طالب';
    final nodeTitle =
        request['node_title']?.toString() ?? 'طلب محادثة جديدة';
    return HomeChatItem(
      name: studentName,
      message: nodeTitle,
      timeText: '',
      dateText: '',
      isOnline: true,
      unreadCount: 1,
    );
  }

  void onAssignedTap(ChatController controller, Map<String, String> session) {
    final sessionId = session['session_id'] ?? '';
    if (sessionId.isEmpty) return;
    final peerName = session['peer_name'];
    controller.openSession(sessionId, peerName: peerName);
  }

  void onChatTap(
    ChatController controller,
    Map<String, dynamic> request,
  ) {
    final sessionId = request['session_id']?.toString() ?? '';
    if (sessionId.isEmpty) return;
    final student = request['student'];
    final peerName = student is Map
        ? (student['full_name']?.toString() ?? '')
        : null;
    final peerImage = controller.getPeerImageForSession(
      sessionId,
      fallback: request,
    );
    controller.openSession(
      sessionId,
      peerName: peerName?.trim().isNotEmpty == true ? peerName!.trim() : null,
      peerImage: peerImage?.trim().isNotEmpty == true ? peerImage!.trim() : null,
      loadMessages: false,
      requiresAcceptance: true,
    );
  }
}

class HomeChatItem {
  final String name;
  final String message;
  final String timeText;
  final String dateText;
  final int? unreadCount;
  final bool isOnline;
  final String? statusChip;
  final color;
  final bool hasDoubleCheck;

  const HomeChatItem({
    required this.name,
    required this.message,
    required this.timeText,
    required this.dateText,
    required this.isOnline,
    this.unreadCount,
    this.statusChip,
    this.color,
    this.hasDoubleCheck = false,
  });
}

