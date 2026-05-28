import 'dart:async';

import 'package:capstone_2026/core/domain/repository/auth/auth_repository.dart';
import 'package:capstone_2026/core/routing/routes.dart';
import 'package:capstone_2026/feature/stamp/domain/service/stamp_service.dart';
import 'package:capstone_2026/feature/store_detail/domain/service/store_review_service.dart';
import 'package:capstone_2026/feature/store_detail/presentation/component/review_write_bottom_sheet.dart';
import 'package:capstone_2026/feature/my_page/reservation_history/domain/repository/user_reservation_history_repository.dart';
import 'package:capstone_2026/feature/my_page/reservation_history/presentation/screen/reservation_history_action.dart';
import 'package:capstone_2026/feature/my_page/reservation_history/presentation/screen/reservation_history_event.dart';
import 'package:capstone_2026/feature/my_page/reservation_history/presentation/screen/reservation_history_state.dart';
import 'package:flutter/material.dart';

class ReservationHistoryViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final UserReservationHistoryRepository _userReservationHistoryRepository;
  final StoreReviewService _storeReviewService;
  final StampService _stampService;

  ReservationHistoryViewModel({
    required AuthRepository authRepository,
    required UserReservationHistoryRepository userReservationHistoryRepository,
    required StoreReviewService storeReviewService,
    required StampService stampService,
  }) : _authRepository = authRepository,
       _userReservationHistoryRepository = userReservationHistoryRepository,
       _storeReviewService = storeReviewService,
       _stampService = stampService;

  ReservationHistoryState _state = const ReservationHistoryState();

  ReservationHistoryState get state => _state;

  final StreamController<ReservationHistoryEvent> _eventController =
      StreamController<ReservationHistoryEvent>.broadcast();

  Stream<ReservationHistoryEvent> get eventStream => _eventController.stream;

  Future<void> fetchHistory() async {
    if (_state.isLoading) {
      return;
    }

    final user = _authRepository.getCurrentUser();
    if (user == null) {
      _state = _state.copyWith(items: const [], isLoading: false);
      notifyListeners();
      return;
    }

    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    try {
      final items = await _userReservationHistoryRepository
          .fetchUserReservationHistory(
            userId: user.uid,
          );

      _state = _state.copyWith(
        isLoading: false,
        items: items,
      );
    } catch (_) {
      _state = _state.copyWith(isLoading: false);
      _eventController.add(
        const ReservationHistoryEvent.showSnackBar(
          '이용 내역을 불러오지 못했습니다.',
        ),
      );
    }

    notifyListeners();
  }

  void onAction(ReservationHistoryAction action) {
    switch (action) {
      case TapReservationHistoryBack():
        _eventController.add(const ReservationHistoryEvent.pop());
        break;
      case TapReservationHistoryItem(:final storeId):
        if (storeId.trim().isEmpty) {
          return;
        }

        _eventController.add(
          ReservationHistoryEvent.push(
            '${Routes.myPage}/${Routes.reservationHistory}/information/${storeId.trim()}',
          ),
        );
        break;
      case TapReservationHistoryReview(
        :final storeId,
        :final storeName,
        :final reservationId,
      ):
        if (storeId.trim().isEmpty || reservationId.trim().isEmpty) {
          return;
        }

        _eventController.add(
          ReservationHistoryEvent.showReviewBottomSheet(
            storeId: storeId.trim(),
            storeName: storeName.trim(),
            reservationId: reservationId.trim(),
          ),
        );
        break;
      case SubmitReservationHistoryReview(
        :final storeId,
        :final storeName,
        :final reservationId,
        :final reviewResult,
      ):
        _submitReview(
          storeId: storeId,
          storeName: storeName,
          reservationId: reservationId,
          result: reviewResult,
        );
        break;
    }
  }

  Future<void> _submitReview({
    required String storeId,
    required String storeName,
    required String reservationId,
    required ReviewWriteResult result,
  }) async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    try {
      await _storeReviewService.submitReview(
        storeId: storeId,
        storeName: storeName,
        review: result,
        reservationId: reservationId,
      );

      await _stampService.accrueStampForReview(
        storeId: storeId,
      );

      _eventController.add(
        const ReservationHistoryEvent.showSnackBar(
          '리뷰가 등록되었으며 스탬프 1개가 적립되었습니다.',
        ),
      );

      _state = _state.copyWith(isLoading: false);
      notifyListeners();

      await fetchHistory();
    } catch (e) {
      _state = _state.copyWith(isLoading: false);
      notifyListeners();
      _eventController.add(
        const ReservationHistoryEvent.showSnackBar(
          '리뷰 등록 중 오류가 발생했습니다.',
        ),
      );
    }
  }

  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }
}
