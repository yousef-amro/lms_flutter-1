import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms_app/core/presentation/theme/color_manager.dart';
import 'package:lms_app/core/presentation/theme/text_manager.dart';
import 'package:lms_app/features/chat/presentation/controllers/chat_controller.dart';
import 'package:lms_app/features/home/presentation/models/home_chat_item.dart';
import 'package:lms_app/features/home/presentation/widgets/home_chat_tile.dart';

class HomeChatsList extends StatelessWidget {
  const HomeChatsList({super.key});

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        SizedBox(
          height: 240,
          child: Center(
            child: Text(
              'لا يوجد محادثات',
              style: AppTypography.bodyM.copyWith(
                color: ColorManager().textDark.withValues(alpha: 0.55),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ChatController>()) {
      return _buildEmptyState();
    }
    final controller = Get.find<ChatController>();
    return Obx(() {
      final fromApi = controller.callCenterSessions;
      final requests = controller.incomingRequests;
      final callCenterSessionsVersion = controller.callCenterSessionsUpdated.value;
      final isLoading = controller.isLoadingCallCenterSessions.value;

      final apiIds = <String>{};
      for (final s in fromApi) {
        final id = (s['session_id'] ?? s['id']?.toString() ?? '').toString().trim();
        if (id.isNotEmpty) apiIds.add(id);
      }
      // WebSocket may show a request before GET /call-center/sessions includes it.
      final pendingOnly = requests.where((r) {
        final id = r['session_id']?.toString().trim() ?? '';
        return id.isEmpty || !apiIds.contains(id);
      }).toList();

      final totalCount = pendingOnly.length + fromApi.length;
      if (totalCount == 0) {
        if (isLoading) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              SizedBox(
                height: 240,
                child: Center(
                  child: CircularProgressIndicator(color: ColorManager().primary),
                ),
              ),
            ],
          );
        }
        return _buildEmptyState();
      }
      return ListView.separated(
        key: ValueKey(
          '$callCenterSessionsVersion-${pendingOnly.length}-${fromApi.length}',
        ),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 24),
        itemCount: totalCount,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          if (index < pendingOnly.length) {
            final request = pendingOnly[index];
            final item = _requestToChatItem(controller, request);
            return HomeChatTile(
              item: item,
              onTap: () => _onChatTap(controller, request),
            );
          }
          final session = fromApi[index - pendingOnly.length];
          final item = _apiSessionToChatItem(controller, session);
          return HomeChatTile(
            item: item,
            onTap: () => _onApiSessionTap(controller, session),
          );
        },
      );
    });
  }

  HomeChatItem _apiSessionToChatItem(
    ChatController controller,
    Map<String, dynamic> session,
  ) {
    final sessionId = (session['session_id'] ?? session['id']?.toString() ?? '').trim();
    final peerName = session['peer_name']?.toString().trim();
    final name = peerName?.isNotEmpty == true ? peerName! : 'محادثة';
    final nodeTitle = session['node_title']?.toString().trim() ?? '';
    final message = nodeTitle.isNotEmpty ? nodeTitle : 'محادثة نشطة';
    final imageUrl = controller.getPeerImageForSession(sessionId, fallback: session);
    final status = session['status']?.toString().trim().toLowerCase() ?? '';
    final isClosed = status == 'closed';
    final colors = ColorManager();
    return HomeChatItem(
      name: name,
      message: message,
      timeText: '',
      dateText: '',
      isOnline: !isClosed,
      unreadCount: 0,
      statusChip: isClosed ? 'مغلقة' : null,
      statusColor: isClosed ? colors.error : null,
      hasDoubleCheck: false,
      imageUrl: imageUrl?.isNotEmpty == true ? imageUrl : null,
    );
  }

  HomeChatItem _requestToChatItem(
    ChatController controller,
    Map<String, dynamic> request,
  ) {
    final sessionId = (request['session_id']?.toString() ?? '').trim();
    final student = request['student'];
    final studentName = student is Map ? (student['full_name']?.toString() ?? 'طالب') : 'طالب';
    final imageUrl = controller.getPeerImageForSession(sessionId, fallback: request);
    final nodeTitle = request['node_title']?.toString() ?? 'طلب محادثة جديدة';
    final colors = ColorManager();
    return HomeChatItem(
      name: studentName,
      message: nodeTitle,
      timeText: '',
      dateText: '',
      isOnline: true,
      unreadCount: 1,
      statusChip: 'قبول',
      statusColor: colors.safe,
      hasDoubleCheck: false,
      imageUrl: imageUrl?.trim().isNotEmpty == true ? imageUrl!.trim() : null,
    );
  }

  void _onApiSessionTap(ChatController controller, Map<String, dynamic> session) {
    final sessionId = (session['session_id'] ?? session['id']?.toString() ?? '').trim();
    if (sessionId.isEmpty) return;

    final peerName = session['peer_name']?.toString().trim();
    final peerImage = controller.getPeerImageForSession(sessionId, fallback: session);
    controller.openSession(
      sessionId,
      peerName: peerName?.isNotEmpty == true ? peerName : null,
      peerImage: peerImage?.isNotEmpty == true ? peerImage : null,
    );
  }

  void _onChatTap(ChatController controller, Map<String, dynamic> request) {
    final sessionId = request['session_id']?.toString() ?? '';
    if (sessionId.isEmpty) return;
    final student = request['student'];
    final peerName = student is Map ? (student['full_name']?.toString() ?? '') : null;
    final peerImage = controller.getPeerImageForSession(sessionId, fallback: request);
    // Do not accept here — ChatSessionScreen asks first (نعم/لا).
    controller.openSession(
      sessionId,
      peerName: peerName?.trim().isNotEmpty == true ? peerName!.trim() : null,
      peerImage: peerImage?.trim().isNotEmpty == true ? peerImage!.trim() : null,
      loadMessages: false,
      requiresAcceptance: true,
    );
  }
}
