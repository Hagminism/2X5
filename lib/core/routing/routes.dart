class Routes {
  // Auth
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String selectAuthProvider = 'select-auth-provider';
  static const String signUpType = 'type';
  static const String signUpCustomer = 'customer';
  static const String signUpPartner = 'partner';
  static const String findPassword = 'find-password';

  static const String onBoarding = '/on-boarding';

  // Shell root
  static const String home = '/home';
  static const String map = '/map';
  static const String bookmark = '/bookmark';
  static const String myPage = '/mypage';

  // Common nested paths
  static const String search = 'search';
  static const String notifications = 'notifications';
  static const String homeStoreInformation = 'information/:storeId';
  static const String bookmarkStoreDetail = 'store/:storeId';

  // reservation
  static const String reservation = 'reservation';

  // My page nested paths
  static const String profileEdit = 'profile-edit';
  static const String reservationHistory = 'history-reservations';
  static const String reviewHistory = 'history-reviews';
  static const String accountSettings = 'account-settings';
  static const String notificationSettings = 'settings-notifications';
  static const String notices = 'notices';
  static const String terms = 'terms';
  static const String inquiry = 'inquiry';

// Partner
  static const String partnerHome = '/partner/home';
  static const String partnerStore = '/partner/store';
  static const String partnerAddressSearch = 'address-search';
  static const String partnerOnboarding = '/partner/onboarding';
  static const String partnerStoreEdit = '/partner/store/edit';
  static const String partnerReservations = '/partner/reservations';
  static const String partnerMyPage = '/partner/mypage';

  /// Partner 마이페이지 하위 경로 (customer `myPage` 하위와 심볼·세그먼트 분리)
  static const String partnerMyPageNotifications = 'partner-notifications';
  static const String partnerMyPageProfileEdit = 'partner-profile-edit';
  static const String partnerMyPageReservationHistory =
      'partner-history-reservations';
  static const String partnerMyPageReviewHistory = 'partner-history-reviews';
  static const String partnerMyPageAccountSettings = 'partner-account-settings';
  static const String partnerMyPageNotificationSettings =
      'partner-settings-notifications';
  static const String partnerMyPageInquiry = 'partner-inquiry';
  static const String partnerMyPageNotices = 'partner-notices';
  static const String partnerMyPageTerms = 'partner-terms';
}
