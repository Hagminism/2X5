import 'dart:ui';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'information_action.freezed.dart';

@freezed
sealed class InformationAction with _$InformationAction {
  const factory InformationAction.tapBack() = TapInformationBack;

  const factory InformationAction.tapShare({
    Rect? shareOrigin,
  }) = TapInformationShare;

  const factory InformationAction.tapBookmark() = TapInformationBookmark;

  const factory InformationAction.tapReservation(String currentLocation) =
      TapInformationReservation;

  const factory InformationAction.tapSalonDesignerReservation({
    required String currentLocation,
    required String designerId,
  }) = TapSalonDesignerReservation;

  const factory InformationAction.sliderPageChanged(int index) =
      SliderPageChanged;

  const factory InformationAction.changeReservationAvailabilityDate(
    DateTime date,
  ) = ChangeReservationAvailabilityDate;
}
