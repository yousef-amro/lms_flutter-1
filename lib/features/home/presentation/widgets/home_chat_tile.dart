import 'package:flutter/material.dart';
import 'package:lms_app/core/presentation/theme/color_manager.dart';
import 'package:lms_app/core/presentation/theme/text_manager.dart';
import 'package:lms_app/features/home/presentation/models/home_chat_item.dart';

class HomeChatTile extends StatelessWidget {
  final HomeChatItem item;
  final VoidCallback? onTap;

  const HomeChatTile({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = ColorManager();

    final content = Container(
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
                    if (item.statusChip != null && item.statusColor != null) ...[
                      _StatusChip(text: item.statusChip!, color: item.statusColor!),
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
                    errorBuilder: (context, error, stackTrace) => placeholder,
                    loadingBuilder: (context, child, loadingProgress) {
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
              border: Border.all(color: colors.cardBackground, width: 2),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(999)),
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
