import 'package:freezed_annotation/freezed_annotation.dart';

part 'partner_store_image_event.freezed.dart';

@freezed
sealed class PartnerStoreImageEvent with _$PartnerStoreImageEvent {
  const factory PartnerStoreImageEvent.showMessage(String message) = ShowMessage;
  const factory PartnerStoreImageEvent.openGallery() = OpenGallery;
  const factory PartnerStoreImageEvent.pop() = Pop;
}
