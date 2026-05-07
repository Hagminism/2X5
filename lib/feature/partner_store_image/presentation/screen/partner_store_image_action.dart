import 'package:freezed_annotation/freezed_annotation.dart';

part 'partner_store_image_action.freezed.dart';

@freezed
sealed class PartnerStoreImageAction with _$PartnerStoreImageAction {
  const factory PartnerStoreImageAction.tapAddImageFromGallery() =
      TapAddImageFromGallery;
  const factory PartnerStoreImageAction.removeStoreImage(int index) =
      RemoveStoreImage;
  const factory PartnerStoreImageAction.changeStoreImageCaption({
    required int index,
    required String value,
  }) = ChangeStoreImageCaption;
  const factory PartnerStoreImageAction.selectCoverImage(int index) =
      SelectCoverImage;
  const factory PartnerStoreImageAction.tapSave() = TapSave;
}
