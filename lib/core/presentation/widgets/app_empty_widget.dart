import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lms_app/core/domain/utils/extensions.dart';
import 'package:lms_app/core/presentation/theme/color_manager.dart';

class AppEmptyWidget extends StatelessWidget {
  const AppEmptyWidget({
    super.key,
    required this.title,
    required this.description,
    required this.svgPath,
  });
  final String title;
  final String description;
  final String svgPath;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset(svgPath, width: 100, height: 100),
        10.spaceY,
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        5.spaceY,
        Text(
          description,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: ColorManager().disabled.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }
}
