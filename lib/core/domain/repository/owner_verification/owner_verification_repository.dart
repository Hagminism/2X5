abstract interface class OwnerVerificationRepository {
  Future<String?> getMyApprovedBusinessNumber();
}
