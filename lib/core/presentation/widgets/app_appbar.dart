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
  const AppStaticAppbar({super.key, this.title});

  final String? title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                if (title != null)
                  Expanded(
                    child: Center(
                      child: Text(
                        title!,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                SizedBox(width: 50),
              ],
            ),
          ),
          Divider(color: theme.colorScheme.onPrimary),
          12.spaceY,
        ],
      ),
    );
  }
}
