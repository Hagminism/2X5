import 'package:freezed_annotation/freezed_annotation.dart';

part 'map_store_information_event.freezed.dart';

@freezed
sealed class MapStoreInformationEvent with _$MapStoreInformationEvent {
  const factory MapStoreInformationEvent.pop() = PopMapStoreInformationScreen;

  const factory MapStoreInformationEvent.push(String location) =
      PushMapStoreInformationRoute;

  const factory MapStoreInformationEvent.showSnackBar(String message) =
      ShowMapStoreInformationSnackBar;
}
