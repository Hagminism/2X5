import 'package:capstone_2026/core/domain/model/enum/reservation_status.dart';
import 'package:capstone_2026/core/domain/model/enum/store_category.dart';
import 'package:capstone_2026/feature/my_page/reservation_history/data/data_source/user_reservation_history_data_source.dart';
import 'package:capstone_2026/feature/my_page/reservation_history/domain/model/user_reservation_history_item.dart';
import 'package:capstone_2026/feature/my_page/reservation_history/domain/model/user_reservation_history_type.dart';
import 'package:capstone_2026/feature/my_page/reservation_history/domain/repository/user_reservation_history_repository.dart';
import 'package:intl/intl.dart';

class UserReservationHistoryRepositoryImpl
    implements UserReservationHistoryRepository {
  UserReservationHistoryRepositoryImpl({
    required UserReservationHistoryDataSource dataSource,
  }) : _dataSource = dataSource;

  final UserReservationHistoryDataSource _dataSource;

  @override
  Future<List<UserReservationHistoryItem>> fetchUserReservationHistory({
    required String userId,
  }) async {
    final (restaurantRows, studyCafeRows, salonRows, reviewRows) = await (
      _dataSource.fetchRestaurantReservationsByUserId(userId),
      _dataSource.fetchStudyCafeReservationsByUserId(userId),
      _dataSource.fetchSalonReservationsByUserId(userId),
      _dataSource.fetchReviewsByUserId(userId),
    ).wait;

    final reviewedRestaurantReservationIds = reviewRows
        .map((row) => row['restaurant_reservation_id']?.toString())
        .whereType<String>()
        .toSet();
    final reviewedStudyCafeReservationIds = reviewRows
        .map((row) => row['studycafe_reservation_id']?.toString())
        .whereType<String>()
        .toSet();
    final reviewedSalonReservationIds = reviewRows
        .map((row) => row['salon_reservation_id']?.toString())
        .whereType<String>()
        .toSet();

    final items = <UserReservationHistoryItem>[
      ...restaurantRows.map(
        (row) => _mapRestaurantRow(
          row,
          reviewedRestaurantReservationIds,
        ),
      ),
      ...studyCafeRows.map(
        (row) => _mapStudyCafeRow(
          row,
          reviewedStudyCafeReservationIds,
        ),
      ),
      ...salonRows.map(
        (row) => _mapSalonRow(
          row,
          reviewedSalonReservationIds,
        ),
      ),
    ]..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));

    return items;
  }

  UserReservationHistoryItem _mapRestaurantRow(
    Map<String, dynamic> row,
    Set<String> reviewedReservationIds,
  ) {
    final store = _readStore(row);
    final guestCount = (row['guest_count'] as num?)?.toInt() ?? 0;
    final totalPrice = (row['total_price'] as num?)?.toInt() ?? 0;
    final priceText = totalPrice > 0
        ? ' · 예약금 ${NumberFormat('#,###', 'ko_KR').format(totalPrice)}원'
        : '';
    final storeId = row['store_id']?.toString() ?? '';
    final id = row['id']?.toString() ?? '';

    return UserReservationHistoryItem(
      id: id,
      storeId: storeId,
      storeName: store.name,
      categoryLabel: store.categoryLabel,
      type: UserReservationHistoryType.restaurant,
      scheduledAt: _parseRestaurantSchedule(
        row['booking_date']?.toString(),
        row['booking_time']?.toString(),
      ),
      summary: '인원 $guestCount명$priceText',
      status: _parseStatus(row['status']?.toString()),
      hasWrittenReview: reviewedReservationIds.contains(id),
    );
  }

  UserReservationHistoryItem _mapStudyCafeRow(
    Map<String, dynamic> row,
    Set<String> reviewedReservationIds,
  ) {
    final store = _readStore(row);
    final seatId = row['seat_id']?.toString() ?? '';
    final durationMinutes = (row['duration_minutes'] as num?)?.toInt() ?? 0;
    final seatLabel = seatId.length <= 8
        ? seatId
        : '${seatId.substring(0, 8)}…';
    final storeId = row['store_id']?.toString() ?? '';
    final id = row['id']?.toString() ?? '';

    return UserReservationHistoryItem(
      id: id,
      storeId: storeId,
      storeName: store.name,
      categoryLabel: store.categoryLabel,
      type: UserReservationHistoryType.studyCafe,
      scheduledAt:
          _parseDateTime(row['start_at']) ??
          _parseDateTime(row['created_at']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      summary: '좌석 $seatLabel · $durationMinutes분',
      status: _parseStatus(row['status']?.toString()),
      hasWrittenReview: reviewedReservationIds.contains(id),
    );
  }

  UserReservationHistoryItem _mapSalonRow(
    Map<String, dynamic> row,
    Set<String> reviewedReservationIds,
  ) {
    final store = _readStore(row);
    final serviceIds = row['service_ids'];
    final serviceCount = switch (serviceIds) {
      final List<dynamic> values => values.length,
      _ => 0,
    };
    final storeId = row['store_id']?.toString() ?? '';
    final id = row['id']?.toString() ?? '';

    return UserReservationHistoryItem(
      id: id,
      storeId: storeId,
      storeName: store.name,
      categoryLabel: store.categoryLabel,
      type: UserReservationHistoryType.salon,
      scheduledAt:
          _parseDateTime(row['start_at']) ??
          _parseDateTime(row['created_at']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      summary: '시술 $serviceCount개',
      status: _parseStatus(row['status']?.toString()),
      hasWrittenReview: reviewedReservationIds.contains(id),
    );
  }

  _StoreSnapshot _readStore(Map<String, dynamic> row) {
    final store = row['stores'];
    if (store is! Map<String, dynamic>) {
      return const _StoreSnapshot(name: '알 수 없는 매장', categoryLabel: '');
    }

    final name = store['name']?.toString().trim() ?? '';
    final category = store['category']?.toString().trim() ?? '';
    final categoryLabel =
        StoreCategory.fromDbValue(category)?.displayName ?? category;

    return _StoreSnapshot(
      name: name.isEmpty ? '알 수 없는 매장' : name,
      categoryLabel: categoryLabel,
    );
  }

  ReservationStatus _parseStatus(String? value) {
    return ReservationStatus.fromDbValue(value) ?? ReservationStatus.pending;
  }

  DateTime _parseRestaurantSchedule(String? date, String? time) {
    if (date == null || date.trim().isEmpty) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    final dateOnly = date.trim().split('T').first;
    final parsedDate = DateTime.tryParse(dateOnly);
    if (parsedDate == null) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    if (time == null || time.trim().isEmpty) {
      return parsedDate;
    }

    final parts = time.trim().split(':');
    final hour = int.tryParse(parts.first) ?? 0;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;

    return DateTime(
      parsedDate.year,
      parsedDate.month,
      parsedDate.day,
      hour,
      minute,
    );
  }

  DateTime? _parseDateTime(Object? value) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(value.toString());
  }
}

class _StoreSnapshot {
  const _StoreSnapshot({
    required this.name,
    required this.categoryLabel,
  });

  final String name;
  final String categoryLabel;
}
