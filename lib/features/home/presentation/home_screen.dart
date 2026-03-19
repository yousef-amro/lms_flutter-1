import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms_app/core/presentation/theme/color_manager.dart';
import 'package:lms_app/core/presentation/theme/text_manager.dart';
import 'package:lms_app/features/chat/presentation/controllers/chat_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final colors = ColorManager();
    AppTypography.init();
    final controllerAvailable = Get.isRegistered<ChatController>();
    final controller =
        controllerAvailable ? Get.find<ChatController>() : null;

    return Scaffold(
      backgroundColor: colors.scaffoldBackground,
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 8),
                _HomeTopBar(title: 'سجل المحادثات', onSearch: () {}),
                const SizedBox(height: 16),
                controller == null
                    ? const _StatsSection(
                        waitingCount: 0,
                        activeCount: 0,
                        closedCount: 0,
                        isLoading: false,
                      )
                    : Obx(
                        () => _StatsSection(
                          waitingCount: controller.callCenterWaitingCount.value,
                          activeCount: controller.callCenterActiveCount.value,
                          closedCount: controller.callCenterClosedCount.value,
                          isLoading:
                              controller.isLoadingCallCenterDashboard.value,
                        ),
                      ),
                const SizedBox(height: 14),
                const _FiltersRow(),
                const SizedBox(height: 10),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      if (!Get.isRegistered<ChatController>()) return;
                      await Get.find<ChatController>().refreshHome();
                    },
                    child: _ChatsList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChatsList extends StatelessWidget {
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
                color: ColorManager().textDark.withValues(
                  alpha: 0.55,
                ),
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
      final callCenterSessionsVersion =
          controller.callCenterSessionsUpdated.value;
      final isLoading = controller.isLoadingCallCenterSessions.value;

      final apiIds = <String>{};
      for (final s in fromApi) {
        final id = (s['session_id'] ?? s['id']?.toString() ?? '')
            .toString()
            .trim();
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
                  child: CircularProgressIndicator(
                    color: ColorManager().primary,
                  ),
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
        separatorBuilder: (context, index) =>
            const SizedBox(height: 8),
        itemBuilder: (context, index) {
          if (index < pendingOnly.length) {
            final request = pendingOnly[index];
            final item = _requestToChatItem(controller, request);
            return _ChatTile(
              item: item,
              onTap: () => _onChatTap(controller, request),
            );
          }
          final session = fromApi[index - pendingOnly.length];
          final item = _apiSessionToChatItem(controller, session);
          return _ChatTile(
            item: item,
            onTap: () => _onApiSessionTap(controller, session),
          );
        },
      );
    });
  }

  _ChatItem _apiSessionToChatItem(
    ChatController controller,
    Map<String, dynamic> session,
  ) {
    final sessionId =
        (session['session_id'] ?? session['id']?.toString() ?? '')
            .trim();
    final peerName = session['peer_name']?.toString().trim();
    final name = peerName?.isNotEmpty == true ? peerName! : 'محادثة';
    final nodeTitle = session['node_title']?.toString().trim() ?? '';
    final message = nodeTitle.isNotEmpty ? nodeTitle : 'محادثة نشطة';
    final imageUrl = controller.getPeerImageForSession(
      sessionId,
      fallback: session,
    );
    final status =
        session['status']?.toString().trim().toLowerCase() ?? '';
    final isClosed = status == 'closed';
    final colors = ColorManager();
    return _ChatItem(
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

  _ChatItem _requestToChatItem(
    ChatController controller,
    Map<String, dynamic> request,
  ) {
    final sessionId = (request['session_id']?.toString() ?? '')
        .trim();
    final student = request['student'];
    final studentName = student is Map
        ? (student['full_name']?.toString() ?? 'طالب')
        : 'طالب';
    final imageUrl = controller.getPeerImageForSession(
      sessionId,
      fallback: request,
    );
    final nodeTitle =
        request['node_title']?.toString() ?? 'طلب محادثة جديدة';
    final colors = ColorManager();
    return _ChatItem(
      name: studentName,
      message: nodeTitle,
      timeText: '',
      dateText: '',
      isOnline: true,
      unreadCount: 1,
      statusChip: 'قبول',
      statusColor: colors.safe,
      hasDoubleCheck: false,
      imageUrl: imageUrl?.trim().isNotEmpty == true
          ? imageUrl!.trim()
          : null,
    );
  }

  void _onApiSessionTap(
    ChatController controller,
    Map<String, dynamic> session,
  ) {
    final sessionId =
        (session['session_id'] ?? session['id']?.toString() ?? '')
            .trim();
    if (sessionId.isEmpty) return;

    final peerName = session['peer_name']?.toString().trim();
    final peerImage = controller.getPeerImageForSession(
      sessionId,
      fallback: session,
    );
    controller.openSession(
      sessionId,
      peerName: peerName?.isNotEmpty == true ? peerName : null,
      peerImage: peerImage?.isNotEmpty == true ? peerImage : null,
    );
  }

  void _onChatTap(
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
    // Do not accept here — ChatSessionScreen asks first (نعم/لا).
    controller.openSession(
      sessionId,
      peerName: peerName?.trim().isNotEmpty == true
          ? peerName!.trim()
          : null,
      peerImage: peerImage?.trim().isNotEmpty == true
          ? peerImage!.trim()
          : null,
      loadMessages: false,
      requiresAcceptance: true,
    );
  }
}

class _HomeTopBar extends StatelessWidget {
  final String title;
  final VoidCallback onSearch;

  const _HomeTopBar({required this.title, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    final colors = ColorManager();

    return Row(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: onSearch,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search,
                color: colors.primary,
                size: 20,
              ),
            ),
          ),
        ),
        const Spacer(),
        Text(
          title,
          textAlign: TextAlign.right,
          style: AppTypography.subheadingM.copyWith(
            color: colors.textDark,
          ),
        ),
      ],
    );
  }
}

class _StatsSection extends StatelessWidget {
  final int waitingCount;
  final int activeCount;
  final int closedCount;
  final bool isLoading;

  const _StatsSection({
    required this.waitingCount,
    required this.activeCount,
    required this.closedCount,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                countText: activeCount.toString(),
                labelText: 'تم الرد عليه',
                icon: Icons.chat_bubble_outline,
                iconBg: Color(0xFFE9FAF4),
                iconFg: Color(0xFF1FA971),
                isLoading: isLoading,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                countText: waitingCount.toString(),
                labelText: 'قيد المتابعة',
                icon: Icons.assignment_outlined,
                iconBg: Color(0xFFFFF3E0),
                iconFg: Color(0xFFF59E0B),
                isLoading: isLoading,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: SizedBox(
            width: 190,
            child: _StatCard(
              countText: closedCount.toString(),
              labelText: 'قد تم إغلاقه',
              icon: Icons.chat_bubble_outline,
              iconBg: Color(0xFFFFEBEE),
              iconFg: Color(0xFFEF4444),
              isLoading: isLoading,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String countText;
  final String labelText;
  final IconData icon;
  final Color iconBg;
  final Color iconFg;
  final bool isLoading;

  const _StatCard({
    required this.countText,
    required this.labelText,
    required this.icon,
    required this.iconBg,
    required this.iconFg,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = ColorManager();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (isLoading)
                  SizedBox(
                    height: 22,
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: iconFg,
                      ),
                    ),
                  )
                else
                  Text(
                    '$countText طلب',
                    textAlign: TextAlign.right,
                    style: AppTypography.bodyM.bold.copyWith(
                      color: colors.textDark,
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  labelText,
                  textAlign: TextAlign.right,
                  style: AppTypography.captionMCairo.copyWith(
                    color: colors.textDark.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconFg, size: 18),
          ),
        ],
      ),
    );
  }
}

class _FiltersRow extends StatelessWidget {
  const _FiltersRow();

  @override
  Widget build(BuildContext context) {
    final colors = ColorManager();

    return Row(
      children: [
        TextButton.icon(
          onPressed: () {},
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF1FA971),
            padding: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 8,
            ),
          ),
          icon: const Icon(Icons.tune, size: 18),
          label: Text(
            'فرز حسب',
            style: AppTypography.bodyS.medium.copyWith(
              color: const Color(0xFF1FA971),
            ),
          ),
        ),
        const Spacer(),
        Row(
          children: [
            Icon(Icons.swap_horiz, size: 16, color: colors.primary),
            const SizedBox(width: 6),
            Text(
              'المحادثات لدي',
              style: AppTypography.bodyS.medium.copyWith(
                color: colors.textDark,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ChatItem {
  final String name;
  final String message;
  final String timeText;
  final String dateText;
  final int? unreadCount;
  final bool isOnline;
  final String? statusChip;
  final Color? statusColor;
  final bool hasDoubleCheck;
  final String? imageUrl;

  const _ChatItem({
    required this.name,
    required this.message,
    required this.timeText,
    required this.dateText,
    required this.isOnline,
    this.unreadCount,
    this.statusChip,
    this.statusColor,
    this.hasDoubleCheck = false,
    this.imageUrl,
  });
}

class _ChatTile extends StatelessWidget {
  final _ChatItem item;
  final VoidCallback? onTap;

  const _ChatTile({required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = ColorManager();

    final content = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          _Avatar(isOnline: item.isOnline, imageUrl: item.imageUrl),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    if (item.statusChip != null &&
                        item.statusColor != null) ...[
                      _StatusChip(
                        text: item.statusChip!,
                        color: item.statusColor!,
                      ),
                      const SizedBox(width: 8),
                    ],
                    const Spacer(),
                    Text(
                      item.name,
                      style: AppTypography.bodyM.bold.copyWith(
                        color: colors.textDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (item.hasDoubleCheck) ...[
                      Icon(
                        Icons.done_all,
                        size: 16,
                        color: colors.primary.withValues(alpha: 0.8),
                      ),
                      const SizedBox(width: 4),
                    ],
                    Expanded(
                      child: Text(
                        item.message,
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodyS.copyWith(
                          color: colors.textDark.withValues(
                            alpha: 0.65,
                          ),
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    if (item.timeText.isNotEmpty) ...[
                      Text(
                        item.timeText,
                        style: AppTypography.captionM.copyWith(
                          color: colors.textDark.withValues(
                            alpha: 0.50,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Text(
                      item.dateText,
                      style: AppTypography.captionM.copyWith(
                        color: colors.textDark.withValues(
                          alpha: 0.50,
                        ),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: content,
        ),
      );
    }
    return content;
  }
}

class _Avatar extends StatelessWidget {
  final bool isOnline;
  final String? imageUrl;
  const _Avatar({required this.isOnline, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final colors = ColorManager();
    final hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;
    final url = hasImage ? imageUrl!.trim() : null;
    final placeholder = Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFE5E7EB),
      ),
      child: const Icon(Icons.person, color: Color(0xFF6B7280)),
    );
    return Stack(
      clipBehavior: Clip.none,
      children: [
        SizedBox(
          width: 44,
          height: 44,
          child: ClipOval(
            child: hasImage && url != null
                ? Image.network(
                    url,
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        placeholder,
                    loadingBuilder:
                        (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return placeholder;
                        },
                  )
                : placeholder,
          ),
        ),
        Positioned(
          right: -1,
          bottom: -1,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: isOnline ? colors.safe : const Color(0xFF9CA3AF),
              shape: BoxShape.circle,
              border: Border.all(
                color: colors.cardBackground,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String text;
  final Color color;
  const _StatusChip({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.lock_outline,
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: AppTypography.captionMCairo.copyWith(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
