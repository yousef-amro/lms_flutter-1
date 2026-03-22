import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lms_app/core/domain/constants/svg_manager.dart';
import 'package:lms_app/core/presentation/localization/localization_keys.dart';
import 'package:lms_app/core/presentation/theme/color_manager.dart';

import '../components/login_actions_row.dart';
import '../components/login_field_icon.dart';
import '../components/login_input_label.dart';
import '../components/login_phone_prefix.dart';
import '../components/login_text_field.dart';

class LoginFormSection extends StatelessWidget {
  const LoginFormSection({
    super.key,
    required this.scale,
    required this.formKey,
    required this.phoneController,
    required this.passwordController,
    required this.obscurePassword,
    required this.isLoading,
    required this.onTogglePasswordVisibility,
    required this.onLogin,
    required this.phoneValidator,
    required this.passwordValidator,
  });

  final double scale;
  final GlobalKey<FormState> formKey;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final bool isLoading;
  final VoidCallback onTogglePasswordVisibility;
  final VoidCallback onLogin;
  final String? Function(String?) phoneValidator;
  final String? Function(String?) passwordValidator;

  @override
  Widget build(BuildContext context) {
    final textDirection = Directionality.of(context);
    final isArabic = (Get.locale?.languageCode ?? '').toLowerCase() == 'ar';

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LoginInputLabel(text: LocalizationKeys.mobileNumber.tr, scale: scale),
          SizedBox(height: 8 * scale),
          LoginTextField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            textDirection: TextDirection.ltr,
            hintText: isArabic ? '\u200F07' : '07',
            validator: phoneValidator,
            prefix: LoginPhonePrefix(scale: scale),
          ),
          SizedBox(height: 18 * scale),
          LoginInputLabel(text: LocalizationKeys.password.tr, scale: scale),
          SizedBox(height: 8 * scale),
          LoginTextField(
            controller: passwordController,
            keyboardType: TextInputType.visiblePassword,
            textDirection: textDirection,
            textInputAction: TextInputAction.done,
            hintText: LocalizationKeys.password.tr,
            obscureText: obscurePassword,
            validator: passwordValidator,
            prefix: LoginFieldIcon(
              asset: SvgManager().loginIconLock,
              color: ColorManager().hintGray,
              scale: scale,
            ),
            suffix: GestureDetector(
              onTap: onTogglePasswordVisibility,
              child: obscurePassword
                  ? Icon(
                      Iconsax.eye,
                      size: 20 * scale,
                      color: ColorManager().hintGray,
                    )
                  : LoginFieldIcon(
                      asset: SvgManager().loginIconEyeSlash,
                      color: ColorManager().hintGray,
                      scale: scale,
                    ),
            ),
          ),
          SizedBox(height: 30 * scale),
          LoginActionsRow(isLoading: isLoading, onLogin: onLogin, scale: scale),
        ],
      ),
    );
  }
}

