import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lms_app/core/domain/constants/svg_manager.dart';
import 'package:lms_app/core/presentation/theme/color_manager.dart';

class LoginPhonePrefix extends StatelessWidget {
  const LoginPhonePrefix({super.key, this.scale = 1});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          SvgManager().loginIconCall,
          width: 20 * scale,
          height: 20 * scale,
          colorFilter: ColorFilter.mode(
            ColorManager().hintGray,
            BlendMode.srcIn,
          ),
        ),
      ],
    );
  }
}

