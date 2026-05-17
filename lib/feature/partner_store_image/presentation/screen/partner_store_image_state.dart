import 'package:capstone_2026/core/domain/model/store/store_image.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'partner_store_image_state.freezed.dart';

@freezed
abstract class PartnerStoreImageState with _$PartnerStoreImageState {
  const factory PartnerStoreImageState({
    @Default(false) bool isLoading,
    @Default(false) bool isSaving,
    @Default(<StoreImage>[]) List<StoreImage> images,
    @Default(<String?>[]) List<String?> localImagePaths,
  }) = _PartnerStoreImageState;
}
