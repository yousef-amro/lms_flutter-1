import 'package:flutter/material.dart';
import 'package:lms_app/core/presentation/theme/color_manager.dart';
import 'package:lms_app/core/presentation/theme/text_manager.dart';

class HomeStatsSection extends StatelessWidget {
  final int waitingCount;
  final int activeCount;
  final int closedCount;
  final bool isLoading;

  const HomeStatsSection({
    super.key,
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
          textDirection: TextDirection.rtl,
          children: [
            Expanded(
              child: _StatCard(
                countText: activeCount.toString(),
                labelText: 'تم الرد عليه',
                icon: Icons.chat_bubble_outline,
                iconBg: const Color(0xFFE9FAF4),
                iconFg: const Color(0xFF1FA971),
                isLoading: isLoading,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                countText: waitingCount.toString(),
                labelText: 'قيد المتابعة',
                icon: Icons.assignment_outlined,
                iconBg: const Color(0xFFFFF3E0),
                iconFg: const Color(0xFFF59E0B),
                isLoading: isLoading,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: SizedBox(
            width: double.infinity,
            child: _StatCard(
              countText: closedCount.toString(),
              labelText: 'قد تم إغلاقه',
              icon: Icons.chat_bubble_outline,
              iconBg: const Color(0xFFFFEBEE),
              iconFg: const Color(0xFFEF4444),
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
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconFg, size: 18),
          ),
        ],
      ),
    );
  }
}
