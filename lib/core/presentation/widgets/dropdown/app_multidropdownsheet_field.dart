import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get/get.dart';
import 'package:lms_app/core/domain/utils/extensions.dart';
import 'package:lms_app/core/presentation/localization/localization_keys.dart';
import 'package:lms_app/core/presentation/theme/color_manager.dart';
import 'package:lms_app/core/presentation/widgets/app_clickable.dart';
import 'package:lms_app/core/presentation/widgets/dropdown/components/dropdown_sheet_header.dart';
import 'package:lms_app/core/presentation/widgets/dropdown/components/dropdown_sheet_item.dart';
import 'package:lms_app/core/presentation/widgets/fields/app_input_field.dart';

class AppMultidropdownsheetField extends HookWidget {
  const AppMultidropdownsheetField({
    super.key,
    required this.selectedValue,
    required this.hintText,
    required this.keyValue,
    required this.keyDisplay,
    required this.list,
    this.maxSelectedValue = 15,
    this.height = 50,
    this.floatingLabel = false,
    this.selectAll,
    this.onTickItem,
    this.whenCloseSheet,
    this.title,
    this.required = false,
  });

  final List<Map<String, dynamic>> selectedValue;
  final List<Map<String, dynamic>> list;
  final String hintText, keyDisplay, keyValue;
  final int maxSelectedValue;
  final double height;
  final bool floatingLabel;
  final bool? selectAll;
  final String? title;
  final bool required;
  final void Function(List<Map<String, dynamic>>)? onTickItem;
  final void Function()? whenCloseSheet;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Local copy for selected items so rebuilds work
    final selected = useState<List<Map<String, dynamic>>>(
      List<Map<String, dynamic>>.from(selectedValue),
    );

    // To update parent list whenever tick/change
    void syncTickItem(List<Map<String, dynamic>> value) {
      onTickItem?.call(value);
      // Also overwrite the given selectedValue - as much as we can in stateless setup
      selectedValue
        ..clear()
        ..addAll(value);
    }

    return Column(
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
          onTap: () async {
            await showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) {
                return _MultiDropdownBottomSheet(
                  selected: selected.value,
                  keyDisplay: keyDisplay,
                  keyValue: keyValue,
                  maxSelectedValue: maxSelectedValue,
                  list: list,
                  title: title,
                  hintText: hintText,
                  onChanged: (newSelected) {
                    selected.value = List<Map<String, dynamic>>.from(
                      newSelected,
                    );
                    syncTickItem(selected.value);
                  },
                );
              },
            );
            whenCloseSheet?.call();
          },
          child: Container(
            height: height,
            decoration: BoxDecoration(
              borderRadius: 10.radius,
              color: ColorManager().inputFill,
            ),
            padding: 10.paddingHorizontal,
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        hintText,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: ColorManager().black,
                          overflow: TextOverflow.ellipsis,
                        ),
                        maxLines: 1,
                      ),
                      5.spaceX,
                      if (selected.value.isNotEmpty) ...[
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: ColorManager().error,
                          ),
                          child: Padding(
                            padding: 5.padding,
                            child: Text(
                              selected.value.length.toString(),
                              style: theme.textTheme.headlineLarge?.copyWith(
                                color: ColorManager().white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        5.spaceX,
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_sharp,
                  color: ColorManager().black,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MultiDropdownBottomSheet extends HookWidget {
  const _MultiDropdownBottomSheet({
    required this.selected,
    required this.keyDisplay,
    required this.keyValue,
    required this.maxSelectedValue,
    required this.list,
    required this.title,
    required this.hintText,
    required this.onChanged,
  });

  final List<Map<String, dynamic>> selected;
  final List<Map<String, dynamic>> list;
  final String keyValue, keyDisplay, hintText;
  final int maxSelectedValue;
  final String? title;
  final void Function(List<Map<String, dynamic>>) onChanged;

  @override
  Widget build(BuildContext context) {
    final searchController = useTextEditingController();
    final filtered = useState<List<Map<String, dynamic>>>(list);
    // Local state to track selected items for UI updates
    final localSelected = useState<List<Map<String, dynamic>>>(
      List<Map<String, dynamic>>.from(selected),
    );

    // Update local state when selected prop changes
    useEffect(() {
      // Deep copy to ensure we detect changes
      final newSelected = List<Map<String, dynamic>>.from(selected);
      // Compare by length and values to detect changes
      if (localSelected.value.length != newSelected.length ||
          !localSelected.value.every(
            (item) => newSelected.any(
              (newItem) =>
                  newItem[keyValue].toString() == item[keyValue].toString(),
            ),
          )) {
        localSelected.value = newSelected;
      }
      return null;
    }, [selected, keyValue]);

    useEffect(() {
      void filter() {
        filtered.value = list.where((item) {
          return item[keyDisplay].toString().toLowerCase().contains(
            searchController.text.toLowerCase(),
          );
        }).toList();
      }

      searchController.addListener(filter);
      filter();
      return () => searchController.removeListener(filter);
    }, [list, keyDisplay, searchController]);

    // for the tags horizontal
    void removeAtIdx(int idx) {
      final mod = List<Map<String, dynamic>>.from(localSelected.value);
      final toRemove = mod[idx][keyValue];
      mod.removeWhere((element) => element[keyValue] == toRemove);
      localSelected.value = mod;
      onChanged(mod);
    }

    void onClickItem(Map<String, dynamic> item) {
      final mod = List<Map<String, dynamic>>.from(localSelected.value);
      final id = item[keyValue].toString();
      final idx = mod.indexWhere((v) => v[keyValue].toString() == id);
      if (idx != -1) {
        mod.removeAt(idx);
      } else {
        if (mod.length < maxSelectedValue) {
          mod.add({keyValue: item[keyValue], keyDisplay: item[keyDisplay]});
        }
      }
      localSelected.value = mod;
      onChanged(mod);
    }

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
                hint: "${LocalizationKeys.searchFor.tr} ${title ?? hintText}",
                prefix: const Icon(Icons.search),
                onChanged: (_) {},
              ),
            ),
            10.spaceY,
            Visibility(
              visible: localSelected.value.isNotEmpty,
              child: SizedBox(
                height: 34,
                child: ListView.separated(
                  padding: 10.paddingHorizontal,
                  scrollDirection: Axis.horizontal,
                  itemCount: localSelected.value.length,
                  separatorBuilder: (context, index) => 10.spaceX,
                  itemBuilder: (context, index) {
                    return AppClickable(
                      onClick: () {
                        removeAtIdx(index);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: 10.radius,
                          border: Border.all(
                            color: ColorManager().disabled.withAlpha(40),
                          ),
                          color: ColorManager().primary,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              localSelected.value[index][keyDisplay],
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: ColorManager().white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            10.spaceX,
                            Icon(
                              Icons.close,
                              color: ColorManager().white,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            5.spaceY,
            Expanded(
              child: list.isEmpty
                  ? Center(
                      child: Padding(
                        padding: 20.paddingHorizontal,
                        child: Text(
                          LocalizationKeys
                              .thereIsNoDataAccordingToCurrentResearch
                              .tr,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : Stack(
                      children: [
                        ListView.separated(
                          padding: EdgeInsets.zero,
                          itemCount: filtered.value.length,
                          separatorBuilder: (context, index) => Divider(
                            color: ColorManager().disabled.withAlpha(40),
                          ),
                          itemBuilder: (context, index) {
                            final item = filtered.value[index];
                            return DropdownSheetItem(
                              label: item[keyDisplay],
                              value: item[keyValue],
                              selectedValues: localSelected.value,
                              keyValue: keyValue,
                              onClick: () {
                                onClickItem(item);
                              },
                            );
                          },
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
