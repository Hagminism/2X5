import 'dart:async';

import 'package:capstone_2026/core/data/data_source/store/store_data_source.dart';
import 'package:capstone_2026/core/data/data_source/studycafe/studycafe_data_source.dart';
import 'package:capstone_2026/core/domain/model/studycafe/studycafe_detail.dart';
import 'package:capstone_2026/core/domain/model/studycafe/studycafe_layout_coordinate_normalizer.dart';
import 'package:capstone_2026/core/domain/model/studycafe/studycafe_reservation.dart';
import 'package:capstone_2026/core/domain/repository/auth/auth_repository.dart';
import 'package:capstone_2026/core/domain/repository/studycafe/studycafe_repository.dart';

class StudyCafeRepositoryImpl implements StudyCafeRepository {
  final StudyCafeDataSource _studyCafeDataSource;
  final StoreDataSource _storeDataSource;
  final AuthRepository _authRepository;

  const StudyCafeRepositoryImpl({
    required StudyCafeDataSource studyCafeDataSource,
    required StoreDataSource storeDataSource,
    required AuthRepository authRepository,
  }) : _studyCafeDataSource = studyCafeDataSource,
       _storeDataSource = storeDataSource,
       _authRepository = authRepository;

  @override
  Future<StudyCafeDetail?> getDetailByStoreId(String storeId) async {
    final detail = await _studyCafeDataSource.findDetailByStoreId(storeId);
    if (detail == null) {
      return null;
    }
    return StudyCafeLayoutCoordinateNormalizer.normalizeDetail(detail);
  }

  @override
  Future<StudyCafeDetail> getMyStoreDetail() async {
    final storeId = await _getMyStoreIdOrThrow();
    final detail = await _studyCafeDataSource.findDetailByStoreId(storeId);
    final base = detail ?? StudyCafeDetail.empty(storeId);
    return StudyCafeLayoutCoordinateNormalizer.normalizeDetail(base);
  }

  @override
  Future<StudyCafeDetail> saveMyStoreDetail(StudyCafeDetail detail) async {
    final storeId = await _getMyStoreIdOrThrow();
    final normalized = StudyCafeLayoutCoordinateNormalizer.normalizeDetail(
      detail,
    );
    final saved = await _studyCafeDataSource.upsertDetail(
      normalized.copyWith(storeId: storeId),
    );
    return StudyCafeLayoutCoordinateNormalizer.normalizeDetail(saved);
  }

  @override
  Future<List<StudyCafeReservation>> getActiveReservationsByStoreId(
    String storeId,
  ) {
    return _studyCafeDataSource.findActiveReservationsByStoreId(storeId);
  }

  @override
  Stream<List<StudyCafeReservation>> watchActiveReservationsByStoreId(
    String storeId,
  ) {
    return _studyCafeDataSource.watchActiveReservationsByStoreId(storeId);
  }

  @override
  Future<StudyCafeReservation> startUsage({
    required String storeId,
    required String seatId,
    required int durationMinutes,
  }) {
    return _studyCafeDataSource.startUsage(
      storeId: storeId,
      userId: _getCurrentUidOrThrow(),
      seatId: seatId,
      durationMinutes: durationMinutes,
    );
  }

  @override
  Future<StudyCafeReservation> extendUsage({
    required String reservationId,
    required int additionalMinutes,
  }) {
    return _studyCafeDataSource.extendUsage(
      reservationId: reservationId,
      userId: _getCurrentUidOrThrow(),
      additionalMinutes: additionalMinutes,
    );
  }

  Future<String> _getMyStoreIdOrThrow() async {
    final uid = _getCurrentUidOrThrow();
    final store = await _storeDataSource.findStoreByOwnerId(uid);
    if (store?.id == null || store!.id!.isEmpty) {
      throw StateError('업장 정보 저장 후 좌석 배치를 설정할 수 있습니다.');
    }
    return store.id!;
  }

  String _getCurrentUidOrThrow() {
    final uid = _authRepository.getCurrentUser()?.uid;
    if (uid == null || uid.isEmpty) {
      throw StateError('로그인 정보가 유효하지 않습니다.');
    }
    return uid;
  }
}
