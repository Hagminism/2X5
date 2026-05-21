import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_store_information_action.freezed.dart';

@freezed
sealed class SearchStoreInformationAction with _$SearchStoreInformationAction {
  const factory SearchStoreInformationAction.tapBack() =
      TapSearchStoreInformationBack;

  const factory SearchStoreInformationAction.tapShare() =
      TapSearchStoreInformationShare;

  const factory SearchStoreInformationAction.tapBookmark() =
      TapSearchStoreInformationBookmark;

  const factory SearchStoreInformationAction.tapReservation(
    String currentLocation,
  ) = TapSearchStoreInformationReservation;

  const factory SearchStoreInformationAction.tapSalonDesignerReservation({
    required String currentLocation,
    required String designerId,
  }) = TapSearchStoreInformationSalonDesignerReservation;

  const factory SearchStoreInformationAction.sliderPageChanged(int index) =
      SliderSearchStoreInformationPageChanged;
}
