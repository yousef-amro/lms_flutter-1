import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lms_app/core/domain/constants/svg_manager.dart';
import 'package:lms_app/core/domain/models/core_model.dart';
import 'package:lms_app/core/presentation/localization/localization_keys.dart';
import 'package:lms_app/core/presentation/theme/color_manager.dart';
import 'package:lms_app/core/presentation/widgets/fields/app_input_field.dart';

import '../../login/components/login_phone_prefix.dart';
import '../components/register_actions_row.dart';
import '../components/register_dropdown_field.dart';
import '../components/register_field_icon.dart';
import '../components/register_input_label.dart';
import '../components/register_login_row.dart';

class RegisterFormSection extends StatelessWidget {
  const RegisterFormSection({
    super.key,
    required this.scale,
    required this.formKey,
    required this.fullNameController,
    required this.phoneController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.selectedGeneration,
    required this.selectedCity,
    required this.generationOptions,
    required this.cityOptions,
    required this.isLoading,
    required this.onTogglePasswordVisibility,
    required this.onToggleConfirmPasswordVisibility,
    required this.onGenerationChanged,
    required this.onCityChanged,
    required this.onRegister,
    required this.onLogin,
    required this.phoneValidator,
    required this.validator,
    required this.passwordValidator,
    required this.confirmPasswordValidator,
  });

  final double scale;
  final GlobalKey<FormState> formKey;
  final TextEditingController fullNameController;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final String? selectedGeneration;
  final String? selectedCity;
  final List<CoreModel> generationOptions;
  final List<CoreModel> cityOptions;
  final bool isLoading;
  final VoidCallback onTogglePasswordVisibility;
  final VoidCallback onToggleConfirmPasswordVisibility;
  final ValueChanged<String?> onGenerationChanged;
  final ValueChanged<String?> onCityChanged;
  final VoidCallback onRegister;
  final VoidCallback onLogin;
  final String? Function(String?) phoneValidator;
  final String? Function(String?) validator;
  final String? Function(String?) passwordValidator;
  final String? Function(String?) confirmPasswordValidator;

  @override
  Widget build(BuildContext context) {
    final isArabic = (Get.locale?.languageCode ?? '').toLowerCase() == 'ar';
    final fieldTextDirection = isArabic ? TextDirection.rtl : TextDirection.ltr;
    final fieldTextAlign = isArabic ? TextAlign.right : TextAlign.left;
    final phoneTextAlign = isArabic ? TextAlign.right : TextAlign.left;
    final fieldContentPadding = EdgeInsets.symmetric(
      horizontal: 16 * scale,
      vertical: 9 * scale,
    );
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12 * scale)),
      borderSide: BorderSide(
        color: ColorManager().hintGray,
        width: 0.5 * scale,
      ),
    );
    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12 * scale)),
      borderSide: BorderSide(color: ColorManager().infoBlue, width: 1 * scale),
    );

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RegisterInputLabel(text: LocalizationKeys.fullName.tr, scale: scale),
          SizedBox(height: 6 * scale),
          AppInputField(
            controller: fullNameController,
            keyboardType: TextInputType.name,
            textDirection: fieldTextDirection,
            contentAlignment: fieldTextAlign,
            hint: LocalizationKeys.fullNameHint.tr,
            required: true,
            validator: (value) => validator(value),
            contentPadding: fieldContentPadding,
            inputBorder: inputBorder,
            focusedBorder: focusedBorder,
            prefix: RegisterFieldIcon(
              asset: SvgManager().registerIconProfile,
              color: ColorManager().hintGray,
              scale: scale,
            ),
          ),
          SizedBox(height: 14 * scale),
          RegisterInputLabel(
            text: LocalizationKeys.mobileNumber.tr,
            scale: scale,
          ),
          SizedBox(height: 6 * scale),
          AppInputField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            textDirection: TextDirection.ltr,
            contentAlignment: phoneTextAlign,
            maxLength: 10,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            hint: isArabic ? '\u200F07' : '07',
            required: true,
            validator: (value) => phoneValidator(value),
            prefix: LoginPhonePrefix(scale: scale),
          ),
          SizedBox(height: 14 * scale),
          RegisterInputLabel(text: LocalizationKeys.password.tr, scale: scale),
          SizedBox(height: 6 * scale),
          AppInputField(
            controller: passwordController,
            keyboardType: TextInputType.visiblePassword,
            textDirection: fieldTextDirection,
            contentAlignment: fieldTextAlign,
            hint: LocalizationKeys.passwordMinLengthHint.tr,
            obscureText: obscurePassword,
            onToggleObscureText: onTogglePasswordVisibility,
            required: true,
            validator: (value) => passwordValidator(value),
            contentPadding: fieldContentPadding,
            inputBorder: inputBorder,
            focusedBorder: focusedBorder,
            prefix: RegisterFieldIcon(
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
                  : RegisterFieldIcon(
                      asset: SvgManager().loginIconEyeSlash,
                      color: ColorManager().hintGray,
                      scale: scale,
                    ),
            ),
          ),
          SizedBox(height: 14 * scale),
          RegisterInputLabel(
            text: LocalizationKeys.confirmPassword.tr,
            scale: scale,
          ),
          SizedBox(height: 6 * scale),
          AppInputField(
            controller: confirmPasswordController,
            keyboardType: TextInputType.visiblePassword,
            textDirection: fieldTextDirection,
            contentAlignment: fieldTextAlign,
            hint: LocalizationKeys.passwordMinLengthHint.tr,
            obscureText: obscureConfirmPassword,
            onToggleObscureText: onToggleConfirmPasswordVisibility,
            required: true,
            validator: (value) => confirmPasswordValidator(value),
            contentPadding: fieldContentPadding,
            inputBorder: inputBorder,
            focusedBorder: focusedBorder,
            prefix: RegisterFieldIcon(
              asset: SvgManager().loginIconLock,
              color: ColorManager().hintGray,
              scale: scale,
            ),
            suffix: GestureDetector(
              onTap: onToggleConfirmPasswordVisibility,
              child: obscureConfirmPassword
                  ? Icon(
                      Iconsax.eye,
                      size: 20 * scale,
                      color: ColorManager().hintGray,
                    )
                  : RegisterFieldIcon(
                      asset: SvgManager().loginIconEyeSlash,
                      color: ColorManager().hintGray,
                      scale: scale,
                    ),
            ),
          ),
          SizedBox(height: 14 * scale),
          RegisterInputLabel(
            text: LocalizationKeys.currentGeneration.tr,
            scale: scale,
          ),
          SizedBox(height: 6 * scale),
          RegisterDropdownField(
            scale: scale,
            value: selectedGeneration,
            items: generationOptions,
            hint: LocalizationKeys.currentGenerationHint,
            leadingIcon: SvgManager().registerIconGeneration,
            onChanged: onGenerationChanged,
            validator: validator,
          ),
          SizedBox(height: 14 * scale),
          RegisterInputLabel(text: LocalizationKeys.city.tr, scale: scale),
          SizedBox(height: 6 * scale),
          RegisterDropdownField(
            scale: scale,
            value: selectedCity,
            items: cityOptions,
            hint: LocalizationKeys.currentCityHint,
            leadingIcon: SvgManager().registerIconLocation,
            onChanged: onCityChanged,
            validator: validator,
          ),
          SizedBox(height: 28 * scale),
          RegisterActionsRow(
            isLoading: isLoading,
            onRegister: onRegister,
            scale: scale,
          ),
          SizedBox(height: 14 * scale),
          RegisterLoginRow(onLogin: onLogin, scale: scale),
        ],
      ),
    );
  }
}

