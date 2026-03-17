import 'package:flutter/material.dart';
import 'package:lms_app/core/domain/constants/svg_manager.dart';
import 'package:lms_app/core/presentation/theme/color_manager.dart';
import 'package:lms_app/core/presentation/theme/text_manager.dart';

import 'register_field_icon.dart';

class RegisterPhonePrefix extends StatelessWidget {
  const RegisterPhonePrefix({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      textDirection: TextDirection.rtl,
      children: [
        RegisterFieldIcon(
          asset: SvgManager().loginIconCall,
          color: ColorManager().hintGray,
        ),
        const SizedBox(width: 6),
        Text(
          '+972',
          style: TextStyle(
            fontFamily: AppFonts.cairo,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: ColorManager().hintGray,
          ),
        ),
      ],
    );
  }
}

