import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app_button.dart';
import 'app_loader.dart';

class AppDialog extends StatelessWidget {
  const AppDialog({
    super.key,
    required this.title,
    this.description,
    required this.actionText,
    this.cancelText,
    required this.onAction,
    this.onCancel,
    this.content,
    this.isLoading = false,
    this.dismissible = true,
  });

  final String title;
  final String? description;
  final String actionText;
  final String? cancelText;
  final VoidCallback onAction;
  final VoidCallback? onCancel;
  final Widget? content;
  final bool isLoading;
  final bool dismissible;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopScope(
      canPop: dismissible,
      child: Dialog(
        insetPadding: EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: theme.scaffoldBackgroundColor,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              if (description != null)
                Text(
                  description!,
                  style: theme.textTheme.labelMedium,
                  textAlign: TextAlign.center,
                ),
              if (content != null) ...[const SizedBox(height: 20), content!],
              const SizedBox(height: 20),
              isLoading
                  ? const AppLoader()
                  : Row(
                      children: [
                        if (cancelText != null) ...[
                          Expanded(
                            child: AppButton.secondary(
                              text: cancelText!,
                              height: 36,
                              onPressed: onCancel ?? Get.back,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: AppButton.primary(
                            text: actionText,
                            height: 36,
                            onPressed: onAction,
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
