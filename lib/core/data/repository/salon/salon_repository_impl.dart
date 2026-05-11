import 'package:capstone_2026/core/data/data_source/salon/salon_data_source.dart';
import 'package:capstone_2026/core/data/data_source/store/store_data_source.dart';
import 'package:capstone_2026/core/domain/model/salon/salon_designer.dart';
import 'package:capstone_2026/core/domain/model/salon/salon_designer_schedule.dart';
import 'package:capstone_2026/core/domain/model/salon/salon_reservation.dart';
import 'package:capstone_2026/core/domain/model/salon/salon_service.dart';
import 'package:capstone_2026/core/domain/repository/auth/auth_repository.dart';
import 'package:capstone_2026/core/domain/repository/salon/salon_repository.dart';

class SalonRepositoryImpl implements SalonRepository {
  final SalonDataSource _salonDataSource;
  final StoreDataSource _storeDataSource;
  final AuthRepository _authRepository;

  const SalonRepositoryImpl({
    required SalonDataSource salonDataSource,
    required StoreDataSource storeDataSource,
    required AuthRepository authRepository,
  }) : _salonDataSource = salonDataSource,
       _storeDataSource = storeDataSource,
       _authRepository = authRepository;

  @override
  Future<List<SalonDesigner>> getDesignersByStoreId(String storeId) {
    return _salonDataSource.findDesignersByStoreId(storeId);
  }

  @override
  Future<List<SalonService>> getServicesByStoreId(String storeId) {
    return _salonDataSource.findServicesByStoreId(storeId);
  }

  @override
  Future<List<SalonDesignerSchedule>> getSchedulesByDesignerId(
    String designerId,
  ) {
    return _salonDataSource.findSchedulesByDesignerId(designerId);
  }

  @override
  Future<List<SalonDesigner>> saveMyStoreDesigners(
    List<SalonDesigner> designers,
  ) async {
    final storeId = await _getMyStoreIdOrThrow();
    return _salonDataSource.upsertDesigners(
      designers.map((designer) => designer.copyWith(storeId: storeId)).toList(),
    );
  }

  @override
  Future<List<SalonService>> saveMyStoreServices(
    List<SalonService> services,
  ) async {
    final storeId = await _getMyStoreIdOrThrow();
    return _salonDataSource.upsertServices(
      services.map((service) => service.copyWith(storeId: storeId)).toList(),
    );
  }

  @override
  Future<SalonReservation> createReservation({
    required String storeId,
    required String designerId,
    required String serviceId,
    required DateTime startAt,
  }) {
    return _salonDataSource.createReservation(
      storeId: storeId,
      userId: _getCurrentUidOrThrow(),
      designerId: designerId,
      serviceId: serviceId,
      startAt: startAt,
    );
  }

  Future<String> _getMyStoreIdOrThrow() async {
    final uid = _getCurrentUidOrThrow();
    final store = await _storeDataSource.findStoreByOwnerId(uid);
    if (store?.id == null || store!.id!.isEmpty) {
      throw StateError('업장 정보 저장 후 미용실 정보를 설정할 수 있습니다.');
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
