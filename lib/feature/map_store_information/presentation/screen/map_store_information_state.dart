import 'package:capstone_2026/core/domain/model/salon/salon_designer.dart';
import 'package:capstone_2026/core/domain/model/store/store_menu.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'map_store_information_state.freezed.dart';

@freezed
abstract class MapStoreInformationState with _$MapStoreInformationState {
  const factory MapStoreInformationState({
    @Default('') String storeId,
    @Default('') String name,
    @Default('') String subtitle,
    @Default(0) double rating,
    @Default('') String category,
    @Default('') String address,
    @Default('') String displayPhone,
    @Default('') String operatingHoursText,
    @Default(<StoreMenu>[]) List<StoreMenu> menus,
    @Default(<String>[]) List<String> imageUrls,
    String? imageUrl,
    @Default(false) bool isBookmarked,
    @Default(false) bool isLoading,
    @Default([]) List<SalonDesigner> salonDesigners,
  }) = _MapStoreInformationState;
}
