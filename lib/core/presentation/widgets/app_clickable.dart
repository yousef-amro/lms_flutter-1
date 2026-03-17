import 'package:flutter/material.dart';

class AppClickable extends StatelessWidget {
  const AppClickable({
    super.key,
    required this.child,
    this.onClick,
    this.color,
    this.radius,
    this.elevation,
  });
  final Widget child;
  final void Function()? onClick;
  final Color? color;
  final double? elevation;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? Colors.transparent,
      borderRadius: BorderRadius.circular(radius ?? 10),
      elevation: elevation ?? 0,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(radius ?? 10),
        onTap: onClick,
        child: child,
      ),
    );
  }
}
