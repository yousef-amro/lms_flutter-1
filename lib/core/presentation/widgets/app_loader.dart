import 'package:flutter/material.dart';

import '../theme/color_manager.dart';

class AppLoader extends StatelessWidget {
  const AppLoader({
    super.key,
    this.withBackground = false,
    this.value,
    this.size,
  });

  final bool withBackground;
  final double? value;
  final Size? size;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size?.height ?? 50,
      width: size?.width ?? 50,
      constraints: const BoxConstraints(),
      padding: size == null ? const EdgeInsets.all(12) : null,
      decoration: withBackground
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: ColorManager().darkColor,
            )
          : null,
      child: Center(
        child: CircularProgressIndicator(
          strokeCap: StrokeCap.round,
          value: value,
        ),
      ),
    );
  }
}
