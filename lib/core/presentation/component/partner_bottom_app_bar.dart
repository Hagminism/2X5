import 'package:capstone_2026/core/presentation/component/app_bar_nav_item.dart';
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
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            AppBarNavItem(
              navigationShell: navigationShell,
              index: 0,
              icon: Icons.space_dashboard_outlined,
              label: '대시보드',
            ),
            AppBarNavItem(
              navigationShell: navigationShell,
              index: 1,
              icon: Icons.storefront_outlined,
              label: '업장 관리',
            ),
            AppBarNavItem(
              navigationShell: navigationShell,
              index: 2,
              icon: Icons.event_note_outlined,
              label: '예약 현황',
            ),
          ],
        ),
      ),
    );
  }
}
