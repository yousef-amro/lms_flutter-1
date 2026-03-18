import 'package:flutter/material.dart';
import 'package:lms_app/core/presentation/theme/color_manager.dart';
import 'package:lms_app/core/presentation/theme/text_manager.dart';

class HomeTopBar extends StatelessWidget {
  final String title;
  final VoidCallback onSearch;
  final VoidCallback onOpenLiveChat;

  const HomeTopBar({
    super.key,
    required this.title,
    required this.onSearch,
    required this.onOpenLiveChat,
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
            onTap: onOpenLiveChat,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chat_bubble_outline,
                color: colors.primary,
                size: 20,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
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

