import 'package:capstone_2026/core/presentation/component/app_bar_nav_item.dart';
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: navigationShell,
      bottomNavigationBar: BottomAppBar(
        // shape: const CircularNotchedRectangle(), // 노치 모양 생성
        // notchMargin: 8.0, // 노치와 floatingActionButton 사이의 간격
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            AppBarNavItem(
              navigationShell: navigationShell,
              index: 0,
              icon: Icons.home_outlined,
              label: '홈',
            ),
            AppBarNavItem(
              navigationShell: navigationShell,
              index: 1,
              icon: Icons.travel_explore_rounded,
              label: '지도',
            ),
            AppBarNavItem(
              navigationShell: navigationShell,
              index: 2,
              icon: Icons.favorite_border_rounded,
              label: '북마크',
            ),
            AppBarNavItem(
              navigationShell: navigationShell,
              index: 3,
              icon: Icons.person_outline_rounded,
              label: '마이페이지',
            ),
          ],
        ),
      ),
      // floatingActionButton: (navigationShell.currentIndex == 0)
      //     ? FloatingActionButton(
      //         onPressed: () {},
      //         shape: CircleBorder(),
      //         backgroundColor: AppColors.primary,
      //         child: Icon(
      //           Icons.add,
      //           color: Colors.white,
      //           size: 32,
      //         ),
      //       )
      //     : null,
    );
  }
}
