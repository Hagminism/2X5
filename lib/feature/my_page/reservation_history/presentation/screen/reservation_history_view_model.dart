import 'dart:async';

import 'package:capstone_2026/core/domain/repository/auth/auth_repository.dart';
import 'package:capstone_2026/core/routing/routes.dart';
import 'package:capstone_2026/feature/my_page/reservation_history/domain/repository/user_reservation_history_repository.dart';
import 'package:capstone_2026/feature/my_page/reservation_history/presentation/screen/reservation_history_action.dart';
import 'package:capstone_2026/feature/my_page/reservation_history/presentation/screen/reservation_history_event.dart';
import 'package:capstone_2026/feature/my_page/reservation_history/presentation/screen/reservation_history_state.dart';
import 'package:flutter/material.dart';

class ReservationHistoryViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final UserReservationHistoryRepository _userReservationHistoryRepository;

  ReservationHistoryViewModel({
    required AuthRepository authRepository,
    required UserReservationHistoryRepository userReservationHistoryRepository,
  }) : _authRepository = authRepository,
       _userReservationHistoryRepository = userReservationHistoryRepository;

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
      case TapReservationHistoryReview(:final storeId):
        if (storeId.trim().isEmpty) {
          return;
        }

        // Review tab index is 4 (for Cafe/Restaurant) or 3 (for others).
        // Since we pass showReviewWrite=true, InformationViewModel will try to show it.
        _eventController.add(
          ReservationHistoryEvent.push(
            '${Routes.myPage}/${Routes.reservationHistory}/information/${storeId.trim()}?tab=4&showReviewWrite=true',
          ),
        );
        break;
    }
  }

  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }
}
