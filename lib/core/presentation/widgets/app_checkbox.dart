import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get/get.dart';

import '../localization/localization_keys.dart';
import '../theme/color_manager.dart';

class AppCheckbox extends FormField<bool> {
  final bool checkBoxValue;
  final void Function(bool)? onChanged;
  final String text;
  final String? highlightedText;
  final VoidCallback? onPressHighlightedText;
  final Widget? suffix;
  final bool required;

  AppCheckbox({
    super.key,
    this.onChanged,
    required this.text,
    this.checkBoxValue = false,
    this.highlightedText,
    this.suffix,
    this.onPressHighlightedText,
    this.required = false,
  }) : super(
         validator: (value) {
           if (!required) return null;
           if (value!) return null;
           return LocalizationKeys.fieldRequired.tr;
         },
         initialValue: checkBoxValue,
         builder: (FormFieldState<bool> state) {
           return HookBuilder(
             builder: (context) {
               final value = useState(checkBoxValue);
               final theme = Theme.of(context);
               return CheckboxListTile(
                 value: value.value,
                 tristate: false,
                 onChanged: (v) {
                   value.value = v!;
                   state.didChange(v);
                   if (onChanged != null) onChanged(v);
                 },
                 isError: state.hasError,
                 contentPadding: EdgeInsets.zero,
                 dense: state.hasError,
                 title:
                     suffix ??
                     Text.rich(
                       TextSpan(
                         text: text,
                         style: theme.textTheme.labelSmall?.copyWith(
                           fontWeight: FontWeight.w600,
                           fontSize: 16,
                         ),
                         children: [
                           if (highlightedText != null)
                             WidgetSpan(
                               alignment: PlaceholderAlignment.middle,
                               child: Padding(
                                 padding: const EdgeInsets.symmetric(
                                   horizontal: 2.0,
                                 ),
                                 child: InkWell(
                                   onTap: onPressHighlightedText,
                                   borderRadius: BorderRadius.circular(2),
                                   splashColor: ColorManager().darkColor
                                       .withValues(alpha: 0.2),
                                   child: Padding(
                                     padding: const EdgeInsets.all(2.0),
                                     child: Text(
                                       highlightedText,
                                       style: theme.textTheme.labelSmall
                                           ?.copyWith(
                                             color: ColorManager().darkColor,
                                           ),
                                     ),
                                   ),
                                 ),
                               ),
                             ),
                         ],
                       ),
                     ),
                 subtitle: state.hasError
                     ? Builder(
                         builder: (BuildContext context) => Text(
                           state.errorText ?? "",
                           style: theme.textTheme.labelSmall?.copyWith(
                             color: theme.colorScheme.error,
                           ),
                         ),
                       )
                     : null,
                 controlAffinity: ListTileControlAffinity.leading,
                 materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                 visualDensity: VisualDensity.compact,
               );
             },
           );
         },
       );
}
