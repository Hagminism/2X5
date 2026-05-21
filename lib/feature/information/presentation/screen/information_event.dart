import 'package:freezed_annotation/freezed_annotation.dart';

part 'information_event.freezed.dart';

@freezed
sealed class InformationEvent with _$InformationEvent {
  const factory InformationEvent.pop() = PopInformationScreen;

  const factory InformationEvent.push(String location) = PushInformationRoute;

  const factory InformationEvent.showSnackBar(String message) =
      ShowInformationSnackBar;

  const factory InformationEvent.share({
    required String text,
    String? subject,
  }) = ShareInformationContent;
}
