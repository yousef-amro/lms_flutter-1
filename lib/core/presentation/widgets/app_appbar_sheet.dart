import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms_app/core/domain/utils/extensions.dart';
import 'package:lms_app/core/presentation/localization/localization_keys.dart';
import 'package:lms_app/core/presentation/theme/color_manager.dart';

class AppAppbarSheet extends StatelessWidget {
  const AppAppbarSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        12.spaceY,
        Center(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: 5.radius,
              color: ColorManager().disabled,
            ),
            width: 155,
            height: 5,
          ),
        ),
        12.spaceY,
        Padding(
          padding: 12.paddingHorizontal,
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.of(context).pop();
                  }
                },
                icon: Icon(
                  Icons.close,
                  color: ColorManager().disabled,
                  size: 24,
                ),
              ),
              12.spaceX,
              Expanded(
                child: Center(
                  child: Text(
                    LocalizationKeys.chooseDeliveryLocation.tr,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              50.spaceX,
            ],
          ),
        ),
        Divider(color: ColorManager().disabled.withValues(alpha: 0.2)),
        12.spaceY,
      ],
    );
  }
}
