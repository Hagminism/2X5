import 'package:capstone_2026/di/di_setup.dart';
import 'package:capstone_2026/feature/bookmark/presentation/screen/bookmark_view_model.dart';
import 'package:capstone_2026/feature/home/presentation/screen/home_view_model.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppBarNavItem extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  final int index;
  final IconData icon;
  final String label;

  static const int _bookmarkTabIndex = 2;

  const AppBarNavItem({
    super.key,
    required this.navigationShell,
    required this.index,
    required this.icon,
    required this.label,
  });

  static const int _homeTabIndex = 0;

  void _onTap() {
    if (index == _homeTabIndex) {
      getIt<HomeViewModel>().refresh();
    }
    if (index == _bookmarkTabIndex) {
      getIt<BookmarkViewModel>().loadBookmarks(force: true);
    }

    navigationShell.goBranch(
      index,
      initialLocation: navigationShell.currentIndex == index,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      child: InkWell(
        onTap: _onTap,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: (navigationShell.currentIndex == index)
                  ? AppColors.primary
                  : const Color(0xFF9CA3AF),
              size: 28,
            ),
            Text(
              label,
              style: AppTextStyles.label.copyWith(
                color: (navigationShell.currentIndex == index)
                    ? AppColors.primary
                    : const Color(0xFF9CA3AF),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}