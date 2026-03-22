import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lms_app/core/domain/utils/extensions.dart';
import 'package:lms_app/core/presentation/theme/text_manager.dart';

import '../../localization/localization_keys.dart';
import '../../theme/color_manager.dart';

class AppInputField extends HookWidget {
  const AppInputField({
    super.key,
    this.controller,
    this.hint,
    this.title,
    this.keyboardType = TextInputType.text,
    this.enabled = true,
    this.validator,
    this.nullMaxLines = false,
    this.required = false,
    this.maxLines,
    this.errorText,
    this.suffix,
    this.prefix,
    this.onTap,
    this.validOrEmptyRequired = false,
    this.contentAlignment,
    this.inputFormatters,
    this.onChanged,
    this.maxLength,
    this.contentPadding,
    this.autovalidateMode,
    this.inputBorder,
    this.focusedBorder,
    this.hasFillColor = false,
    this.textInputAction,
    this.textDirection,
    this.obscureText,
    this.onToggleObscureText,
  }) : assert(
         !(validOrEmptyRequired && validator == null),
         'If "validOrEmpty" is true, "validator" must be non null',
       );

  const AppInputField.secondary({
    super.key,
    this.controller,
    this.hint,
    this.title,
    this.contentPadding,
    this.prefix,
    this.keyboardType = TextInputType.text,
    this.enabled = true,
    this.validator,
    this.required = false,
    this.maxLines,
    this.nullMaxLines = false,
    this.errorText,
    this.suffix,
    this.onTap,
    this.maxLength,
    this.validOrEmptyRequired = false,
    this.contentAlignment,
    this.inputFormatters,
    this.onChanged,
    this.autovalidateMode,
    this.textDirection,
    this.textInputAction,
    this.obscureText,
    this.onToggleObscureText,
    this.inputBorder = const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.transparent),
      borderRadius: BorderRadius.all(Radius.circular(5.0)),
    ),
    this.focusedBorder = const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.transparent),
      borderRadius: BorderRadius.all(Radius.circular(5.0)),
    ),
    this.hasFillColor = true,
  }) : assert(
         !(validOrEmptyRequired && validator == null),
         'If "validOrEmpty" is true, "validator" must be non null',
       );

  final TextEditingController? controller;
  final String? hint;
  final String? title;
  final TextInputType keyboardType;
  final bool enabled;
  final bool required;
  final bool nullMaxLines;
  final int? maxLines;
  final String? Function(String)? validator;
  final void Function(String)? onChanged;
  final String? errorText;
  final Widget? suffix;
  final Widget? prefix;
  final VoidCallback? onTap;
  final TextAlign? contentAlignment;
  final bool validOrEmptyRequired;
  final EdgeInsets? contentPadding;
  final List<TextInputFormatter>? inputFormatters;
  final AutovalidateMode? autovalidateMode;
  final InputBorder? inputBorder;
  final InputBorder? focusedBorder;
  final int? maxLength;
  final bool hasFillColor;
  final TextDirection? textDirection;
  final TextInputAction? textInputAction;
  final bool? obscureText;
  final VoidCallback? onToggleObscureText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localObscureText = useState(
      keyboardType == TextInputType.visiblePassword,
    );
    final isError = useState(false);
    final effectiveObscure = obscureText ?? localObscureText.value;

    final defaultBorderSide = BorderSide(
      color: ColorManager().border,
      width: 1,
    );
    final defaultRadius = BorderRadius.circular(30);
    final defaultOutlineBorder = OutlineInputBorder(
      borderSide: defaultBorderSide,
      borderRadius: defaultRadius,
    );
    final defaultErrorBorder = OutlineInputBorder(
      borderSide: BorderSide(
        color: theme.colorScheme.error,
        width: 1,
      ),
      borderRadius: defaultRadius,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Row(
            children: [
              Text(title!, style: AppTypography.bodyS.bold),
              if (required)
                Text(
                  ' *',
                  style: AppTypography.bodyS.bold.copyWith(
                    color: ColorManager().error,
                  ),
                ),
            ],
          ),
          8.spaceY,
        ],
        GestureDetector(
          onTap: onTap,
          child: TextFormField(
            key: key,
            controller: controller,
            onChanged: (value) {
              if (onChanged != null) onChanged!(value);
            },
            maxLength: maxLength,
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
            buildCounter:
                (
                  context, {
                  required currentLength,
                  required isFocused,
                  required maxLength,
                }) => SizedBox(),
            onTapOutside: (_) => FocusScope.of(context).unfocus(),
            keyboardType: keyboardType,
            textInputAction: textInputAction ?? TextInputAction.next,
            enabled: enabled,
            autovalidateMode: autovalidateMode,
            textDirection:
                textDirection ??
                (keyboardType == TextInputType.phone
                    ? TextDirection.ltr
                    : null),
            maxLines: maxLines ?? (nullMaxLines ? null : 1),
            obscureText: effectiveObscure,
            inputFormatters: inputFormatters,
            textAlign: contentAlignment ?? TextAlign.start,
            obscuringCharacter: '*',
            validator: (value) {
              if (validOrEmptyRequired) {
                if (validator!(value ?? '') != null)
                  isError.value = true;
                return validator!(value ?? '');
              }
              if (!required) return null;
              if (value case null || '') {
                isError.value = true;
                return LocalizationKeys.fieldRequired.tr;
              }
              if (validator case null) return null;
              if (validator!(value) != null) isError.value = true;

              return validator!(value);
            },
            style: AppTypography.bodyS.bold,
            decoration: InputDecoration(
              border: inputBorder ?? defaultOutlineBorder,
              enabledBorder: inputBorder ?? defaultOutlineBorder,
              disabledBorder: inputBorder ?? defaultOutlineBorder,
              focusedBorder:
                  focusedBorder ??
                  (inputBorder ?? defaultOutlineBorder),
              errorBorder: inputBorder ?? defaultErrorBorder,
              focusedErrorBorder: inputBorder ?? defaultErrorBorder,
              hintText: hint,
              suffixIconConstraints: const BoxConstraints(),
              prefixIconConstraints: const BoxConstraints(),
              fillColor: (isError.value || errorText != null)
                  ? theme.colorScheme.error.withValues(alpha: 0.1)
                  : ColorManager().inputFill,
              filled: hasFillColor,
              prefixIcon: Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: 16,
                  end: 8,
                ),
                child: prefix,
              ),
              isDense: true,
              contentPadding:
                  contentPadding ??
                  const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 18,
                  ),
              suffixIconColor: theme.colorScheme.onSurface,
              suffixIcon:
                  (suffix == null &&
                      keyboardType != TextInputType.visiblePassword)
                  ? null
                  : Padding(
                      padding: const EdgeInsetsDirectional.only(
                        start: 8,
                        end: 16,
                      ),
                      child:
                          suffix ??
                          (keyboardType ==
                                  TextInputType.visiblePassword
                              ? IconButton(
                                  onPressed:
                                      onToggleObscureText ??
                                      () => localObscureText.value =
                                          !localObscureText.value,

                                  icon: Icon(
                                    effectiveObscure
                                        ? Iconsax.eye
                                        : Iconsax.eye_slash,
                                    size: 20,
                                  ),
                                )
                              : null),
                    ),
              hintStyle: AppTypography.bodyS.medium,
              errorStyle: AppTypography.captionM.medium.copyWith(
                color: theme.colorScheme.error,
              ),
              error: errorText != null && !isError.value
                  ? Text(
                      errorText!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
