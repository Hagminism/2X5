import 'package:capstone_2026/core/data/data_source/owner_verification/owner_verification_data_source.dart';
import 'package:capstone_2026/core/domain/repository/auth/auth_repository.dart';
import 'package:capstone_2026/core/domain/repository/owner_verification/owner_verification_repository.dart';

class OwnerVerificationRepositoryImpl implements OwnerVerificationRepository {
  final OwnerVerificationDataSource _ownerVerificationDataSource;
  final AuthRepository _authRepository;

  const OwnerVerificationRepositoryImpl({
    required OwnerVerificationDataSource ownerVerificationDataSource,
    required AuthRepository authRepository,
  }) : _ownerVerificationDataSource = ownerVerificationDataSource,
       _authRepository = authRepository;

  @override
  Future<String?> getMyApprovedBusinessNumber() async {
    final uid = _authRepository.getCurrentUser()?.uid;
    if (uid == null || uid.isEmpty) {
      throw StateError('로그인 정보가 유효하지 않습니다.');
    }

    return _ownerVerificationDataSource
        .findLatestApprovedBusinessNumberByOwnerId(
          uid,
        );
  }
}
