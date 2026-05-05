import 'package:capstone_2026/core/data/data_source/reservation/reservation_data_source.dart';
import 'package:capstone_2026/core/data/data_source/store/store_data_source.dart';
import 'package:capstone_2026/core/data/mapper/reservation/reservation_mapper.dart';
import 'package:capstone_2026/core/domain/model/enum/reservation_status.dart';
import 'package:capstone_2026/core/domain/model/reservation/reservation.dart';
import 'package:capstone_2026/core/domain/repository/auth/auth_repository.dart';
import 'package:capstone_2026/core/domain/repository/reservation/reservation_repository.dart';

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
}
