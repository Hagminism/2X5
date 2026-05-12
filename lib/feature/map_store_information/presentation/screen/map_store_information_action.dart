import 'package:freezed_annotation/freezed_annotation.dart';

part 'map_store_information_action.freezed.dart';

@freezed
sealed class MapStoreInformationAction with _$MapStoreInformationAction {
  const factory MapStoreInformationAction.tapBack() =
      TapMapStoreInformationBack;

  const factory MapStoreInformationAction.tapShare() =
      TapMapStoreInformationShare;

  const factory MapStoreInformationAction.tapBookmark() =
      TapMapStoreInformationBookmark;

  const factory MapStoreInformationAction.tapReservation(
    String currentLocation,
  ) = TapMapStoreInformationReservation;
}
