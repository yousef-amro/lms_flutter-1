import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/presentation/theme/color_manager.dart';
import '../../../core/presentation/theme/text_manager.dart';
import 'controllers/chat_controller.dart';

class ChatInboxScreen extends StatelessWidget {
  const ChatInboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = ColorManager();
    AppTypography.init();
    final controller = Get.find<ChatController>();

    final isArabic = Get.locale?.languageCode.toLowerCase() == 'ar';

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: colors.scaffoldBackground,
        appBar: AppBar(
          backgroundColor: colors.cardBackground,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              isArabic
                  ? Icons.arrow_back_ios_rounded
                  : Icons.arrow_forward_ios_rounded,
              size: 20,
              color: colors.textDark,
            ),
            onPressed: () => Get.back(),
          ),
          title: Text(
            'المحادثات المباشرة',
            style: TextStyle(
              fontFamily: AppFonts.ffShamelFamily,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: colors.textDark,
            ),
            textDirection: TextDirection.rtl,
          ),
          actions: [
            IconButton(
              tooltip: 'تحديث',
              onPressed: () => controller.loadCallCenterSessions(),
              icon: Icon(Icons.refresh, color: colors.textDark),
            ),
          ],
        ),
      body: Obx(() {
        final connected = controller.isConnected.value;
        final isLoading = controller.isLoadingCallCenterSessions.value;
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _ConnectionCard(connected: connected),
              const SizedBox(height: 10),
              _WsDebugCard(
                role: controller.role.value,
                userId: controller.userId.value,
                userName: controller.userName.value,
                recentTypes: controller.recentEventTypes,
              ),
              const SizedBox(height: 12),
              if (isLoading)
                LinearProgressIndicator(
                  minHeight: 3,
                  color: colors.primary,
                  backgroundColor: colors.divider.withValues(alpha: 0.35),
                ),
              const SizedBox(height: 12),
              Expanded(
                child: controller.assignedSessions.isEmpty &&
                        controller.incomingRequests.isEmpty &&
                        controller.callCenterSessions.isEmpty
                    ? Center(
                        child: Text(
                          'لا توجد طلبات محادثة حالياً',
                          style: AppTypography.bodyM.copyWith(
                            color: colors.textDark.withValues(alpha: 0.65),
                          ),
                        ),
                      )
                    : ListView(
                        children: [
                          if (controller.callCenterSessions.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(
                                'كل محادثات مركز الاتصال',
                                style: AppTypography.captionM.bold.copyWith(
                                  color: colors.textDark.withValues(alpha: 0.8),
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                            ...controller.callCenterSessions.map((item) {
                              final sessionId =
                                  item['session_id']?.toString() ?? '';
                              final peerName =
                                  item['peer_name']?.toString().trim();
                              final nodeTitle =
                                  item['node_title']?.toString() ?? '';
                              final peerImage = controller.getPeerImageForSession(
                                sessionId,
                                fallback: item,
                              );
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: colors.cardBackground,
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.03),
                                        blurRadius: 16,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    textDirection: TextDirection.rtl,
                                    children: [
                                      _SessionAvatar(imageUrl: peerImage),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              (peerName?.isNotEmpty == true)
                                                  ? peerName!
                                                  : 'محادثة',
                                              textAlign: TextAlign.right,
                                              style: AppTypography.bodyM.bold
                                                  .copyWith(
                                                color: colors.textDark,
                                              ),
                                            ),
                                            if (nodeTitle.isNotEmpty) ...[
                                              const SizedBox(height: 4),
                                              Text(
                                                nodeTitle,
                                                textAlign: TextAlign.right,
                                                style: AppTypography.captionM
                                                    .copyWith(
                                                  color: colors.textDark
                                                      .withValues(alpha: 0.6),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      FilledButton(
                                        onPressed: sessionId.isEmpty
                                            ? null
                                            : () => controller.openSession(
                                                  sessionId,
                                                  peerName: peerName,
                                                  peerImage: peerImage?.isNotEmpty == true ? peerImage : null,
                                                ),
                                        child: const Text('فتح'),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                            const SizedBox(height: 16),
                          ],
                          // Already accepted (persisted) chats — restored after restart
                          if (controller.assignedSessions.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(
                                'محادثاتك النشطة',
                                style: AppTypography.captionM.bold.copyWith(
                                  color: colors.textDark.withValues(alpha: 0.8),
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                            ...controller.assignedSessions.map((item) {
                              final sessionId =
                                  item['session_id'] ?? '';
                              final peerName =
                                  item['peer_name']?.isNotEmpty == true
                                      ? item['peer_name']!
                                      : 'محادثة';
                              final nodeTitle = item['node_title'] ?? '';
                              final peerImage = controller.getPeerImageForSession(
                                sessionId,
                                fallback: item,
                              );
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: colors.cardBackground,
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.03),
                                        blurRadius: 16,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    textDirection: TextDirection.rtl,
                                    children: [
                                      _SessionAvatar(imageUrl: peerImage),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              peerName,
                                              textAlign: TextAlign.right,
                                              style: AppTypography.bodyM.bold
                                                  .copyWith(
                                                color: colors.textDark,
                                              ),
                                            ),
                                            if (nodeTitle.isNotEmpty) ...[
                                              const SizedBox(height: 4),
                                              Text(
                                                nodeTitle,
                                                textAlign: TextAlign.right,
                                                style: AppTypography.captionM
                                                    .copyWith(
                                                  color: colors.textDark
                                                      .withValues(alpha: 0.6),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      FilledButton(
                                        onPressed: sessionId.isEmpty
                                            ? null
                                            : () => controller.openSession(
                                                  sessionId,
                                                  peerName: peerName,
                                                  peerImage: peerImage?.isNotEmpty == true ? peerImage : null,
                                                ),
                                        child: const Text('فتح'),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                            const SizedBox(height: 16),
                          ],
                          // Pending requests (new_chat_request)
                          if (controller.incomingRequests.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(
                                'طلبات جديدة',
                                style: AppTypography.captionM.bold.copyWith(
                                  color: colors.textDark.withValues(alpha: 0.8),
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                            ...controller.incomingRequests.map((item) {
                              final sessionId =
                                  item['session_id']?.toString() ?? '';
                              final student = item['student'];
                              final peerImage = controller.getPeerImageForSession(
                                sessionId,
                                fallback: item,
                              );
                              final studentName = student is Map
                                  ? (student['full_name']?.toString() ?? 'طالب')
                                  : 'طالب';
                              final nodeTitle =
                                  item['node_title']?.toString() ?? '';
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: colors.cardBackground,
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.03),
                                        blurRadius: 16,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    textDirection: TextDirection.rtl,
                                    children: [
                                      _SessionAvatar(imageUrl: peerImage),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              studentName,
                                              textAlign: TextAlign.right,
                                              style: AppTypography.bodyM.bold
                                                  .copyWith(
                                                color: colors.textDark,
                                              ),
                                            ),
                                            if (nodeTitle.isNotEmpty) ...[
                                              const SizedBox(height: 4),
                                              Text(
                                                nodeTitle,
                                                textAlign: TextAlign.right,
                                                style: AppTypography.captionM
                                                    .copyWith(
                                                  color: colors.textDark
                                                      .withValues(alpha: 0.6),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      FilledButton(
                                        onPressed: sessionId.isEmpty
                                            ? null
                                            : () async {
                                                await controller.acceptChat(
                                                  sessionId: sessionId,
                                                );
                                                controller.openSession(
                                                  sessionId,
                                                  peerName: studentName,
                                                  peerImage: peerImage?.isNotEmpty == true ? peerImage : null,
                                                );
                                              },
                                        child: const Text('قبول'),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ],
                        ],
                      ),
              ),
            ],
          ),
        );
      }),
    ),
    );
  }
}

class _ConnectionCard extends StatelessWidget {
  final bool connected;
  const _ConnectionCard({required this.connected});

  @override
  Widget build(BuildContext context) {
    final colors = ColorManager();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: connected ? colors.safe.withValues(alpha: 0.25) : colors.error,
          width: 1,
        ),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Icon(
            connected ? Icons.wifi : Icons.wifi_off,
            color: connected ? colors.safe : colors.error,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              connected ? 'متصل بالخادم' : 'غير متصل، جاري إعادة المحاولة…',
              textAlign: TextAlign.right,
              style: AppTypography.bodyS.copyWith(color: colors.textDark),
            ),
          ),
        ],
      ),
    );
  }
}

class _WsDebugCard extends StatelessWidget {
  final String? role;
  final String? userId;
  final String? userName;
  final List<String> recentTypes;
  const _WsDebugCard({
    required this.role,
    required this.userId,
    required this.userName,
    required this.recentTypes,
  });

  @override
  Widget build(BuildContext context) {
    final colors = ColorManager();
    final typesText = recentTypes.isEmpty ? '—' : recentTypes.take(6).join(' • ');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.primary.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'WS Debug',
            style: AppTypography.captionM.bold.copyWith(
              color: colors.textDark.withValues(alpha: 0.75),
            ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 6),
          Text(
            'role: ${role ?? "—"}',
            style: AppTypography.captionM.copyWith(
              color: colors.textDark.withValues(alpha: 0.75),
            ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 4),
          Text(
            'user: ${(userName ?? "—")} (${userId ?? "—"})',
            style: AppTypography.captionM.copyWith(
              color: colors.textDark.withValues(alpha: 0.75),
            ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 4),
          Text(
            'events: $typesText',
            style: AppTypography.captionM.copyWith(
              color: colors.textDark.withValues(alpha: 0.70),
            ),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }
}

class _SessionAvatar extends StatelessWidget {
  final String? imageUrl;

  const _SessionAvatar({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;
    final url = hasImage ? imageUrl!.trim() : null;
    const placeholder = CircleAvatar(
      backgroundColor: Color(0xFFE5E7EB),
      child: Icon(Icons.person_rounded, color: Color(0xFF6B7280)),
    );
    if (url == null) return placeholder;
    return ClipOval(
      child: SizedBox(
        width: 44,
        height: 44,
        child: Image.network(
          url,
          width: 44,
          height: 44,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => placeholder,
          loadingBuilder: (_, child, loadingProgress) =>
              loadingProgress == null ? child : placeholder,
        ),
      ),
    );
  }
}
