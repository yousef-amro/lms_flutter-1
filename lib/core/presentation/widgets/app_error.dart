import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../localization/localization_keys.dart';
import 'app_button.dart';

class AppErrorScreen extends StatelessWidget {
  const AppErrorScreen({super.key, this.onAction, this.actionText});

  final VoidCallback? onAction;
  final String? actionText;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: AppErrorBody(onAction: onAction));
  }
}

class AppErrorBody extends StatelessWidget {
  const AppErrorBody({super.key, this.onAction, this.actionText});

  final VoidCallback? onAction;
  final String? actionText;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          LocalizationKeys.somethingWentWrong.tr,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        if (onAction != null) ...[
          const SizedBox(height: 40),
          AppButton.primary(
            text: actionText ?? LocalizationKeys.retry.tr,
            onPressed: onAction!,
          ),
        ],
      ],
    );
  }
}
