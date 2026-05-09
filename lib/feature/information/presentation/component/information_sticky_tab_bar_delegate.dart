import 'package:flutter/material.dart';

class InformationStickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  const InformationStickyTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1)),
      ),
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(InformationStickyTabBarDelegate oldDelegate) => false;
}
