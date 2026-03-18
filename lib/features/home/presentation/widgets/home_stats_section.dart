import 'package:flutter/material.dart';
import 'package:lms_app/core/presentation/theme/color_manager.dart';
import 'package:lms_app/core/presentation/theme/text_manager.dart';

class HomeStatsSection extends StatelessWidget {
  const HomeStatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                countText: '20',
                labelText: 'تم الرد عليه',
                icon: Icons.chat_bubble_outline,
                iconBg: Color(0xFFE9FAF4),
                iconFg: Color(0xFF1FA971),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: StatCard(
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
            child: StatCard(
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

class StatCard extends StatelessWidget {
  final String countText;
  final String labelText;
  final IconData icon;
  final Color iconBg;
  final Color iconFg;

  const StatCard({
    super.key,
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

