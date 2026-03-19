import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms_app/core/presentation/theme/color_manager.dart';
import 'package:lms_app/core/presentation/theme/text_manager.dart';

import '../../../../core/services/session_manager_service.dart';

class HomeTopBar extends StatelessWidget {
  final String title;
  final VoidCallback onSearch;

  const HomeTopBar({super.key, required this.title, required this.onSearch});

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
        const SizedBox(width: 12),
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () {
              Get.dialog(
                AlertDialog(
                  title: const Text('هل أنت متأكد؟'),
                  content: const Text('هل تريد تسجيل الخروج الآن؟'),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back<void>(),
                      child: const Text('إلغاء'),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.back<void>();
                        Get.find<SessionManagerService>().handleUserLogout(
                          showMessage: true,
                        );
                      },
                      child: const Text('تسجيل الخروج'),
                    ),
                  ],
                ),
              );
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.logout, color: colors.primary, size: 20),
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
