import 'package:flutter/material.dart';
import 'package:lms_app/core/presentation/theme/color_manager.dart';
import 'package:lms_app/core/presentation/theme/text_manager.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = ColorManager();
    AppTypography.init();

    return Scaffold(
      backgroundColor: colors.scaffoldBackground,
      body: SafeArea(
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
                child: ListView.separated(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemBuilder: (context, index) {
                    final items = _demoChats();
                    final item = items[index];
                    return _ChatTile(item: item);
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemCount: _demoChats().length,
                ),
              ),
            ],
          ),
        ),
      ),
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
              child: Icon(Icons.search, color: colors.primary, size: 20),
            ),
          ),
        ),
        const Spacer(),
        Text(
          title,
          textAlign: TextAlign.right,
          style: AppTypography.subheadingM.copyWith(color: colors.textDark),
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
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
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
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

List<_ChatItem> _demoChats() {
  return const [
    _ChatItem(
      name: 'د. عبد الرحيم صافي',
      message: 'السلام عليكم يحب عليك ...',
      timeText: '10:00 PM',
      dateText: '22 أبريل 2026',
      unreadCount: 3,
      isOnline: true,
    ),
    _ChatItem(
      name: 'د. عبد الرحيم صافي',
      message: 'السلام عليكم يحب عليك ...',
      timeText: '',
      dateText: '22 أبريل 2026',
      isOnline: true,
      hasDoubleCheck: true,
    ),
    _ChatItem(
      name: 'د. عبد الرحيم صافي',
      message: 'السلام عليكم يحب عليك ...',
      timeText: '',
      dateText: '22 أبريل 2026',
      isOnline: false,
      statusChip: 'مغلقه',
      statusColor: Color(0xFFEF4444),
      hasDoubleCheck: true,
    ),
    _ChatItem(
      name: 'د. عبد الرحيم صافي',
      message: 'السلام عليكم يحب عليك ...',
      timeText: '10:00 PM',
      dateText: '22 أبريل 2026',
      unreadCount: 3,
      isOnline: false,
    ),
  ];
}

class _ChatTile extends StatelessWidget {
  final _ChatItem item;
  const _ChatTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final colors = ColorManager();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
        children: [
          _Avatar(isOnline: item.isOnline),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    if (item.unreadCount != null) ...[
                      _UnreadBadge(count: item.unreadCount!),
                      const SizedBox(width: 8),
                    ],
                    if (item.statusChip != null && item.statusColor != null) ...[
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
                          color: colors.textDark.withValues(alpha: 0.65),
                        ),
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
                          color: colors.textDark.withValues(alpha: 0.50),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Text(
                      item.dateText,
                      style: AppTypography.captionM.copyWith(
                        color: colors.textDark.withValues(alpha: 0.50),
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
              border: Border.all(color: colors.cardBackground, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

class _UnreadBadge extends StatelessWidget {
  final int count;
  const _UnreadBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$count',
        style: AppTypography.captionM.bold.copyWith(color: Colors.white),
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.lock_outline, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            text,
            style: AppTypography.captionMCairo.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

