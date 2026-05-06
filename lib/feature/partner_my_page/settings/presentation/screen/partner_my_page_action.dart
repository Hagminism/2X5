import 'package:freezed_annotation/freezed_annotation.dart';

part 'partner_my_page_action.freezed.dart';

@freezed
sealed class PartnerMyPageAction with _$PartnerMyPageAction {
  const factory PartnerMyPageAction.viewNotifications() = ViewNotifications;

  const factory PartnerMyPageAction.editProfile() = EditProfile;

  const factory PartnerMyPageAction.viewReservationHistory() =
      ViewReservationHistory;

  const factory PartnerMyPageAction.viewReviewHistory() = ViewReviewHistory;

  const factory PartnerMyPageAction.tapAccountSettings() = TapAccountSettings;

  const factory PartnerMyPageAction.tapNotificationSettings() =
      TapNotificationSettings;

  const factory PartnerMyPageAction.tapInquiry() = TapInquiry;

  const factory PartnerMyPageAction.viewNotices() = ViewNotices;

  const factory PartnerMyPageAction.viewTerms() = ViewTerms;
}
