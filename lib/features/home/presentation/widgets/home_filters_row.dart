import 'package:flutter/material.dart';
import 'package:lms_app/core/presentation/theme/color_manager.dart';
import 'package:lms_app/core/presentation/theme/text_manager.dart';

class HomeFiltersRow extends StatelessWidget {
  const HomeFiltersRow({super.key});

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
          textDirection: TextDirection.rtl,
          children: [
            Icon(Icons.swap_horiz, size: 16, color: colors.primary),
            const SizedBox(width: 6),
            Text(
              'المحادثات لدي',
              style: AppTypography.bodyS.medium.copyWith(color: colors.textDark),
            ),
          ],
        ),
      ],
    );
  }
}
