import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms_app/core/presentation/localization/localization_keys.dart';
import 'package:lms_app/core/presentation/theme/color_manager.dart';
import 'package:lms_app/core/presentation/theme/text_manager.dart';

class LoginSignupRow extends StatelessWidget {
  const LoginSignupRow({
    super.key,
    required this.onCreateAccount,
    this.scale = 1,
  });

  final VoidCallback onCreateAccount;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4 * scale,
      children: [
        Text(
          LocalizationKeys.noAccountOnPlatformQ.tr,
          style: TextStyle(
            fontFamily: AppFonts.ffShamelFamily,
            fontSize: 11,
            fontWeight: FontWeight.w200,
            color: ColorManager().textMuted,
          ),
        ),
        GestureDetector(
          onTap: onCreateAccount,
          child: Text(
            LocalizationKeys.createNewAccount.tr,
            style: TextStyle(
              fontFamily: AppFonts.ffShamelFamily,
              fontSize: 11,
              fontWeight: FontWeight.w300,
              color: ColorManager().primaryButton,
            ),
          ),
        ),
      ],
    );
  }
}

