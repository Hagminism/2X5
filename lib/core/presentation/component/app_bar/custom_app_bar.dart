import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool? showBackButton;
  final void Function()? onTap;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      automaticallyImplyLeading: false,
      surfaceTintColor: Colors.transparent,
      title: Row(
        mainAxisAlignment: (showBackButton != null && showBackButton == true)
            ? MainAxisAlignment.spaceBetween
            : MainAxisAlignment.start,
        children: [
          if (showBackButton != null && showBackButton == true)
            InkWell(
              onTap: onTap,
              child: Icon(
                Icons.arrow_back,
                size: 24,
                color: AppColors.customAppBarPrimary,
              ),
            ),
          if (showBackButton != null && showBackButton == true) Spacer(),
          Text(
            title,
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.customAppBarPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (showBackButton != null && showBackButton == true) Spacer(),
          if (showBackButton != null && showBackButton == true)
            const SizedBox(width: 24, height: 24),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
