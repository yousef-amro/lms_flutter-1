import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lms_app/core/presentation/theme/color_manager.dart';

enum AlertType { success, fail, info }

mixin Alerts {
  Future<void> _showSnackbar({
    required AlertType alertType,
    required String text,
    String? subtitle,
    IconData? iconData,
    String? iconPath,
    int duration = 4,
  }) async {
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }
    Color iconColor = ColorManager().primary;
    Color textColor = ColorManager().textDark;
    final svgIcon = iconPath != null ? true : false;
    final theme = Theme.of(Get.context!);

    Get.showSnackbar(
      GetSnackBar(
        messageText: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 12,
          children: [
            if (iconPath != null)
              SvgPicture.asset(
                iconPath,
                colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                width: 18,
                height: 18,
              ),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Cairo',
                      color: textColor,
                      fontWeight: FontWeight.normal,
                    ),
                    textAlign: TextAlign.start,
                  ),
                  if (subtitle != null && subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Cairo',
                        color: textColor.withValues(alpha: 0.8),
                        fontWeight: FontWeight.normal,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        snackPosition: SnackPosition.TOP,
        icon: iconData != null && !svgIcon
            ? Icon(iconData, color: iconColor)
            : null,
        shouldIconPulse: false,
        backgroundColor: theme.colorScheme.surfaceContainer,
        borderRadius: 6,
        snackStyle: SnackStyle.FLOATING,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        padding: const EdgeInsets.all(12),
        duration: Duration(seconds: duration),
        boxShadows: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }

  void showSuccessSnackbar({
    required String text,
    String? subtitle,
    IconData? iconData,
    String? iconPath,
    int duration = 4,
  }) => _showSnackbar(
    alertType: AlertType.success,
    text: text,
    subtitle: subtitle,
    iconData: iconData,
    iconPath: iconPath,
    duration: duration,
  );

  void showFailSnackbar({
    required String text,
    String? subtitle,
    IconData? iconData,
    String? iconPath,
    int duration = 4,
  }) => _showSnackbar(
    alertType: AlertType.fail,
    text: text,
    subtitle: subtitle,
    iconData: iconData,
    iconPath: iconPath,
    duration: duration,
  );

  void showInfoSnackbar({
    required String text,
    required String subtitle,
    IconData? iconData,
    String? iconPath,
    int duration = 4,
  }) => _showSnackbar(
    alertType: AlertType.info,
    text: text,
    subtitle: subtitle,
    iconData: iconData,
    iconPath: iconPath,
    duration: duration,
  );
}
