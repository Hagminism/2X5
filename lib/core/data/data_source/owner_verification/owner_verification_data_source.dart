abstract interface class OwnerVerificationDataSource {
  Future<String?> findLatestApprovedBusinessNumberByOwnerId(String ownerId);
}
