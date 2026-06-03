import 'dart:async';

import 'package:capstone_2026/core/domain/model/enum/reservation_status.dart';
import 'package:capstone_2026/core/domain/model/reservation/reservation.dart';
import 'package:capstone_2026/core/domain/repository/reservation/reservation_repository.dart';
import 'package:capstone_2026/core/domain/repository/store/store_repository.dart';
import 'package:capstone_2026/feature/partner_dashboard/presentation/screen/partner_dashboard_event.dart';
import 'package:capstone_2026/feature/partner_dashboard/presentation/screen/partner_dashboard_state.dart';
import 'package:flutter/foundation.dart';

class PartnerDashboardViewModel extends ChangeNotifier {
  final StoreRepository _storeRepository;
  final ReservationRepository _reservationRepository;

  PartnerDashboardViewModel({
    required StoreRepository storeRepository,
    required ReservationRepository reservationRepository,
  }) : _storeRepository = storeRepository,
       _reservationRepository = reservationRepository;

  PartnerDashboardState _state = const PartnerDashboardState();

  PartnerDashboardState get state => _state;

  final StreamController<PartnerDashboardEvent> _eventController =
      StreamController<PartnerDashboardEvent>.broadcast();

  Stream<PartnerDashboardEvent> get eventStream => _eventController.stream;

  Future<void> fetch() async {
    if (state.isLoading) {
      return;
    }

    _state = state.copyWith(isLoading: true);
    notifyListeners();

    try {
      final store = await _storeRepository.getMyStore();
      final storeId = store?.id;
      if (storeId == null || storeId.isEmpty) {
        _state = state.copyWith(
          isLoading: false,
          todayPendingCount: 0,
          todayConfirmedCount: 0,
          todayCancelledCount: 0,
          summaryMessage: '등록된 업장이 없습니다. 업장 관리에서 정보를 등록해 주세요.',
        );
        notifyListeners();
        return;
      }

      final today = DateTime.now();
      final todayReservations = await _reservationRepository
          .getReservationsByStoreAndDate(
            storeId: storeId,
            date: today,
          );

      _state = state.copyWith(
        isLoading: false,
        todayPendingCount: _countByStatus(
          todayReservations,
          ReservationStatus.pending,
        ),
        todayConfirmedCount: _countByStatus(
          todayReservations,
          ReservationStatus.confirmed,
        ),
        todayCancelledCount: _countByStatus(
          todayReservations,
          ReservationStatus.cancelled,
        ),
        summaryMessage: _buildSummaryMessage(todayReservations),
      );
      notifyListeners();
    } catch (_) {
      _state = state.copyWith(isLoading: false);
      notifyListeners();
      _eventController.add(
        const PartnerDashboardEvent.showMessage(
          '대시보드 정보를 불러오지 못했습니다. 잠시 후 다시 시도해 주세요.',
        ),
      );
    }
  }

  int _countByStatus(
    List<Reservation> reservations,
    ReservationStatus status,
  ) {
    return reservations.where((item) => item.status == status).length;
  }

  String _buildSummaryMessage(List<Reservation> todayReservations) {
    if (todayReservations.isEmpty) {
      return '오늘 예약이 없습니다.';
    }

    final activeReservations = todayReservations
        .where(
          (item) =>
              item.status == ReservationStatus.pending ||
              item.status == ReservationStatus.confirmed,
        )
        .toList();

    if (activeReservations.isEmpty) {
      return '오늘 활성 예약이 없습니다.';
    }

    final sortedByTime = [...activeReservations]
      ..sort((a, b) => a.bookingTime.compareTo(b.bookingTime));
    final firstReservation = sortedByTime.first;

    final peakMessage = _buildPeakHourMessage(activeReservations);
    if (peakMessage == null) {
      return '오늘 첫 예약이 ${firstReservation.bookingTime}에 예정되어 있어요.';
    }

    return '오늘 첫 예약은 ${firstReservation.bookingTime}입니다. $peakMessage';
  }

  String? _buildPeakHourMessage(List<Reservation> reservations) {
    final hourCounts = <int, int>{};
    for (final reservation in reservations) {
      final hour = _parseHour(reservation.bookingTime);
      if (hour == null) {
        continue;
      }
      hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
    }

    if (hourCounts.isEmpty) {
      return null;
    }

    final peakEntry = hourCounts.entries.reduce(
      (current, next) => next.value > current.value ? next : current,
    );
    if (peakEntry.value < 2) {
      return null;
    }

    final peakHour = peakEntry.key;
    final endHour = peakHour + 1;
    return '가장 많은 예약이 ${peakHour.toString().padLeft(2, '0')}:00~${endHour.toString().padLeft(2, '0')}:00에 몰려 있어요.';
  }

  int? _parseHour(String bookingTime) {
    final trimmed = bookingTime.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    final parts = trimmed.split(':');
    if (parts.isEmpty) {
      return null;
    }

    return int.tryParse(parts.first);
  }

  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }
}
