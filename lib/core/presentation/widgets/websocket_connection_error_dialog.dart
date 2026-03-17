import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms_app/core/domain/utils/extensions.dart';
import 'package:lms_app/core/presentation/theme/color_manager.dart';
import 'package:lms_app/core/presentation/theme/text_manager.dart';

class WebSocketConnectionErrorDialog extends StatelessWidget {
  const WebSocketConnectionErrorDialog({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = ColorManager();

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: colors.white,
            borderRadius: 12.radius,
            boxShadow: [
              BoxShadow(
                color: colors.black.withAlpha(50),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with gradient
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [colors.error, colors.error.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colors.white.withAlpha(50),
                        borderRadius: 8.radius,
                      ),
                      child: Icon(
                        Icons.wifi_off_rounded,
                        color: colors.white,
                        size: 28,
                      ),
                    ),
                    16.spaceX,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'فشل الاتصال',
                            style: AppTypography.headingS.bold.copyWith(
                              color: colors.white,
                            ),
                          ),
                          4.spaceY,
                          Text(
                            'خطأ في الاتصال المباشر',
                            style: AppTypography.captionM.copyWith(
                              color: colors.white.withAlpha(200),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Error message
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colors.error.withOpacity(0.05),
                        borderRadius: 8.radius,
                        border: Border.all(
                          color: colors.error.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            color: colors.error,
                            size: 20,
                          ),
                          12.spaceX,
                          Expanded(
                            child: Text(
                              'تعذر الاتصال بخادم البيانات المباشرة. حاولنا إعادة الاتصال عدة مرات ولم ننجح.',
                              style: AppTypography.captionM.copyWith(
                                color: colors.textDark,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    20.spaceY,

                    // Troubleshooting steps
                    _buildTroubleshootingStep(
                      colors: colors,
                      icon: Icons
                          .signal_wifi_statusbar_connected_no_internet_4_rounded,
                      text: 'تأكد من اتصالك بالإنترنت',
                    ),
                    8.spaceY,
                    _buildTroubleshootingStep(
                      colors: colors,
                      icon: Icons.cloud_queue_rounded,
                      text: 'تحقق من حالة الخادم',
                    ),
                    8.spaceY,
                    _buildTroubleshootingStep(
                      colors: colors,
                      icon: Icons.refresh_rounded,
                      text: 'أعد المحاولة مرة أخرى',
                    ),

                    24.spaceY,

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: _buildButton(
                            colors: colors,
                            text: 'إلغاء',
                            isPrimary: false,
                            onTap: () => Get.back(),
                          ),
                        ),
                        12.spaceX,
                        Expanded(
                          child: _buildButton(
                            colors: colors,
                            text: 'إعادة المحاولة',
                            isPrimary: true,
                            onTap: () {
                              Get.back();
                              onRetry();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTroubleshootingStep({
    required ColorManager colors,
    required IconData icon,
    required String text,
  }) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: colors.neutralDark.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
        ),
        12.spaceX,
        Icon(icon, size: 16, color: colors.neutralDark.withOpacity(0.5)),
        8.spaceX,
        Expanded(
          child: Text(
            text,
            style: AppTypography.captionM.copyWith(
              color: colors.neutralDark.withOpacity(0.7),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButton({
    required ColorManager colors,
    required String text,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isPrimary ? colors.primary : colors.white,
          borderRadius: 8.radius,
          border: Border.all(
            color: isPrimary
                ? colors.primary
                : colors.neutralDark.withOpacity(0.15),
            width: 1.5,
          ),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: colors.primary.withAlpha(60),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            text,
            style: AppTypography.bodyM.semiBold.copyWith(
              color: isPrimary ? colors.white : colors.neutralDark,
            ),
          ),
        ),
      ),
    );
  }
}
