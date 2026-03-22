import 'package:flutter/material.dart';
import 'package:lms_app/core/presentation/theme/color_manager.dart';
import 'package:lms_app/core/presentation/theme/text_manager.dart';

class LoginTextField extends StatelessWidget {
  const LoginTextField({
    super.key,
    required this.controller,
    required this.keyboardType,
    required this.hintText,
    this.prefix,
    this.suffix,
    this.validator,
    this.obscureText = false,
    this.textInputAction,
    this.textDirection,
  });

  final TextEditingController controller;
  final TextInputType keyboardType;
  final String hintText;
  final Widget? prefix;
  final Widget? suffix;
  final bool obscureText;
  final TextInputAction? textInputAction;
  final TextDirection? textDirection;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction ?? TextInputAction.next,
      obscureText: obscureText,
      validator: validator,
      textAlign: TextAlign.right,
      textDirection: textDirection,
      style: TextStyle(
        fontFamily: AppFonts.cairo,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: ColorManager().titleDark,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          fontFamily: AppFonts.cairo,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: ColorManager().hintGray,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: ColorManager().hintGray,
            width: 0.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: ColorManager().hintGray,
            width: 0.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF3185ff), width: 1),
        ),
        prefixIcon: prefix == null
            ? null
            : Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: 12,
                  end: 8,
                ),
                child: prefix,
              ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 0,
          minHeight: 0,
        ),
        suffixIcon: suffix == null
            ? null
            : Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: 8,
                  end: 12,
                ),
                child: suffix,
              ),
        suffixIconConstraints: const BoxConstraints(
          minWidth: 0,
          minHeight: 0,
        ),
      ),
    );
  }
}
