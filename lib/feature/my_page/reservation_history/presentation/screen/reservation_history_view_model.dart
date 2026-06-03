import 'dart:async';

import 'package:capstone_2026/core/domain/model/review/review_reservation_ref.dart';
import 'package:capstone_2026/core/domain/repository/auth/auth_repository.dart';
import 'package:capstone_2026/feature/my_page/reservation_history/domain/model/user_reservation_history_type.dart';
import 'package:capstone_2026/feature/my_page/reservation_history/domain/model/user_reservation_history_type_review_extension.dart';
import 'package:capstone_2026/core/presentation/util/app_snack_bar.dart';
import 'package:capstone_2026/core/presentation/util/review_submit_error_message.dart';
import 'package:capstone_2026/core/routing/routes.dart';
import 'package:capstone_2026/feature/my_page/reservation_history/domain/repository/user_reservation_history_repository.dart';
import 'package:capstone_2026/feature/my_page/reservation_history/presentation/screen/reservation_history_action.dart';
import 'package:capstone_2026/feature/my_page/reservation_history/presentation/screen/reservation_history_event.dart';
import 'package:capstone_2026/feature/my_page/reservation_history/presentation/screen/reservation_history_state.dart';
import 'package:capstone_2026/feature/stamp/domain/service/stamp_service.dart';
import 'package:capstone_2026/feature/store_detail/domain/service/store_review_service.dart';
import 'package:capstone_2026/feature/store_detail/presentation/component/review_write_bottom_sheet.dart';
import 'package:flutter/material.dart';

class ReservationHistoryViewModel extends ChangeNotifier {
  ReservationHistoryViewModel({
    required AuthRepository authRepository,
    required UserReservationHistoryRepository userReservationHistoryRepository,
    required StoreReviewService storeReviewService,
    required StampService stampService,
  }) : _authRepository = authRepository,
       _userReservationHistoryRepository = userReservationHistoryRepository,
       _storeReviewService = storeReviewService,
       _stampService = stampService;

  final AuthRepository _authRepository;
  final UserReservationHistoryRepository _userReservationHistoryRepository;
  final StoreReviewService _storeReviewService;
  final StampService _stampService;

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
      _state = state.copyWith(items: const [], isLoading: false);
      notifyListeners();
      return;
    }

    _state = state.copyWith(isLoading: true);
    notifyListeners();

    try {
      final items =
          await _userReservationHistoryRepository.fetchUserReservationHistory(
            userId: user.uid,
          );

      _state = state.copyWith(
        isLoading: false,
        items: items,
      );
      notifyListeners();
    } catch (_) {
      _state = state.copyWith(isLoading: false);
      notifyListeners();
      _eventController.add(
        const ReservationHistoryEvent.showSnackBar(
          '이용 내역을 불러오지 못했습니다.',
        ),
      );
    }
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
        :final reservationType,
      ):
        _eventController.add(
          ReservationHistoryEvent.showReviewBottomSheet(
            storeId: storeId,
            storeName: storeName,
            reservationId: reservationId,
            reservationType: reservationType,
          ),
        );
        break;
    }
  }

  Future<void> submitReview({
    required String storeId,
    required String storeName,
    required String reservationId,
    required UserReservationHistoryType reservationType,
    required ReviewWriteResult result,
  }) async {
    final reservationRef = ReviewReservationRef(
      source: reservationType.reviewReservationSource,
      reservationId: reservationId,
    );

    try {
      await _storeReviewService.submitReview(
        storeId: storeId,
        storeName: storeName,
        review: result,
        reservationRef: reservationRef,
      );
      await _stampService.accrueStampForReview(storeId: storeId);
      await fetchHistory();

      _eventController.add(
        const ReservationHistoryEvent.showSnackBar(
          '리뷰가 등록되었습니다. 스탬프 1개가 적립되었습니다.',
          variant: AppSnackBarVariant.success,
        ),
      );
    } catch (error) {
      _eventController.add(
        ReservationHistoryEvent.showSnackBar(
          reviewSubmitErrorMessage(error),
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
