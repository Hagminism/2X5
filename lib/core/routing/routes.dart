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

  // Admin
  static const String adminHome = '/admin/home';
  static const String adminStore = '/admin/store';
  static const String adminOnboarding = '/admin/onboarding';
  static const String adminStoreEdit = '/admin/store/edit';
  static const String adminReservations = '/admin/reservations';
}