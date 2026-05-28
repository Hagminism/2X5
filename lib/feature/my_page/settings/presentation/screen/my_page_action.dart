import 'package:freezed_annotation/freezed_annotation.dart';

part 'my_page_action.freezed.dart';

@freezed
sealed class MyPageAction with _$MyPageAction {
  const factory MyPageAction.viewNotifications() = ViewNotifications;

  const factory MyPageAction.editProfile() = EditProfile;

  const factory MyPageAction.viewReservationHistory() = ViewReservationHistory;

  const factory MyPageAction.viewReviewHistory() = ViewReviewHistory;

  const factory MyPageAction.viewStampHistory() = ViewStampHistory;

  const factory MyPageAction.viewCouponBox() = ViewCouponBox;

  const factory MyPageAction.tapAccountSettings() = TapAccountSettings;

  const factory MyPageAction.tapNotificationSettings() =
      TapNotificationSettings;

  const factory MyPageAction.tapInquiry() = TapInquiry;

  const factory MyPageAction.viewNotices() = ViewNotices;

  const factory MyPageAction.viewTerms() = ViewTerms;
}
