import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get/get.dart';
import 'package:lms_app/core/domain/constants/png_manager.dart';
import 'package:lms_app/core/domain/routing/app_routes.dart';
import 'package:lms_app/core/presentation/localization/localization_keys.dart';
import 'package:lms_app/core/presentation/theme/color_manager.dart';

import '../auth_controller.dart';
import 'widgets/login_form_section.dart';
import 'widgets/login_header_section.dart';

class LoginScreen extends HookWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loginFormKey = useMemoized(() => GlobalKey<FormState>());

    return Scaffold(
      backgroundColor: ColorManager().white,
      body: GetBuilder<AuthController>(
        init: Get.find<AuthController>(),
        id: AuthController.loginScreenId,
        builder: (controller) {
          final contentWidth = controller.loginScreenWidth(context);
          final scale = controller.authScale(context);

          return SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: controller.loginContentMinHeight(context),
                ),
                child: Center(
                  child: SizedBox(
                    width: contentWidth,
                    child: Column(
                      children: [
                        SizedBox(height: 20 * scale),
                        LoginHeaderSection(
                          width: contentWidth,
                          scale: scale,
                          heroAsset: ImageManager().loginHero,
                          title: LocalizationKeys.loginTitle.tr,
                        ),
                        SizedBox(height: 28 * scale),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 28 * scale),
                          child: LoginFormSection(
                            scale: scale,
                            formKey: loginFormKey,
                            phoneController: controller.phoneController,
                            passwordController: controller.passwordController,
                            obscurePassword: controller.obscurePassword,
                            isLoading: controller.isLoading,
                            onTogglePasswordVisibility:
                                controller.togglePasswordVisibility,
                            onLogin: () => controller.submitLogin(loginFormKey),
                            onCreateAccount: () =>
                                Get.toNamed(AppRoutes.register),
                            phoneValidator: (value) =>
                                controller.phoneNumberValidator(value ?? ''),
                            passwordValidator: (value) =>
                                controller.emptyValidator(value ?? ''),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
