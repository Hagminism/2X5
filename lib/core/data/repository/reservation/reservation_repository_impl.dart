import 'package:capstone_2026/core/data/data_source/reservation/reservation_data_source.dart';
import 'package:capstone_2026/core/data/data_source/store/store_data_source.dart';
import 'package:capstone_2026/core/data/mapper/reservation/reservation_mapper.dart';
import 'package:capstone_2026/core/data/mapper/reservation/store_reservation_slot_mapper.dart';
import 'package:capstone_2026/core/domain/model/enum/reservation_status.dart';
import 'package:capstone_2026/core/domain/model/reservation/reservation.dart';
import 'package:capstone_2026/core/domain/model/reservation/restaurant_time_slot.dart';
import 'package:capstone_2026/core/domain/model/reservation/store_reservation_slot_default.dart';
import 'package:capstone_2026/core/domain/model/reservation/store_schedule_exception.dart';
import 'package:capstone_2026/core/domain/model/store/store.dart';
import 'package:capstone_2026/core/domain/repository/auth/auth_repository.dart';
import 'package:capstone_2026/core/domain/repository/reservation/reservation_repository.dart';
import 'package:capstone_2026/core/util/restaurant_booking_slot.dart';

class ReservationRepositoryImpl implements ReservationRepository {
  final ReservationDataSource _reservationDataSource;
  final StoreDataSource _storeDataSource;
  final AuthRepository _authRepository;

  const ReservationRepositoryImpl({
    required ReservationDataSource reservationDataSource,
    required StoreDataSource storeDataSource,
    required AuthRepository authRepository,
  }) : _reservationDataSource = reservationDataSource,
       _storeDataSource = storeDataSource,
       _authRepository = authRepository;

  @override
  Future<List<Reservation>> fetchReservations() async {
    final uid = _getCurrentUidOrThrow();
    final myStore = await _storeDataSource.findStoreByOwnerId(uid);
    if (myStore?.id == null || myStore!.id!.isEmpty) {
      return [];
    }

    final reservations = await _reservationDataSource.findReservationsByStoreId(
      myStore.id!,
    );
    return reservations.map((dto) => dto.toModel()).toList();
  }

  @override
  Future<List<Reservation>> getReservationsByStoreAndDate({
    required String storeId,
    required DateTime date,
  }) async {
    final reservations = await _reservationDataSource
        .findReservationsByStoreIdAndDate(
          storeId: storeId,
          bookingDate: _formatDate(date),
        );
    return reservations.map((dto) => dto.toModel()).toList();
  }

  @override
  Future<Reservation> createReservation({
    required String storeId,
    required DateTime bookingDate,
    required String bookingTime,
    required int guestCount,
    String? customerRequest,
  }) async {
    final dto = await _reservationDataSource.createReservationViaCallable(
      storeId: storeId,
      bookingDate: _formatDate(bookingDate),
      bookingTime: bookingTime,
      guestCount: guestCount,
      customerRequest: customerRequest,
    );
    return dto.toModel();
  }

  @override
  Future<List<StoreReservationSlotDefault>> getSlotDefaultsByStoreId(
    String storeId,
  ) async {
    final dtos = await _reservationDataSource.findSlotDefaultsByStoreId(
      storeId,
    );
    return dtos.map((dto) => dto.toModel()).toList();
  }

  @override
  Future<void> saveSlotDefaults({
    required String storeId,
    required List<StoreReservationSlotDefault> defaults,
  }) async {
    await _reservationDataSource.saveSlotDefaults(
      storeId: storeId,
      defaults: defaults.map((item) => item.toDto()).toList(),
    );
  }

  @override
  Future<StoreScheduleException?> getScheduleException({
    required String storeId,
    required DateTime date,
  }) async {
    final dto = await _reservationDataSource.findScheduleException(
      storeId: storeId,
      exceptionDate: _formatDate(date),
    );
    return dto?.toModel();
  }

  @override
  Future<StoreScheduleException> upsertScheduleException(
    StoreScheduleException exception,
  ) async {
    final dto = await _reservationDataSource.upsertScheduleException(
      exception.toDto(),
    );
    return dto.toModel();
  }

  @override
  Future<void> deleteScheduleException({
    required String storeId,
    required DateTime date,
  }) async {
    await _reservationDataSource.deleteScheduleException(
      storeId: storeId,
      exceptionDate: _formatDate(date),
    );
  }

  @override
  Future<List<RestaurantTimeSlot>> getAvailabilityForDate({
    required Store store,
    required DateTime date,
  }) async {
    final calendarDate = DateTime(date.year, date.month, date.day);
    final results = await (
      getSlotDefaultsByStoreId(store.id),
      getScheduleException(storeId: store.id, date: calendarDate),
      getReservationsByStoreAndDate(storeId: store.id, date: calendarDate),
    ).wait;

    return RestaurantBookingSlot.buildSlotsForDate(
      store: store,
      targetDate: calendarDate,
      slotDefaults: results.$1,
      scheduleException: results.$2,
      reservations: results.$3,
    );
  }

  @override
  Future<Reservation> updateReservationStatus({
    required String reservationId,
    required ReservationStatus status,
  }) async {
    final updatedDto = await _reservationDataSource.updateReservationStatus(
      reservationId: reservationId,
      status: status.dbValue,
    );
    return updatedDto.toModel();
  }

  String _getCurrentUidOrThrow() {
    final uid = _authRepository.getCurrentUser()?.uid;
    if (uid == null || uid.isEmpty) {
      throw StateError('로그인 정보가 유효하지 않습니다.');
    }

    return uid;
  }

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
