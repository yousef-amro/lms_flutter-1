import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms_app/core/presentation/theme/text_manager.dart';

import '../localization/localization_keys.dart';
import '../theme/color_manager.dart';
import 'app_loader.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isPrimary;
  final String? icon;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? textColor;
  final bool enabled;
  final bool isLoading;
  final TextStyle? textStyle;
  final double? height;
  final double? loadingProgress;
  final double? loadingDimensions;
  final bool fitWidth;
  final double? width;
  final bool isProcessing;
  final Widget? loadingSuffix;
  final Widget? child;

  const AppButton.primary({
    super.key,
    required this.text,
    required this.onPressed,
    this.isPrimary = true,
    this.borderColor,
    this.textColor,
    this.icon,
    this.backgroundColor,
    this.loadingProgress,
    this.loadingDimensions,
    this.isLoading = false,
    this.enabled = true,
    this.fitWidth = true,
    this.textStyle,
    this.width,
    this.height,
    this.isProcessing = false,
    this.loadingSuffix,
    this.child,
  });

  const AppButton.secondary({
    super.key,
    required this.text,
    required this.onPressed,
    this.borderColor,
    this.textColor,
    this.isPrimary = false,
    this.icon,
    this.loadingProgress,
    this.loadingDimensions,
    this.backgroundColor,
    this.isLoading = false,
    this.enabled = true,
    this.fitWidth = true,
    this.textStyle,
    this.height,
    this.width,
    this.isProcessing = false,
    this.loadingSuffix,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor =
        this.backgroundColor ??
        (isPrimary ? theme.colorScheme.primary : Colors.transparent);
    return SizedBox(
      height: height ?? 50,
      width: width,
      child: FilledButton(
        onPressed: isLoading || !enabled || isProcessing ? null : onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          backgroundColor: this.backgroundColor ?? backgroundColor,
          disabledBackgroundColor: backgroundColor.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
            side: isPrimary && borderColor == null
                ? BorderSide.none
                : BorderSide(
                    color: (borderColor ?? theme.colorScheme.primary)
                        .withValues(alpha: enabled ? 1 : 0),
                    width: 1.4,
                  ),
          ),
          minimumSize: fitWidth ? Size.fromHeight(height ?? 50) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading || isProcessing)
              Row(
                children: [
                  AppLoader(
                    value: loadingProgress == 0 ? null : loadingProgress,
                    size: loadingDimensions == null
                        ? null
                        : Size(loadingDimensions!, loadingDimensions!),
                  ),
                  if (loadingSuffix != null && !isProcessing)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(start: 12),
                      child: loadingSuffix!,
                    ),
                ],
              ),
            if (isProcessing) const SizedBox(width: 12),
            if (!isLoading)
              Text(
                isProcessing ? LocalizationKeys.processing.tr : text,
                textAlign: TextAlign.center,
                style: (textStyle ?? AppTypography.subheadingM.bold).copyWith(
                  color:
                      (isLoading || isProcessing
                              ? theme.colorScheme.onSurface
                              : textColor ??
                                    textStyle?.color ??
                                    (isPrimary
                                        ? ColorManager().white
                                        : theme.colorScheme.primary))
                          .withValues(alpha: enabled ? 1 : 0.5),
                ),
              ),
            if (child != null) ...[Spacer(), child!],
          ],
        ),
      ),
    );
  }
}
