import 'package:capstone_2026/core/domain/model/enum/user_type.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'on_boarding_action.freezed.dart';

@freezed
sealed class OnBoardingAction with _$OnBoardingAction {
  const factory OnBoardingAction.tapCustomer(UserType userType) = TapCustomer;

  const factory OnBoardingAction.tapPartner(UserType userType) = TapPartner;
}
