import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  String get yyyyMmDd => DateFormat('yyyy-MM-dd').format(this);
}

extension DoubleExtension on num {
  SizedBox get spaceX => SizedBox(width: toDouble());
  SizedBox get spaceY => SizedBox(height: toDouble());

  BorderRadius get radius => BorderRadius.circular(toDouble());
  BorderRadius get radiusBottom =>
      BorderRadius.vertical(bottom: Radius.circular(toDouble()));
  BorderRadiusGeometry get radiusEnd =>
      BorderRadiusDirectional.horizontal(end: Radius.circular(toDouble()));
  BorderRadius get radiusTop =>
      BorderRadius.vertical(top: Radius.circular(toDouble()));

  EdgeInsetsGeometry get padding => EdgeInsets.all(toDouble());
  EdgeInsetsGeometry get paddingHorizontal =>
      EdgeInsets.symmetric(horizontal: toDouble());
  EdgeInsetsGeometry get paddingVertical =>
      EdgeInsets.symmetric(vertical: toDouble());
  EdgeInsets get paddingTop => EdgeInsets.only(top: toDouble());
  EdgeInsetsGeometry get paddingBottom => EdgeInsets.only(bottom: toDouble());
  EdgeInsetsGeometry get paddingStart =>
      EdgeInsetsDirectional.only(start: toDouble());
}
