import 'package:freezed_annotation/freezed_annotation.dart';

part 'on_boarding_event.freezed.dart';

@freezed
sealed class OnBoardingEvent with _$OnBoardingEvent {
  const factory OnBoardingEvent.showError(String error) = ShowError;
}