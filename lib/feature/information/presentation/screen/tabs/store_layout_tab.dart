import 'package:capstone_2026/core/domain/model/store/store_layout_detail.dart';
import 'package:capstone_2026/feature/seat_selection/presentation/component/seat_selection_layout_canvas.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:flutter/material.dart';

class StoreLayoutTab extends StatefulWidget {
  final StoreLayoutDetail? layoutDetail;
  final bool isReservationAvailable;

  const StoreLayoutTab({
    super.key,
    required this.layoutDetail,
    required this.isReservationAvailable,
  });

  @override
  State<StoreLayoutTab> createState() => _StoreLayoutTabState();
}

class _StoreLayoutTabState extends State<StoreLayoutTab>{
  @override
  Widget build(BuildContext context) {
    final isReservationAvailable = widget.isReservationAvailable;
    final layoutDetail = widget.layoutDetail;

    if (!isReservationAvailable) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: _NotOnboardedLayoutBody(),
      );
    }

    final detail = layoutDetail;
    if (detail == null || (detail.elements.isEmpty && detail.seats.isEmpty)) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: _NoLayoutDataBody(),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: SeatSelectionLayoutCanvas(
          elements: detail.elements,
          seats: detail.seats,
          occupiedSeatIds: const [],
          selectedSeatId: null,
          onSeatTap: (_) {},
        ),
      ),
    );
  }
}

class _NotOnboardedLayoutBody extends StatelessWidget {
  const _NotOnboardedLayoutBody();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFF7F8FA),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Icon(
                Icons.storefront_outlined,
                size: 36,
                color: AppColors.textSecondary.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '아직 입점하지 않은 매장입니다',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                color: AppColors.textPrimary,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '이 매장은 정보 조회만 가능합니다.\n내부 구조는 입점 후 확인할 수 있어요.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.1,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoLayoutDataBody extends StatelessWidget {
  const _NoLayoutDataBody();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFF7F8FA),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Icon(
                Icons.layers_clear_outlined,
                size: 36,
                color: AppColors.textSecondary.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '등록된 내부 구조가 없습니다',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                color: AppColors.textPrimary,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '아직 매장의 내부 구조 정보가 등록되지 않았습니다.\n매장에서 준비 중입니다.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.1,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
