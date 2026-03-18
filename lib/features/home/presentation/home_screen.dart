import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms_app/core/presentation/theme/color_manager.dart';
import 'package:lms_app/core/presentation/theme/text_manager.dart';
import 'package:lms_app/features/chat/presentation/controllers/chat_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = ColorManager();
    AppTypography.init();

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
                _HomeTopBar(
                  title: 'سجل المحادثات',
                  onSearch: () {},
                ),
                const SizedBox(height: 16),
                const _StatsSection(),
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
      final assigned = controller.assignedSessions;
      final requests = controller.incomingRequests;
      final totalCount = assigned.length + requests.length;
      if (totalCount == 0) {
        return _buildEmptyState();
      }
      return ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 24),
        itemCount: totalCount,
        separatorBuilder: (context, index) =>
            const SizedBox(height: 8),
        itemBuilder: (context, index) {
          // Always show pending/incoming requests at the top.
          if (index < requests.length) {
            final request = requests[index];
            final item = _requestToChatItem(request);
            return _ChatTile(
              item: item,
              onTap: () => _onChatTap(controller, request),
            );
          }
          final session = assigned[index - requests.length];
          final item = _assignedToChatItem(session);
          return _ChatTile(
            item: item,
            onTap: () => _onAssignedTap(controller, session),
          );
        },
      );
    });
  }

  _ChatItem _assignedToChatItem(Map<String, String> session) {
    final name = session['peer_name']?.isNotEmpty == true
        ? session['peer_name']!
        : 'محادثة';
    final message = session['node_title']?.isNotEmpty == true
        ? session['node_title']!
        : 'محادثة نشطة';
    return _ChatItem(
      name: name,
      message: message,
      timeText: '',
      dateText: '',
      isOnline: true,
      unreadCount: 0,
      statusChip: null,
      statusColor: null,
      hasDoubleCheck: false,
    );
  }

  _ChatItem _requestToChatItem(Map<String, dynamic> request) {
    final student = request['student'];
    final studentName = student is Map
        ? (student['full_name']?.toString() ?? 'طالب')
        : 'طالب';
    final nodeTitle =
        request['node_title']?.toString() ?? 'طلب محادثة جديدة';
    return _ChatItem(
      name: studentName,
      message: nodeTitle,
      timeText: '',
      dateText: '',
      isOnline: true,
      unreadCount: 1,
      statusChip: 'قبول',
      statusColor: ColorManager().primary,
      hasDoubleCheck: false,
    );
  }

  void _onAssignedTap(
    ChatController controller,
    Map<String, String> session,
  ) {
    final sessionId = session['session_id'] ?? '';
    if (sessionId.isEmpty) return;
    final peerName = session['peer_name'];
    controller.openSession(sessionId, peerName: peerName);
  }

  Future<void> _onChatTap(
    ChatController controller,
    Map<String, dynamic> request,
  ) async {
    final sessionId = request['session_id']?.toString() ?? '';
    if (sessionId.isEmpty) return;
    final student = request['student'];
    final peerName = student is Map
        ? (student['full_name']?.toString() ?? '')
        : null;
    await controller.acceptChat(sessionId: sessionId);
    controller.openSession(sessionId, peerName: peerName);
  }
}

class _HomeTopBar extends StatelessWidget {
  final String title;
  final VoidCallback onSearch;

  const _HomeTopBar({
    required this.title,
    required this.onSearch,
  });

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
  const _StatsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                countText: '20',
                labelText: 'تم الرد عليه',
                icon: Icons.chat_bubble_outline,
                iconBg: Color(0xFFE9FAF4),
                iconFg: Color(0xFF1FA971),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                countText: '13',
                labelText: 'قيد المتابعة',
                icon: Icons.assignment_outlined,
                iconBg: Color(0xFFFFF3E0),
                iconFg: Color(0xFFF59E0B),
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
              countText: '20',
              labelText: 'قد تم إغلاقه',
              icon: Icons.chat_bubble_outline,
              iconBg: Color(0xFFFFEBEE),
              iconFg: Color(0xFFEF4444),
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

  const _StatCard({
    required this.countText,
    required this.labelText,
    required this.icon,
    required this.iconBg,
    required this.iconFg,
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
          _Avatar(isOnline: item.isOnline),
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
  const _Avatar({required this.isOnline});

  @override
  Widget build(BuildContext context) {
    final colors = ColorManager();
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFE5E7EB),
          ),
          child: const Icon(Icons.person, color: Color(0xFF6B7280)),
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
