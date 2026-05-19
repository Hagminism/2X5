abstract interface class UserReservationHistoryDataSource {
  Future<List<Map<String, dynamic>>> fetchRestaurantReservationsByUserId(
    String userId,
  );

  Future<List<Map<String, dynamic>>> fetchStudyCafeReservationsByUserId(
    String userId,
  );

  Future<List<Map<String, dynamic>>> fetchSalonReservationsByUserId(
    String userId,
  );
}
