import 'package:capstone_2026/core/domain/repository/auth/auth_repository.dart';
import 'package:capstone_2026/feature/stamp/domain/model/store_stamp_status.dart';
import 'package:capstone_2026/feature/stamp/domain/repository/stamp_repository.dart';

class StampService {
  StampService({
    required StampRepository stampRepository,
    required AuthRepository authRepository,
  }) : _stampRepository = stampRepository,
       _authRepository = authRepository;

  final StampRepository _stampRepository;
  final AuthRepository _authRepository;

  Future<StoreStampStatus> loadStoreStampStatus({
    required String storeId,
  }) {
    return _stampRepository.fetchStoreStampStatus(
      userId: _authRepository.getCurrentUserId(),
      storeId: storeId,
    );
  }

  Future<List<StoreStampStatus>> loadMyStampStatuses() {
    return _stampRepository.fetchUserStampStatuses(
      userId: _authRepository.getCurrentUserId(),
    );
  }

  Future<StoreStampStatus> accrueStampForReview({
    required String storeId,
  }) {
    return _stampRepository.accrueStampForReview(
      userId: _authRepository.getCurrentUserId(),
      storeId: storeId,
    );
  }

  Future<StoreStampStatus> revokeStampForDeletedReview({
    required String storeId,
  }) {
    return _stampRepository.revokeStampForDeletedReview(
      userId: _authRepository.getCurrentUserId(),
      storeId: storeId,
    );
  }

  Future<StoreStampStatus> claimReward({
    required String storeId,
  }) {
    return _stampRepository.claimReward(
      userId: _authRepository.getCurrentUserId(),
      storeId: storeId,
    );
  }
}
