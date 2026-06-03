import 'package:capstone_2026/feature/my_page/coupon_box/domain/model/coupon.dart';
import 'package:capstone_2026/feature/my_page/coupon_box/presentation/screen/coupon_box_action.dart';
import 'package:capstone_2026/feature/my_page/coupon_box/presentation/screen/coupon_box_state.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CouponBoxScreen extends StatefulWidget {
  const CouponBoxScreen({
    super.key,
    required this.state,
    required this.onAction,
  });

  final CouponBoxState state;
  final void Function(CouponBoxAction) onAction;

  @override
  State<CouponBoxScreen> createState() => _CouponBoxScreenState();
}

class _CouponBoxScreenState extends State<CouponBoxScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, String>> _categories = const [
    {'dbValue': 'all', 'displayName': '전체'},
    {'dbValue': 'restaurant', 'displayName': '식당'},
    {'dbValue': 'cafe', 'displayName': '카페'},
    {'dbValue': 'study_cafe', 'displayName': '스터디카페'},
    {'dbValue': 'salon', 'displayName': '미용실'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.state.tabIndex,
    );
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        widget.onAction(CouponBoxAction.changeTab(_tabController.index));
      }
    });
  }

  @override
  void didUpdateWidget(covariant CouponBoxScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.tabIndex != widget.state.tabIndex) {
      _tabController.animateTo(widget.state.tabIndex);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text(
          '쿠폰함',
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 17,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.tab,
          labelStyle: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
          unselectedLabelStyle: AppTextStyles.body,
          tabs: const [
            Tab(text: '사용 가능 쿠폰'),
            Tab(text: '사용 완료/만료 쿠폰'),
          ],
        ),
      ),
      body: widget.state.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCategoryChips(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildCouponList(tabIndex: 0),
                      _buildCouponList(tabIndex: 1),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCategoryChips() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected =
              widget.state.selectedCategory == category['dbValue'];

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              selected: isSelected,
              label: Text(
                category['displayName']!,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  color: isSelected ? AppColors.white : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
              onSelected: (bool selected) {
                widget.onAction(
                  CouponBoxAction.selectCategory(
                    category['dbValue']!,
                  ),
                );
              },
              backgroundColor: AppColors.surfaceMuted,
              selectedColor: AppColors.primary,
              checkmarkColor: AppColors.white,
              elevation: 0,
              pressElevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? Colors.transparent : AppColors.border,
                  width: 1,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCouponList({required int tabIndex}) {
    final coupons = widget.state.filteredCouponsForTab(tabIndex);

    if (coupons.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.confirmation_number_outlined,
                color: AppColors.textSecondary,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '보유한 쿠폰이 없습니다.',
              style: AppTextStyles.bodySecondary.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: coupons.length,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemBuilder: (context, index) {
        final coupon = coupons[index];
        return _buildCouponCard(coupon);
      },
    );
  }

  Widget _buildCouponCard(Coupon coupon) {
    final isUsed = coupon.usedAt != null;
    final now = DateTime.now();
    final isExpired = coupon.expiredAt.isBefore(now) && !isUsed;
    final isInactive = isUsed || isExpired;

    // 카테고리별 파스텔톤 배경 그라데이션
    final gradientColors = isInactive
        ? [AppColors.surfaceMuted, AppColors.surfaceMuted]
        : _getGradientColors(coupon.storeCategory);

    final iconData = _getCategoryIcon(coupon.storeCategory);
    final categoryLabel = _getCategoryLabel(coupon.storeCategory);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isInactive ? 0.02 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isInactive
              ? AppColors.border
              : AppColors.primary.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isInactive
              ? null
              : () => widget.onAction(CouponBoxAction.tapUseCoupon(coupon.id)),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Row(
              children: [
                // 카테고리 아이콘 뱃지
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: isInactive
                        ? AppColors.border
                        : AppColors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    iconData,
                    color: isInactive
                        ? AppColors.textSecondary
                        : AppColors.primary,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),
                // 쿠폰 정보텍스트
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isInactive
                                  ? AppColors.border
                                  : AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              categoryLabel,
                              style: TextStyle(
                                fontFamily: AppTextStyles.fontFamily,
                                fontSize: 11,
                                color: isInactive
                                    ? AppColors.textSecondary
                                    : AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              coupon.storeName,
                              style: AppTextStyles.bodySecondary.copyWith(
                                color: isInactive
                                    ? AppColors.textSecondary
                                    : AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        coupon.rewardTitle,
                        style: AppTextStyles.titleLarge.copyWith(
                          color: isInactive
                              ? AppColors.textSecondary
                              : AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (coupon.rewardDescription != null &&
                          coupon.rewardDescription!.trim().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          coupon.rewardDescription!,
                          style: AppTextStyles.bodySecondary.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      Divider(
                        color: isInactive
                            ? AppColors.border
                            : AppColors.primary.withValues(alpha: 0.1),
                        height: 1,
                      ),
                      const SizedBox(height: 8),
                      // 사용기한 혹은 사용일자
                      _buildDateInfo(coupon, isUsed, isExpired),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateInfo(Coupon coupon, bool isUsed, bool isExpired) {
    final dateFormat = DateFormat('yyyy.MM.dd');

    if (isUsed) {
      final usedDateStr = dateFormat.format(coupon.usedAt!);
      return Row(
        children: [
          const Icon(
            Icons.check_circle_outline_rounded,
            size: 14,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            '사용완료: $usedDateStr',
            style: const TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      );
    } else if (isExpired) {
      final expiredDateStr = dateFormat.format(coupon.expiredAt);
      return Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 14,
            color: AppColors.danger,
          ),
          const SizedBox(width: 4),
          Text(
            '기간만료 (만료일: $expiredDateStr)',
            style: const TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 12,
              color: AppColors.danger,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      );
    } else {
      final expireDateStr = dateFormat.format(coupon.expiredAt);
      return Row(
        children: [
          const Icon(
            Icons.access_time_rounded,
            size: 14,
            color: AppColors.primary,
          ),
          const SizedBox(width: 4),
          Text(
            '$expireDateStr 까지 사용 가능',
            style: const TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 12,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }
  }

  List<Color> _getGradientColors(String category) {
    switch (category) {
      case 'restaurant':
        return [const Color(0xFFFFECE7), const Color(0xFFFFDCD5)];
      case 'cafe':
        return [const Color(0xFFFBF0E9), const Color(0xFFEFE2D9)];
      case 'study_cafe':
        return [const Color(0xFFE6F7F5), const Color(0xFFD3EFEA)];
      case 'salon':
        return [const Color(0xFFFAF0F8), const Color(0xFFF2DFF0)];
      default:
        return [AppColors.surfaceMuted, AppColors.surfaceMuted];
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'restaurant':
        return Icons.restaurant_rounded;
      case 'cafe':
        return Icons.coffee_rounded;
      case 'study_cafe':
        return Icons.chair_alt_rounded;
      case 'salon':
        return Icons.content_cut_rounded;
      default:
        return Icons.confirmation_number_outlined;
    }
  }

  String _getCategoryLabel(String category) {
    switch (category) {
      case 'restaurant':
        return '식당';
      case 'cafe':
        return '카페';
      case 'study_cafe':
        return '스터디카페';
      case 'salon':
        return '미용실';
      default:
        return '기타';
    }
  }
}
