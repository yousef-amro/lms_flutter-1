import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms_app/core/domain/constants/svg_manager.dart';
import 'package:lms_app/core/domain/models/core_model.dart';
import 'package:lms_app/core/presentation/theme/color_manager.dart';
import 'package:lms_app/core/presentation/theme/text_manager.dart';

import 'register_field_icon.dart';

class RegisterDropdownField extends StatelessWidget {
  const RegisterDropdownField({
    super.key,
    required this.scale,
    required this.value,
    required this.items,
    required this.hint,
    required this.leadingIcon,
    required this.onChanged,
    required this.validator,
  });

  final double scale;
  final String? value;
  final List<CoreModel> items;
  final String hint;
  final String leadingIcon;
  final ValueChanged<String?> onChanged;
  final String? Function(String?) validator;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      key: ValueKey(value ?? ''),
      initialValue: value,
      isExpanded: true,
      onChanged: onChanged,
      validator: validator,
      icon: Transform.rotate(
        angle: -math.pi / 2,
        child: RegisterFieldIcon(
          asset: SvgManager().registerIconArrowLeft,
          color: ColorManager().hintGray,
          scale: scale,
        ),
      ),
      style: TextStyle(
        fontFamily: AppFonts.cairo,
        fontSize: 14 * scale,
        fontWeight: FontWeight.w500,
        color: ColorManager().titleDark,
      ),
      hint: Text(
        hint.tr,
        textAlign: TextAlign.right,
        style: TextStyle(
          fontFamily: AppFonts.cairo,
          fontSize: 14 * scale,
          fontWeight: FontWeight.w400,
          color: ColorManager().hintGray,
        ),
      ),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16 * scale,
          vertical: 9 * scale,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12 * scale),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: 1 * scale,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12 * scale),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: 1 * scale,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12 * scale),
          borderSide: BorderSide(
            color: ColorManager().hintGray,
            width: 0.5 * scale,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12 * scale),
          borderSide: BorderSide(
            color: ColorManager().hintGray,
            width: 0.5 * scale,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12 * scale),
          borderSide: BorderSide(
            color: ColorManager().infoBlue,
            width: 1 * scale,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12 * scale),
          borderSide: BorderSide(
            color: ColorManager().hintGray,
            width: 0.5 * scale,
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        prefixIcon: Padding(
          padding: EdgeInsetsDirectional.only(
            start: 12 * scale,
            end: 8 * scale,
          ),
          child: RegisterFieldIcon(
            asset: leadingIcon,
            color: ColorManager().hintGray,
            scale: scale,
          ),
        ),
      ),
      items: items
          .map(
            (item) => DropdownMenuItem<String>(
              value: item.id,
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Text(
                  item.name,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: AppFonts.cairo,
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.w500,
                    color: ColorManager().titleDark,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

