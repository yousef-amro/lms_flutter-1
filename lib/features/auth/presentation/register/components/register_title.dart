import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lms_app/core/domain/constants/svg_manager.dart';
import 'package:lms_app/core/presentation/theme/color_manager.dart';
import 'package:lms_app/core/presentation/theme/text_manager.dart';

class RegisterTitle extends StatelessWidget {
  const RegisterTitle({
    super.key,
    required this.title,
    required this.scale,
  });

  final String title;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppFonts.ffShamelFamily,
            fontSize: 25 * scale,
            height: 1.5,
            color: ColorManager().titleDark,
          ),
        ),
        Column(
          children: [
            SizedBox(height: 28 * scale),
            SvgPicture.asset(
              SvgManager().registerTitleUnderline,
              width: 77 * scale,
              height: 10 * scale,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ],
    );
  }
}

