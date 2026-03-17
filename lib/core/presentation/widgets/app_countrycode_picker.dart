// import 'package:arabgt_app/core/presentation/localization/localization_keys.dart';
// import 'package:arabgt_app/core/presentation/theme/color_manager.dart';
// import 'package:fl_country_code_picker/fl_country_code_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_hooks/flutter_hooks.dart';
// import 'package:get/get.dart';

// import '../localization/localization_keys.dart';

// class AppCountrycodePicker extends HookWidget {
//   const AppCountrycodePicker({
//     super.key,
//     required this.onCountryCodeChanged,
//     this.initialDialCode,
//     this.searchHint,
//   });

//   final void Function(CountryCode) onCountryCodeChanged;
//   final String? initialDialCode;
//   final String? searchHint;

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final countryCode =
//         useState<CountryCode?>(CountryCode.fromDialCode(initialDialCode));
//     return GestureDetector(
//       onTap: () async {
//         final picker = FlCountryCodePicker(
//           countryTextStyle: theme.textTheme.labelLarge,
//           dialCodeTextStyle: theme.textTheme.labelLarge,
//           searchBarDecoration: InputDecoration(
//             fillColor: ColorManager().inputFill,
//             hintText: LocalizationKeys.searchCountry.tr,
//             hintStyle: theme.textTheme.labelLarge?.copyWith(
//               color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
//             ),
//             suffixIconConstraints: const BoxConstraints(),
//             suffixIcon: const Icon(Icons.search_rounded),
//             alignLabelWithHint: true,
//           ),
//           title: Padding(
//             padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
//             child: Text(
//               LocalizationKeys.selectCountry.tr,
//               style: theme.textTheme.labelLarge,
//             ),
//           ),
//           searchBarTextStyle: theme.textTheme.labelLarge,
//           filteredCountries: codes
//               .where((code) {
//                 return code['name'] != 'Israel';
//               })
//               .map((code) => code['code'] as String)
//               .toList(),
//         );

//         final code = await picker.showPicker(
//           context: context,
//           scrollToDeviceLocale: false,
//           barrierColor:
//               theme.colorScheme.inverseSurface.withValues(alpha: 0.75),
//         );

//         if (code != null) {
//           countryCode.value = code;
//           onCountryCodeChanged(code);
//         }
//       },
//       child: Container(
//         height: 48,
//         padding: const EdgeInsets.symmetric(horizontal: 8),
//         decoration: BoxDecoration(
//           color: theme.colorScheme.onPrimary,
//           border: Border(
//             bottom: BorderSide(
//               color: theme.colorScheme.primary,
//               width: 2,
//             ),
//           ),
//           borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ClipRRect(
//               borderRadius: BorderRadius.circular(4),
//               child: countryCode.value == null
//                   ? const Icon(Icons.block_rounded)
//                   : Image.asset(
//                       countryCode.value!.flagUri,
//                       width: 30,
//                       package: countryCode.value?.flagImagePackage,
//                     ),
//             ),
//             const SizedBox(width: 8),
//             if (countryCode.value != null)
//               Text(
//                 countryCode.value!.dialCode,
//                 style: theme.textTheme.labelMedium
//                     ?.copyWith(fontWeight: FontWeight.w700),
//               ),
//             const SizedBox(width: 4),
//             Icon(
//               Icons.keyboard_arrow_down_rounded,
//               size: 24,
//               color: theme.colorScheme.primary,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
