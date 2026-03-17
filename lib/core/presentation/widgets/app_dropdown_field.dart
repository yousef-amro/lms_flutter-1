import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get/get.dart';
import 'package:lms_app/core/presentation/localization/localization_keys.dart';

import '../theme/color_manager.dart';
import 'fields/app_input_field.dart';

class AppDropdownField<T> extends HookWidget {
  const AppDropdownField({
    super.key,
    required this.onSelectItem,
    required this.itemBuilder,
    this.initialValue,
    this.hint,
    this.secondary = false,
    this.title,
  });

  final String? initialValue;
  final String Function(T) onSelectItem;
  final List<PopupMenuItem<T>> Function(BuildContext) itemBuilder;
  final String? hint;
  final bool secondary;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController(text: initialValue);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(title!, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
        ],
        PopupMenuButton(
          itemBuilder: (context) => itemBuilder(context),
          onSelected: (value) => controller.text = onSelectItem(value),
          position: PopupMenuPosition.under,
          child: AppInputField(
            controller: controller,
            enabled: false,
            hint: hint,
            suffix: const Icon(Icons.keyboard_arrow_down_rounded),
            inputBorder: secondary
                ? const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}

class AppDropdownSearch<T> extends HookWidget {
  const AppDropdownSearch({
    super.key,
    required this.items,
    required this.hint,
    required this.compareFn,
    required this.selectedValue,
    required this.onSelectItem,
    this.title,
    this.required = false,
    this.validator,
  });

  final bool Function(T, T) compareFn;
  final List<T> items;
  final T? selectedValue;
  final void Function(T) onSelectItem;
  final String? title;
  final String hint;
  final bool required;
  final String? Function(String)? validator;

  @override
  Widget build(BuildContext context) {
    final isError = useState<bool>(false);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Row(
            children: [
              Text(title!, style: Theme.of(context).textTheme.labelLarge),
              if (required)
                Text(
                  ' *',
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: ColorManager().error),
                ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        DropdownSearch<T>(
          selectedItem: selectedValue,
          items: (_, __) => items,
          onChanged: (value) async {
            if (value == null) return;
            onSelectItem(value);
          },
          validator: validator != null
              ? (value) {
                  // Reset error state
                  isError.value = false;

                  // If not required and no value, it's valid
                  if (!required &&
                      (value == null || value.toString().isEmpty)) {
                    return null;
                  }

                  // If required and no value, show error
                  if (required && (value == null || value.toString().isEmpty)) {
                    isError.value = true;
                    return LocalizationKeys.fieldRequired.tr;
                  }

                  // If validator is provided, use it
                  if (validator != null) {
                    final validationResult = validator!(value.toString());
                    if (validationResult != null) {
                      isError.value = true;
                    }
                    return validationResult;
                  }

                  return null;
                }
              : null,
          dropdownBuilder: (context, selection) {
            return Text(
              selectedValue == null ? '' : selection.toString(),
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            );
          },
          compareFn: (i, s) => compareFn(i, s),
          suffixProps: const DropdownSuffixProps(
            dropdownButtonProps: DropdownButtonProps(
              iconClosed: Icon(Icons.keyboard_arrow_down_rounded),
              iconOpened: Icon(Icons.keyboard_arrow_up_rounded),
            ),
          ),
          decoratorProps: DropDownDecoratorProps(
            decoration: InputDecoration(
              fillColor: isError.value
                  ? ColorManager().error.withValues(alpha: 0.1)
                  : ColorManager().inputFill,
              hintText: hint,
              hintStyle: theme.textTheme.labelMedium,
              filled: true,
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: isError.value
                      ? ColorManager().error.withValues(alpha: 0.1)
                      : Colors.transparent,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: isError.value
                      ? ColorManager().error.withValues(alpha: 0.1)
                      : Colors.transparent,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: ColorManager().error.withValues(alpha: 0.1),
                ),
              ),
              disabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent),
              ),
              errorStyle: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
          popupProps: PopupProps.menu(
            showSearchBox: true,
            cacheItems: true,
            fit: FlexFit.tight,
            searchDelay: Duration.zero,
            searchFieldProps: TextFieldProps(
              decoration: InputDecoration(
                suffixIcon: Icon(
                  Icons.search,
                  color: theme.colorScheme.primary,
                ),
              ),
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            itemBuilder: (___, item, _, __) {
              return Text(
                item.toString(),
                textAlign: TextAlign.center,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
