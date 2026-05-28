import 'package:capstone_2026/core/presentation/component/app_bar_nav_item.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PartnerBottomAppBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const PartnerBottomAppBar({
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
                  icon: Icons.space_dashboard_outlined,
                  selectedIcon: Icons.space_dashboard_rounded,
                  label: '대시보드',
                ),
                AppBarNavItem(
                  navigationShell: navigationShell,
                  index: 1,
                  icon: Icons.storefront_outlined,
                  selectedIcon: Icons.storefront_rounded,
                  label: '업장 관리',
                ),
                AppBarNavItem(
                  navigationShell: navigationShell,
                  index: 2,
                  icon: Icons.event_note_outlined,
                  selectedIcon: Icons.event_note_rounded,
                  label: '예약 현황',
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
