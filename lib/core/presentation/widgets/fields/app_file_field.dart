import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:lms_app/core/domain/utils/extensions.dart';

import '../../theme/color_manager.dart';

class AppFileField extends HookWidget {
  const AppFileField({
    super.key,
    this.localFile,
    this.networkFile,
    this.hint,
    this.title,
    this.enabled = true,
    this.validator,
    this.required = false,
    this.errorText,
    this.suffix,
    this.onTap,
    this.onRemove,
    this.validOrEmptyRequired = false,
  }) : assert(
         !(validOrEmptyRequired && validator == null),
         'If "validOrEmpty" is true, "validator" must be non null',
       );

  final File? localFile;
  final String? networkFile;
  final String? hint;
  final String? title;
  final bool enabled;
  final bool required;
  final String? Function(String)? validator;
  final String? errorText;
  final Widget? suffix;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  final bool validOrEmptyRequired;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // final isError = useState(false);

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
          onTap: onTap,
          child: Row(
            children: [
              4.spaceY,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    localFile != null
                        ? ClipRRect(
                            borderRadius: 5.radius,
                            child: Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: 5.radius,
                                    border: Border.all(
                                      color: ColorManager().disabled.withAlpha(
                                        80,
                                      ),
                                    ),
                                  ),
                                  child: Image.file(localFile!, height: 120),
                                ),
                                Positioned(
                                  left: 0,
                                  child: IconButton(
                                    onPressed: onRemove,
                                    icon: Icon(Icons.close),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : networkFile != null
                        ? ClipRRect(
                            borderRadius: 5.radius,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: 5.radius,
                                border: Border.all(
                                  color: ColorManager().disabled.withAlpha(80),
                                ),
                              ),
                              child: Image.network(networkFile!, height: 120),
                            ),
                          )
                        : Text(hint ?? "", style: theme.textTheme.labelMedium),
                  ],
                ),
              ),
              4.spaceX,
              if (enabled) Icon(Icons.file_upload_outlined),
            ],
          ),
        ),
        Divider(color: ColorManager().disabled, thickness: 2),
      ],
    );
  }
}
