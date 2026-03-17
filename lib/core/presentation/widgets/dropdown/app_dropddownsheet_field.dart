// ignore_for_file: must_be_immutable, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms_app/core/domain/constants/svg_manager.dart';
import 'package:lms_app/core/domain/utils/alerts.dart';
import 'package:lms_app/core/domain/utils/extensions.dart';
import 'package:lms_app/core/presentation/localization/localization_keys.dart';
import 'package:lms_app/core/presentation/theme/color_manager.dart';
import 'package:lms_app/core/presentation/widgets/app_empty_widget.dart';
import 'package:lms_app/core/presentation/widgets/app_list_view.dart';
import 'package:lms_app/core/presentation/widgets/dropdown/components/dropdown_sheet_header.dart';
import 'package:lms_app/core/presentation/widgets/dropdown/components/dropdown_sheet_item.dart';

import '../fields/app_input_field.dart';

class AppDropDownsheetField extends StatelessWidget with Alerts {
  const AppDropDownsheetField({
    super.key,
    required this.list,
    required this.selectedValue,
    required this.keyValue,
    required this.keyDisplay,
    required this.hintText,
    required this.onChanged,
    this.title,
    this.required = false,
    this.height = 50,
  });

  final List<Map<String, dynamic>> list;
  final String? keyValue, keyDisplay;
  final String? selectedValue;
  final String hintText;
  final void Function(String?)? onChanged;
  final String? title;
  final bool required;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final searchController = TextEditingController();

    List<Map<String, dynamic>> filteredList() {
      return list.where((item) {
        return item[keyDisplay].toString().toLowerCase().contains(
          searchController.text.toLowerCase(),
        );
      }).toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Row(
            children: [
              Text(title!, style: theme.textTheme.labelLarge),
              if (required)
                Text(
                  ' *',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: ColorManager().error,
                  ),
                ),
            ],
          ),
          8.spaceY,
        ],
        GestureDetector(
          onTap: () {
            if (list.isEmpty) {
              showFailSnackbar(text: LocalizationKeys.noDataFound.tr);
            } else {
              showBottomSheet(searchController, filteredList);
            }
          },
          child: Container(
            height: height,
            decoration: BoxDecoration(
              borderRadius: 10.radius,
              color: ColorManager().inputFill,
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
                          orElse: () => {keyDisplay!: hintText},
                        )[keyDisplay]
                        .toString(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: ColorManager().black,
                      overflow: TextOverflow.ellipsis,
                    ),
                    maxLines: 1,
                  ),
                ),
                Container(
                  padding: 6.padding,
                  decoration: BoxDecoration(borderRadius: 5.radius),
                  child: const Icon(
                    Icons.keyboard_arrow_down_sharp,
                    size: 22,
                    // color: color ?? ColorManager().disabled,
                  ),
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
    List<Map<String, dynamic>> Function() filteredList,
  ) {
    return Get.bottomSheet(
      isScrollControlled: true,
      ignoreSafeArea: false,
      StatefulBuilder(
        builder: (context, setState) {
          return Container(
            height: MediaQuery.of(context).size.height - 80,
            decoration: BoxDecoration(
              borderRadius: 15.radiusTop,
              color: ColorManager().white,
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownSheetHeader(title: title ?? hintText),
                  10.spaceY,
                  Padding(
                    padding: 10.padding,
                    child: AppInputField.secondary(
                      controller: searchController,
                      hint:
                          "${LocalizationKeys.searchFor.tr} ${title ?? hintText}",
                      prefix: const Icon(Icons.search),
                      onChanged: (_) {
                        setState(() {});
                      },
                    ),
                  ),
                  10.spaceY,
                  Expanded(
                    child: AppListView(
                      isInitialLoading: false,
                      itemsList: filteredList(),
                      listPadding: EdgeInsets.zero,
                      emptyListPlaceholder: AppEmptyWidget(
                        title: LocalizationKeys.noDataFound.tr,
                        description: LocalizationKeys.noDataFoundDescription.tr,
                        svgPath: SvgManager().emptyResults,
                      ),
                      separatorBuilder: (context, index) =>
                          Divider(color: ColorManager().disabled.withAlpha(40)),
                      itemBuilder: (context, index) => DropdownSheetItem(
                        label: filteredList()[index][keyDisplay],
                        value: filteredList()[index][keyValue],
                        selectedValues: [],
                        keyValue: keyValue ?? '',
                        onClick: () {
                          onChanged!(filteredList()[index][keyValue]);
                          navigator?.maybePop();
                        },
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
