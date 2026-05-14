import 'package:freezed_annotation/freezed_annotation.dart';

part 'information_action.freezed.dart';

@freezed
sealed class InformationAction with _$InformationAction {
  const factory InformationAction.tapBack() = TapInformationBack;

  const factory InformationAction.tapShare() = TapInformationShare;

  const factory InformationAction.tapBookmark() = TapInformationBookmark;

  const factory InformationAction.tapReservation(String currentLocation) =
      TapInformationReservation;

  const factory InformationAction.tapSalonDesignerReservation({
    required String currentLocation,
    required String designerId,
  }) = TapSalonDesignerReservation;
}
