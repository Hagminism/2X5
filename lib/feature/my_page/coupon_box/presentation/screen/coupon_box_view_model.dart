import 'package:capstone_2026/core/presentation/util/app_snack_bar.dart';
import 'dart:async';

import 'package:capstone_2026/core/domain/repository/auth/auth_repository.dart';
import 'package:capstone_2026/feature/my_page/coupon_box/domain/repository/coupon_repository.dart';
import 'package:capstone_2026/feature/my_page/coupon_box/presentation/screen/coupon_box_action.dart';
import 'package:capstone_2026/feature/my_page/coupon_box/presentation/screen/coupon_box_event.dart';
import 'package:capstone_2026/feature/my_page/coupon_box/presentation/screen/coupon_box_state.dart';
import 'package:flutter/foundation.dart';

class CouponBoxViewModel extends ChangeNotifier {
  CouponBoxViewModel({
    required CouponRepository couponRepository,
    required AuthRepository authRepository,
  }) : _couponRepository = couponRepository,
       _authRepository = authRepository;

  final CouponRepository _couponRepository;
  final AuthRepository _authRepository;

  CouponBoxState _state = const CouponBoxState();
  CouponBoxState get state => _state;

  final StreamController<CouponBoxEvent> _eventController =
      StreamController<CouponBoxEvent>.broadcast();
  Stream<CouponBoxEvent> get eventStream => _eventController.stream;

  void onAction(CouponBoxAction action) {
    switch (action) {
      case ChangeTab():
        _state = _state.copyWith(tabIndex: action.index);
        notifyListeners();
        break;
      case SelectCategory():
        _state = _state.copyWith(selectedCategory: action.category);
        notifyListeners();
        break;
      case TapUseCoupon():
        final coupon = _state.coupons.firstWhere(
          (c) => c.id == action.couponId,
        );
        _eventController.add(
          CouponBoxEvent.showUseConfirmationDialog(
            couponId: coupon.id,
            storeName: coupon.storeName,
            rewardTitle: coupon.rewardTitle,
          ),
        );
        break;
      case ConfirmUseCoupon():
        _useCoupon(action.couponId);
        break;
    }
  }

  Future<void> loadCoupons() async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    try {
      final userId = _authRepository.getCurrentUserId();
      final list = await _couponRepository.fetchUserCoupons(userId: userId);
      _state = _state.copyWith(
        isLoading: false,
        coupons: list,
      );
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(isLoading: false);
      notifyListeners();
      _eventController.add(
        const CouponBoxEvent.showMessage('쿠폰 목록을 불러오는 중 오류가 발생했습니다.'),
      );
    }
  }

  Future<void> _useCoupon(String couponId) async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    try {
      await _couponRepository.useCoupon(couponId: couponId);
      _eventController.add(const CouponBoxEvent.showMessage('쿠폰 사용이 완료되었습니다.', variant: AppSnackBarVariant.success));
      await loadCoupons();
    } catch (e) {
      _state = _state.copyWith(isLoading: false);
      notifyListeners();
      _eventController.add(
        const CouponBoxEvent.showMessage('쿠폰 사용 처리 중 오류가 발생했습니다.'),
      );
    }
  }

  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }
}
