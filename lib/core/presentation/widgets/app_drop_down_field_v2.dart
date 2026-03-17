import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../domain/utils/extensions.dart';
import '../theme/color_manager.dart';
import '../theme/components/text_theme.dart';
import '../theme/text_manager.dart';
import 'app_clickable.dart';
import 'fields/app_input_field.dart';

// Use AppTextTheme from components/text_theme.dart

class AppDropDownSheet<T extends Map<String, dynamic>> extends StatelessWidget {
  const AppDropDownSheet({
    super.key,
    required this.list,
    required this.selectedValue,
    required this.keyValue,
    required this.keyDisplay,
    required this.labelText,
    required this.hintText,
    required this.onChanged,
    this.enable = true,
    this.color,
    this.height = 53,
    this.floatingLabel = false,
  });

  final List<T> list;
  final String? keyValue, keyDisplay;
  final String? selectedValue;
  final String labelText, hintText;
  final bool enable;
  final void Function(String?)? onChanged;
  final Color? color;
  final double height;
  final bool floatingLabel;

  @override
  Widget build(BuildContext context) {
    final searchController = TextEditingController();

    List<T> filteredList() {
      return list.where((item) {
        return item[keyDisplay].toString().toLowerCase().contains(
          searchController.text.toLowerCase(),
        );
      }).toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (floatingLabel) ...[
          Padding(
            padding: 8.paddingHorizontal,
            child: Text(
              labelText,
              style: TextManager().lightBodySmall.copyWith(
                fontWeight: FontWeight.bold,
                color: ColorManager().primary,
              ),
            ),
          ),
          8.spaceY,
        ],
        GestureDetector(
          onTap: () async {
            await showBottomSheet(searchController, filteredList);
          },
          child: Container(
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(color: Colors.grey),
            ),
            padding: 10.paddingHorizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    list
                        .firstWhere(
                          (item) => item[keyValue] == selectedValue,
                          orElse: () => {keyDisplay ?? "name": hintText} as T,
                        )[keyDisplay ?? "name"]
                        .toString(),
                    style: AppTextTheme().lightTheme.bodySmall?.copyWith(
                      color: color ?? ColorManager().disabled,
                    ),
                    maxLines: 2,
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_sharp,
                  color: color ?? ColorManager().disabled,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<dynamic> showBottomSheet(
    TextEditingController searchController,
    List<T> Function() filteredList,
  ) {
    return Get.bottomSheet(
      isScrollControlled: true,
      ignoreSafeArea: false,
      StatefulBuilder(
        builder: (context, setState) {
          return SafeArea(
            child: Container(
              height: MediaQuery.of(context).size.height - 80,
              decoration: BoxDecoration(
                borderRadius: 15.radiusTop,
                color: ColorManager().lightOnPrimary,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  10.spaceY,
                  Center(
                    child: Container(
                      width: 130,
                      height: 5,
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
                          if (Get.isBottomSheetOpen ?? false) {
                            navigator?.popUntil(
                              (route) => !Get.isBottomSheetOpen!,
                            );
                          }
                        },
                        icon: Icon(Icons.close, color: ColorManager().primary),
                      ),
                      Expanded(
                        child: Text(
                          labelText,
                          style: TextManager().lightBodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: ColorManager().lightOnSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      50.spaceX,
                    ],
                  ),
                  const Divider(),
                  Padding(
                    padding: 10.padding,
                    child: AppInputField(
                      controller: searchController,
                      hint: hintText,
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  ),
                  5.spaceY,
                  Expanded(
                    child: filteredList().isEmpty
                        ? Center(
                            child: Padding(
                              padding: 20.paddingHorizontal,
                              child: Text(
                                'No data found',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: EdgeInsets.zero,
                            itemCount: filteredList().length,
                            separatorBuilder: (context, index) =>
                                Divider(color: ColorManager().disabled),
                            itemBuilder: (context, index) => AppClickable(
                              color: Colors.transparent,
                              onClick: () {
                                navigator?.popUntil(
                                  (route) => !Get.isBottomSheetOpen!,
                                );

                                onChanged!(filteredList()[index][keyValue]);
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      filteredList()[index][keyDisplay]
                                          .toString()
                                          .tr,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                    const Spacer(),
                                    Visibility(
                                      visible:
                                          (selectedValue ?? '') ==
                                          filteredList()[index][keyValue]
                                              .toString(),
                                      child: Icon(
                                        Icons.check,
                                        color: ColorManager().primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
