import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lms_app/core/cache/local_storage_service.dart';
import 'package:lms_app/core/presentation/localization/localization_keys.dart';
import 'package:lms_app/core/presentation/theme/color_manager.dart';
import 'package:lms_app/core/presentation/theme/text_manager.dart';
import 'package:lms_app/core/presentation/widgets/app_button.dart';
import 'package:lms_app/core/presentation/widgets/fields/app_input_field.dart';

import '../auth_controller.dart';

class LoginScreen extends HookWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = ColorManager();
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final usernameController = useTextEditingController();
    final passwordController = useTextEditingController();

    // Initialize typography
    AppTypography.init();

    // Animation
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 800),
    );

    useEffect(() {
      animationController.forward();
      return null;
    }, []);

    final fadeAnimation = useAnimation(
      CurvedAnimation(parent: animationController, curve: Curves.easeOut),
    );

    return Scaffold(
      backgroundColor: colors.scaffoldBackground,
      body: GetBuilder<AuthController>(
        init: AuthController(
          repository: Get.find(),
          tokenManager: Get.find(),
          sessionManager: Get.find(),
          localStorage: LocalStorageService(),
        ),
        id: LoginScreen,
        builder: (controller) {
          return SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      Opacity(
                        opacity: fadeAnimation,
                        child: Column(
                          children: [
                            const SizedBox(height: 36),

                            // Logo Container
                            const SizedBox(height: 28),

                            // Title
                            Text(
                              LocalizationKeys.soundMonitor.tr,
                              style: AppTypography.headingM.copyWith(
                                color: colors.textDark,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              LocalizationKeys.hospitalNoiseTracking.tr,
                              style: AppTypography.bodyS.medium.copyWith(
                                color: colors.neutralDark.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 36),

                      // Form Section
                      Opacity(
                        opacity: fadeAnimation,
                        child: Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: colors.cardBackground,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: colors.border.withValues(alpha: 0.3),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: colors.textDark.withValues(alpha: 0.03),
                                blurRadius: 12,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Form(
                            key: formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Welcome text
                                Text(
                                  LocalizationKeys
                                      .enterYourCredentialsToContinue
                                      .tr,
                                  style: AppTypography.subheadingM.copyWith(
                                    color: colors.textDark,
                                  ),
                                ),
                                const SizedBox(height: 28),

                                // Username field
                                AppInputField(
                                  controller: usernameController,
                                  hint: LocalizationKeys.usernameHint.tr,
                                  title: LocalizationKeys.username.tr,
                                  prefix: Icon(
                                    Iconsax.user,
                                    color: colors.disabled,
                                    size: 22,
                                  ),
                                  required: true,
                                  validator: (value) =>
                                      controller.emptyValidator(value),
                                  hasFillColor: true,
                                ),
                                const SizedBox(height: 20),

                                // Password field
                                AppInputField(
                                  controller: passwordController,
                                  hint: LocalizationKeys.passwordHint.tr,
                                  title: LocalizationKeys.password.tr,
                                  keyboardType: TextInputType.visiblePassword,
                                  contentPadding: EdgeInsets.only(top: 16),
                                  hasFillColor: true,
                                  prefix: Icon(
                                    Iconsax.lock,
                                    color: colors.disabled,
                                    size: 22,
                                  ),
                                  required: true,
                                  validator: (value) =>
                                      controller.emptyValidator(value),
                                  enabled:
                                      controller.authState != AuthState.loading,
                                  textInputAction: TextInputAction.done,
                                ),
                                const SizedBox(height: 32),

                                AppButton.primary(
                                  text: LocalizationKeys.signIn.tr,
                                  onPressed: () {
                                    if (formKey.currentState?.validate() ??
                                        false) {
                                      controller.login(
                                        username: usernameController.text
                                            .trim(),
                                        password: passwordController.text
                                            .trim(),
                                      );
                                    }
                                  },
                                  isLoading:
                                      controller.authState == AuthState.loading,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Footer
                      Opacity(
                        opacity: fadeAnimation * 0.7,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Iconsax.hospital,
                              size: 16,
                              color: colors.neutralDark.withValues(alpha: 0.8),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              LocalizationKeys
                                  .ensuringPeacefulHealingEnvironments
                                  .tr,
                              style: AppTypography.captionS.copyWith(
                                color: colors.neutralDark.withValues(
                                  alpha: 0.8,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
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
