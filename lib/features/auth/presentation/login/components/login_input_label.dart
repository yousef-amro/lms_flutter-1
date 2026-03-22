import 'package:flutter/material.dart';
import 'package:lms_app/core/presentation/theme/color_manager.dart';
import 'package:lms_app/core/presentation/theme/text_manager.dart';

class LoginInputLabel extends StatelessWidget {
  const LoginInputLabel({super.key, required this.text, this.scale = 1});

  final String text;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text(
        text,
        style: TextStyle(
          fontFamily: AppFonts.bahijTheSansArabic,
          fontSize: 14 * scale,
          fontWeight: FontWeight.w700,
          color: ColorManager().titleDark.withValues(alpha: 0.8),
        ),
        textAlign: TextAlign.start,
      ),
    );
  }
}

