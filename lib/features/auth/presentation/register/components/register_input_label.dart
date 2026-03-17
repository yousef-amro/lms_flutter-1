import 'package:flutter/material.dart';
import 'package:lms_app/core/presentation/theme/color_manager.dart';
import 'package:lms_app/core/presentation/theme/text_manager.dart';

class RegisterInputLabel extends StatelessWidget {
  const RegisterInputLabel({
    super.key,
    required this.text,
    this.scale = 1,
  });

  final String text;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text(
        text,
        textAlign: TextAlign.right,
        style: TextStyle(
          fontFamily: AppFonts.bahijTheSansArabic,
          fontSize: 14 * scale,
          fontWeight: FontWeight.w700,
          color: ColorManager().titleDark.withValues(alpha: 0.8),
        ),
      ),
    );
  }
}

