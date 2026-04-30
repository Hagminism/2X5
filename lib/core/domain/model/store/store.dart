import 'package:freezed_annotation/freezed_annotation.dart';

part 'store.freezed.dart';
part 'store.g.dart';

@freezed
abstract class Store with _$Store {
  const factory Store({
    required String id,
    required String ownerId,
    required String name,
    required String category,
    required String businessNumber,
    required String address,
    required double latitude,
    required double longitude,
    String? naverPlaceId,
    required String contact,
    required Map<String, dynamic> operatingHours,
    DateTime? createdAt,
  }) = _Store;

  factory Store.fromJson(Map<String, Object?> json) => _$StoreFromJson(json);
}
