import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms_app/core/presentation/theme/color_manager.dart';
import 'package:lms_app/core/presentation/widgets/app_clickable.dart';

class DropdownSheetItem extends StatelessWidget {
  const DropdownSheetItem({
    super.key,
    required this.label,
    required this.onClick,
    required this.selectedValues,
    required this.value,
    required this.keyValue,
  });

  final String label, value, keyValue;
  final void Function()? onClick;
  final List<Map<String, dynamic>> selectedValues;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Check if this item is selected
    final isSelected = selectedValues.any(
      (selectedItem) => selectedItem[keyValue].toString() == value.toString(),
    );

    return AppClickable(
      color: Colors.transparent,
      onClick: onClick,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label.toString().tr,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: value == "0" ? Colors.amber : Colors.black,
                  fontWeight: value == "0"
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
            Visibility(
              visible: isSelected,
              child: Icon(Icons.check, color: ColorManager().primary),
            ),
          ],
        ),
      ),
    );
  }
}
