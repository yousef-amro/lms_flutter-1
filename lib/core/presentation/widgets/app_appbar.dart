import 'package:flutter/material.dart';
import 'package:lms_app/core/domain/utils/extensions.dart';
import 'package:lms_app/core/presentation/theme/color_manager.dart';
import 'package:lms_app/core/presentation/widgets/app_clickable.dart';

class AppAppbar extends StatelessWidget implements PreferredSizeWidget {
  const AppAppbar({super.key, this.isAsk = false});

  final bool isAsk;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      backgroundColor: theme.scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      centerTitle: false,
      actions: [],
    );
  }
}

class AppStaticAppbar extends StatelessWidget {
  const AppStaticAppbar({super.key, this.title, this.trailing});

  final String? title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 20, vertical: 12),
            child: Directionality(
              // Keep back button on the left and trailing on the right,
              // regardless of the app's current locale direction.
              textDirection: TextDirection.ltr,
              child: Row(
                children: [
                  AppClickable(
                    onClick: () {
                      if (Navigator.canPop(context)) {
                        Navigator.of(context).pop();
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onPrimary,
                        shape: BoxShape.circle,
                      ),
                      padding: 8.padding,
                      child: Icon(
                        Icons.arrow_back,
                        color: ColorManager().black,
                        size: 26,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: title == null
                          ? const SizedBox.shrink()
                          : Text(
                              title!,
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(
                    width: 50,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: trailing,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(color: theme.colorScheme.onPrimary),
          12.spaceY,
        ],
      ),
    );
  }
}
