import 'package:capstone_2026/core/data/data_source/store/store_data_source.dart';
import 'package:capstone_2026/core/data/mapper/store/store_mapper.dart';
import 'package:capstone_2026/core/domain/model/enum/partner_status.dart';
import 'package:capstone_2026/core/domain/model/store/store.dart';
import 'package:capstone_2026/core/domain/repository/auth/auth_repository.dart';
import 'package:capstone_2026/core/domain/repository/store/store_repository.dart';
import 'package:capstone_2026/core/domain/repository/user/user_repository.dart';
import 'package:capstone_2026/core/domain/validator/store_operating_hours_validator.dart';

class StoreRepositoryImpl implements StoreRepository {
  final StoreDataSource _storeDataSource;
  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  final StoreOperatingHoursValidator _operatingHoursValidator;

  const StoreRepositoryImpl({
    required StoreDataSource storeDataSource,
    required AuthRepository authRepository,
    required UserRepository userRepository,
    required StoreOperatingHoursValidator operatingHoursValidator,
  }) : _storeDataSource = storeDataSource,
       _authRepository = authRepository,
       _userRepository = userRepository,
       _operatingHoursValidator = operatingHoursValidator;

  @override
  Future<Store?> getMyStore() async {
    final uid = _getCurrentUidOrThrow();
    final storeDto = await _storeDataSource.findStoreByOwnerId(uid);
    return storeDto?.toModel();
  }

  @override
  Future<Store> createMyStore(Store store) async {
    final uid = await _validateAndGetApprovedUid();
    _validateStoreInput(store);

    final createdStore = await _storeDataSource.createStore(
      store.copyWith(ownerId: uid).toDto(),
    );

    return createdStore.toModel();
  }

  @override
  Future<Store> updateMyStore(Store store) async {
    final uid = await _validateAndGetApprovedUid();
    _validateStoreInput(store);

    final existingStore = await _storeDataSource.findStoreByOwnerId(uid);
    if (existingStore == null) {
      throw StateError('수정할 업장 정보가 존재하지 않습니다.');
    }
    if ((existingStore.businessNumber ?? '').isNotEmpty &&
        existingStore.businessNumber != store.businessNumber) {
      throw StateError('사업자등록번호는 수정할 수 없습니다.');
    }

    final updateDto = store
        .copyWith(
          ownerId: uid,
          businessNumber: existingStore.businessNumber ?? store.businessNumber,
        )
        .toDto();

    final updatedStore = await _storeDataSource.updateStoreById(
      existingStore.id ?? store.id,
      updateDto,
    );

    return updatedStore.toModel();
  }

  String _getCurrentUidOrThrow() {
    final uid = _authRepository.getCurrentUser()?.uid;
    if (uid == null || uid.isEmpty) {
      throw StateError('로그인 정보가 유효하지 않습니다.');
    }
    return uid;
  }

  Future<String> _validateAndGetApprovedUid() async {
    final uid = _getCurrentUidOrThrow();
    final user = await _userRepository.findUserById(uid);
    if (user?.partnerStatus != PartnerStatus.approved) {
      throw StateError('승인된 관리자만 업장 정보를 저장할 수 있습니다.');
    }
    return uid;
  }

  void _validateStoreInput(Store store) {
    if (store.name.trim().isEmpty ||
        store.category.trim().isEmpty ||
        store.businessNumber.trim().isEmpty ||
        store.address.trim().isEmpty ||
        store.contact.trim().isEmpty) {
      throw ArgumentError('업장 필수 입력값이 누락되었습니다.');
    }

    if (store.latitude.isNaN || store.longitude.isNaN) {
      throw ArgumentError('좌표 정보 형식이 올바르지 않습니다.');
    }

    final normalizedBusinessNumber = store.businessNumber.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );
    if (!RegExp(r'^\d{10}$').hasMatch(normalizedBusinessNumber)) {
      throw ArgumentError('사업자등록번호는 숫자 10자리여야 합니다.');
    }

    if (!_operatingHoursValidator.isValid(store.operatingHours)) {
      throw ArgumentError('운영시간 형식이 올바르지 않습니다.');
    }
  }
}
