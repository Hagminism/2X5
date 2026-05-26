import 'package:capstone_2026/core/presentation/component/app_bar_nav_item.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomBottomAppBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const CustomBottomAppBar({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(
            top: BorderSide(color: AppColors.border, width: 1),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                AppBarNavItem(
                  navigationShell: navigationShell,
                  index: 0,
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home_rounded,
                  label: '홈',
                ),
                AppBarNavItem(
                  navigationShell: navigationShell,
                  index: 1,
                  icon: Icons.travel_explore_outlined,
                  selectedIcon: Icons.travel_explore_rounded,
                  label: '지도',
                ),
                AppBarNavItem(
                  navigationShell: navigationShell,
                  index: 2,
                  icon: Icons.favorite_border_rounded,
                  selectedIcon: Icons.favorite_rounded,
                  label: '북마크',
                ),
                AppBarNavItem(
                  navigationShell: navigationShell,
                  index: 3,
                  icon: Icons.person_outline_rounded,
                  selectedIcon: Icons.person_rounded,
                  label: '마이페이지',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
