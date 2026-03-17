import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms_app/core/presentation/localization/localization_keys.dart';
import 'package:lms_app/core/presentation/theme/color_manager.dart';
import 'package:lms_app/core/presentation/theme/text_manager.dart';

class RegisterActionsRow extends StatelessWidget {
  const RegisterActionsRow({
    super.key,
    required this.isLoading,
    required this.onRegister,
    required this.scale,
  });

  final bool isLoading;
  final VoidCallback onRegister;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 59 * scale,
            child: ElevatedButton(
              onPressed: isLoading ? null : onRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorManager().infoBlue,
                disabledBackgroundColor:
                    ColorManager().infoBlue.withValues(alpha: 0.5),
                shape: const StadiumBorder(),
                elevation: 0,
              ),
              child: isLoading
                  ? SizedBox(
                      width: 22 * scale,
                      height: 22 * scale,
                      child: CircularProgressIndicator(
                        strokeWidth: 2 * scale,
                        color: ColorManager().white,
                      ),
                    )
                  : Text(
                      LocalizationKeys.registerConfirmSubscription.tr,
                      style: TextStyle(
                        fontFamily: AppFonts.ffShamelFamily,
                        fontSize: 15,
                        fontWeight: FontWeight.w300,
                        color: ColorManager().white,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

