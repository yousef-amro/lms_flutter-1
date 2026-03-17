import 'package:flutter/material.dart';
import 'package:lms_app/core/domain/utils/extensions.dart';
import 'package:lms_app/core/presentation/theme/color_manager.dart';

class DropdownSheetHeader extends StatelessWidget {
  const DropdownSheetHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        10.spaceY,
        Center(
          child: Container(
            width: 150,
            height: 7,
            decoration: BoxDecoration(
              color: ColorManager().disabled,
              borderRadius: 10.radius,
            ),
          ),
        ),
        10.spaceY,
        Row(
          children: [
            IconButton(
              onPressed: () {
                Navigator.of(context).maybePop();
              },
              icon: Icon(Icons.close, color: ColorManager().disabled),
            ),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: ColorManager().black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            50.spaceX,
          ],
        ),
        const Divider(),
      ],
    );
  }
}
