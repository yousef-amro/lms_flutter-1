import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get/get.dart';
import 'package:lms_app/core/cache/local_storage_service.dart';
import 'package:lms_app/core/domain/utils/extensions.dart';
import 'package:lms_app/core/presentation/theme/color_manager.dart';
import 'package:lms_app/core/presentation/widgets/app_button.dart';

import '../../../../core/presentation/localization/localization_keys.dart';
import '../../../../core/presentation/widgets/fields/app_input_field.dart';
import '../auth_controller.dart';

class ResetPasswordScreen extends HookWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formKey = GlobalKey<FormState>();
    final passwordCtrl = useTextEditingController();
    final confirmPasswordCtrl = useTextEditingController();

    return GetBuilder(
      init: AuthController(
        repository: Get.find(),
        tokenManager: Get.find(),
        sessionManager: Get.find(),
        localStorage: LocalStorageService(),
      ),
      id: ResetPasswordScreen,
      builder: (controller) {
        return Scaffold(
          backgroundColor: Color.fromARGB(251, 255, 255, 255),
          appBar: AppBar(
            backgroundColor: theme.scaffoldBackgroundColor,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.of(context).pop();
                }
              },
              icon: Icon(Icons.arrow_back, color: ColorManager().black),
            ),
            actions: [
              IconButton(
                tooltip: 'Sign out',
                onPressed: () => controller.logout(),
                icon: Icon(Icons.logout, color: ColorManager().primary),
              ),
            ],
          ),
          body: Form(
            key: formKey,
            child: ListView(
              padding: 20.paddingHorizontal,
              children: [
                AppInputField(
                  controller: passwordCtrl,
                  hint: LocalizationKeys.enterYourNewPassword.tr,
                  title: LocalizationKeys.password.tr,
                  keyboardType: TextInputType.visiblePassword,
                  required: true,
                ),
                28.spaceY,
                AppInputField(
                  controller: confirmPasswordCtrl,
                  hint: LocalizationKeys.enterYourConfirmPassword.tr,
                  title: LocalizationKeys.confirmPassword.tr,
                  keyboardType: TextInputType.visiblePassword,
                  required: true,
                ),
                28.spaceY,
                AppButton.primary(
                  height: 60,
                  text: LocalizationKeys.continueWith.tr,
                  textStyle: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                    color: ColorManager().white,
                  ),
                  onPressed: () {
                    if (passwordCtrl.text.trim() !=
                        confirmPasswordCtrl.text.trim()) {
                      controller.showFailSnackbar(
                        text: LocalizationKeys.passwordsDoNotMatch.tr,
                      );
                      return;
                    }
                    if (formKey.currentState?.validate() ?? false) {
                      // controller.resetPassword(
                      //   password: passwordCtrl.text.trim(),
                      //   confirmPassword: confirmPasswordCtrl.text.trim(),
                      // );
                    }
                  },
                  isLoading: controller.authState == AuthState.loading,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
