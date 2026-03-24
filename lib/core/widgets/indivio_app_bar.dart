// lib/core/widgets/indivio_app_bar.dart

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_text_styles.dart';

class IndivioAppBar extends StatelessWidget implements PreferredSizeWidget {
  const IndivioAppBar({
    required this.title,
    this.subtitle,
    this.showBack = false,
    this.actions,
    this.roleColor,
    this.showNotificationBell = false,
    this.notificationCount = 0,
    super.key,
  });

  final String title;
  final String? subtitle;
  final bool showBack;
  final List<Widget>? actions;
  final Color? roleColor;
  final bool showNotificationBell;
  final int notificationCount;

  @override
  Size get preferredSize => const Size.fromHeight(
        AppDimensions.appBarHeight + 0.5,
      );

  @override
  Widget build(BuildContext context) {
    final effectiveRoleColor = roleColor ?? AppColors.primary;

    return AppBar(
      backgroundColor: AppColors.bgPrimary,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: showBack ? BackButton(color: effectiveRoleColor) : null,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.h3,
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: AppTextStyles.caption,
            ),
        ],
      ),
      actions: [
        if (showNotificationBell)
          Padding(
            padding: const EdgeInsets.only(
              right: AppDimensions.paddingLG,
            ),
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                Center(
                  child: Icon(
                    Icons.notifications_rounded,
                    color: effectiveRoleColor,
                    size: AppDimensions.iconLG,
                  ),
                ),
                if (notificationCount > 0)
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.paddingXS),
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      notificationCount > 99
                          ? '99+'
                          : notificationCount.toString(),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textOnPrimary,
                        fontSize: 9,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        if (actions != null) ...actions!,
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.5),
        child: Container(
          height: 0.5,
          color: AppColors.borderLight,
        ),
      ),
    );
  }
}
