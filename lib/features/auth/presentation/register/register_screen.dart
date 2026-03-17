import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lms_app/core/domain/constants/png_manager.dart';
import 'package:lms_app/core/domain/constants/svg_manager.dart';
import 'package:lms_app/core/domain/routing/app_routes.dart';
import 'package:lms_app/core/presentation/localization/localization_keys.dart';
import 'package:lms_app/core/presentation/theme/color_manager.dart';

import '../auth_controller.dart';
import 'widgets/register_form_section.dart';
import 'widgets/register_header_section.dart';

class RegisterScreen extends HookWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final registerFormKey = useMemoized(() => GlobalKey<FormState>());
    final authController = Get.find<AuthController>();

    useEffect(() {
      authController.fetchRegisterOptions();
      return null;
    }, const []);

    return Scaffold(
      backgroundColor: ColorManager().screenBgLight,
      body: GetBuilder<AuthController>(
        init: authController,
        id: AuthController.registerScreenId,
        builder: (controller) {
          final contentWidth = controller.loginScreenWidth(context);
          final scale = controller.authScale(context);
          final isArabic = (Get.locale?.languageCode ?? '').toLowerCase() == 'ar';

          void goToLogin() {
            if (Get.previousRoute == AppRoutes.login) {
              Get.back();
              return;
            }
            Get.offNamed(AppRoutes.login);
          }

          void onBack() {
            if (Get.previousRoute.isNotEmpty) {
              Get.back();
              return;
            }
            Get.offNamed(AppRoutes.login);
          }

          return Directionality(
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            child: SafeArea(
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
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 34 * scale),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20 * scale),
                                onTap: onBack,
                                child: SizedBox(
                                  width: 18 * scale,
                                  height: 18 * scale,
                                  child: SvgPicture.asset(
                                    SvgManager().registerIconArrowLeft,
                                    colorFilter: ColorFilter.mode(
                                      ColorManager().hintGray,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          RegisterHeaderSection(
                            width: contentWidth,
                            scale: scale,
                            heroAsset: ImageManager().registerHero,
                            title: LocalizationKeys.createNewAccount.tr,
                            readyBanner: LocalizationKeys.readyBanner.tr,
                          ),
                          SizedBox(height: 10 * scale),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 56 * scale),
                            child: RegisterFormSection(
                              scale: scale,
                              formKey: registerFormKey,
                              fullNameController:
                                  controller.registerFullNameController,
                              phoneController: controller.registerPhoneController,
                              passwordController:
                                  controller.registerPasswordController,
                              confirmPasswordController:
                                  controller.registerConfirmPasswordController,
                              obscurePassword: controller.registerObscurePassword,
                              obscureConfirmPassword:
                                  controller.registerObscureConfirmPassword,
                              selectedGeneration: controller.selectedGeneration,
                              selectedCity: controller.selectedCity,
                              generationOptions: controller.generationOptions,
                              cityOptions: controller.cityOptions,
                              isLoading: controller.isLoading,
                              onTogglePasswordVisibility:
                                  controller.toggleRegisterPasswordVisibility,
                              onToggleConfirmPasswordVisibility:
                                  controller.toggleRegisterConfirmPasswordVisibility,
                              onGenerationChanged: controller.onGenerationChanged,
                              onCityChanged: controller.onCityChanged,
                              onRegister: () =>
                                  controller.submitRegister(registerFormKey),
                              onLogin: goToLogin,
                              phoneValidator: (value) =>
                                  controller.phoneNumberValidator(value ?? ''),
                              validator: (value) =>
                                  controller.emptyValidator(value ?? ''),
                              passwordValidator: (value) => controller
                                  .registerPasswordValidator(value ?? ''),
                              confirmPasswordValidator: (value) => controller
                                  .registerConfirmPasswordValidator(value ?? ''),
                            ),
                          ),
                          SizedBox(height: 18 * scale),
                        ],
                      ),
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

