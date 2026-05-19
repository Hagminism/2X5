import 'package:capstone_2026/core/data/data_source/owner_verification/owner_verification_data_source.dart';
import 'package:capstone_2026/core/data/data_source/owner_verification/owner_verification_data_source_impl.dart';
import 'package:app_links/app_links.dart';
import 'package:capstone_2026/core/data/data_source/user/user_data_source.dart';
import 'package:capstone_2026/core/data/data_source/user/user_data_source_impl.dart';
import 'package:capstone_2026/core/data/data_source/reservation/reservation_data_source.dart';
import 'package:capstone_2026/core/data/data_source/reservation/reservation_data_source_impl.dart';
import 'package:capstone_2026/core/data/data_source/salon/salon_data_source.dart';
import 'package:capstone_2026/core/data/data_source/salon/salon_data_source_impl.dart';
import 'package:capstone_2026/core/data/data_source/store/store_data_source.dart';
import 'package:capstone_2026/core/data/data_source/store/store_data_source_impl.dart';
import 'package:capstone_2026/core/data/data_source/studycafe/studycafe_data_source.dart';
import 'package:capstone_2026/core/data/data_source/studycafe/studycafe_data_source_impl.dart';
import 'package:capstone_2026/core/data/repository/auth/auth_repository_impl.dart';
import 'package:capstone_2026/core/data/repository/owner_verification/owner_verification_repository_impl.dart';
import 'package:capstone_2026/core/data/repository/reservation/reservation_repository_impl.dart';
import 'package:capstone_2026/core/data/repository/salon/salon_repository_impl.dart';
import 'package:capstone_2026/core/data/repository/store/store_repository_impl.dart';
import 'package:capstone_2026/core/data/repository/studycafe/studycafe_repository_impl.dart';
import 'package:capstone_2026/core/data/repository/user/user_repository_impl.dart';
import 'package:capstone_2026/core/domain/repository/auth/auth_repository.dart';
import 'package:capstone_2026/core/domain/repository/owner_verification/owner_verification_repository.dart';
import 'package:capstone_2026/core/domain/repository/reservation/reservation_repository.dart';
import 'package:capstone_2026/core/domain/repository/salon/salon_repository.dart';
import 'package:capstone_2026/core/domain/repository/store/store_repository.dart';
import 'package:capstone_2026/core/domain/repository/studycafe/studycafe_repository.dart';
import 'package:capstone_2026/core/domain/repository/user/user_repository.dart';
import 'package:capstone_2026/core/domain/service/sign_up_with_email_service.dart';
import 'package:capstone_2026/core/domain/validator/store_operating_hours_validator.dart';
import 'package:capstone_2026/core/routing/core/component/user_registration_status_notifier.dart';
import 'package:capstone_2026/feature/address_search/data/data_source/address_search_data_source.dart';
import 'package:capstone_2026/feature/address_search/data/data_source/address_search_data_source_impl.dart';
import 'package:capstone_2026/feature/address_search/presentation/screen/address_search_view_model.dart';
import 'package:capstone_2026/feature/find_password/presentation/screen/find_password_view_model.dart';
import 'package:capstone_2026/feature/home/presentation/screen/home_view_model.dart';
import 'package:capstone_2026/feature/map_store_information/presentation/screen/map_studycafe_pass_selection_view_model.dart';
import 'package:capstone_2026/feature/map_store_information/presentation/screen/map_studycafe_seat_selection_view_model.dart';
import 'package:capstone_2026/feature/map_store_information/presentation/screen/map_store_information_view_model.dart';
import 'package:capstone_2026/feature/partner_onboarding/presentation/screen/partner_onboarding_view_model.dart';
import 'package:capstone_2026/feature/partner_reservation_slot_settings/presentation/screen/partner_reservation_slot_settings_view_model.dart';
import 'package:capstone_2026/feature/partner_reservations/presentation/screen/partner_reservations_view_model.dart';
import 'package:capstone_2026/feature/partner_salon_designer_management/presentation/screen/partner_salon_designer_management_view_model.dart';
import 'package:capstone_2026/feature/partner_salon_management/presentation/screen/partner_salon_management_view_model.dart';
import 'package:capstone_2026/feature/partner_salon_schedule_management/presentation/screen/partner_salon_schedule_management_view_model.dart';
import 'package:capstone_2026/feature/partner_salon_service_management/presentation/screen/partner_salon_service_management_view_model.dart';
import 'package:capstone_2026/feature/partner_page/presentation/screen/partner_store_management_view_model.dart';
import 'package:capstone_2026/feature/partner_store_image/presentation/screen/partner_store_image_view_model.dart';
import 'package:capstone_2026/feature/partner_store_menu/presentation/screen/partner_store_menu_view_model.dart';
import 'package:capstone_2026/feature/partner_studycafe_layout/presentation/screen/partner_studycafe_layout_view_model.dart';
import 'package:capstone_2026/feature/partner_studycafe_layout/presentation/screen/partner_studycafe_usage_option_view_model.dart';
import 'package:capstone_2026/feature/my_page/account_settings/presentation/screen/account_setting_view_model.dart';
import 'package:capstone_2026/feature/my_page/review_history/presentation/screen/review_history_view_model.dart';
import 'package:capstone_2026/feature/my_page/stamp_history/presentation/screen/stamp_history_view_model.dart';
import 'package:capstone_2026/feature/my_page/settings/presentation/screen/my_page_view_model.dart';
import 'package:capstone_2026/feature/partner_my_page/settings/presentation/screen/partner_my_page_view_model.dart';
import 'package:capstone_2026/feature/on_boarding/presentation/screen/on_boarding_view_model.dart';
import 'package:capstone_2026/feature/select_auth_provider/presentation/screen/select_auth_provider_view_model.dart';
import 'package:capstone_2026/feature/salon_reservation/presentation/screen/salon_reservation_view_model.dart';
import 'package:capstone_2026/feature/sign_in/presentation/screen/sign_in_view_model.dart';
import 'package:capstone_2026/feature/sign_up_customer/presentation/screen/sign_up_customer_view_model.dart';
import 'package:capstone_2026/feature/sign_up_partner/presentation/sign_up_partner_view_model.dart';
import 'package:capstone_2026/feature/store_detail/data/data_source/google_places_data_source.dart';
import 'package:capstone_2026/feature/store_detail/data/data_source/google_places_data_source_impl.dart';
import 'package:capstone_2026/feature/store_detail/data/data_source/naver_store_search_data_source.dart';
import 'package:capstone_2026/feature/store_detail/data/data_source/naver_store_search_data_source_impl.dart';
import 'package:capstone_2026/feature/store_detail/data/repository/store_detail_repository_impl.dart';
import 'package:capstone_2026/feature/store_detail/data/repository/store_review_repository_impl.dart';
import 'package:capstone_2026/feature/store_detail/domain/repository/store_detail_repository.dart';
import 'package:capstone_2026/feature/store_detail/domain/repository/store_review_repository.dart';
import 'package:capstone_2026/feature/store_detail/domain/service/store_review_service.dart';
import 'package:capstone_2026/feature/store_detail/presentation/screen/store_detail_view_model.dart';
import 'package:capstone_2026/feature/stamp/data/repository/stamp_repository_impl.dart';
import 'package:capstone_2026/feature/stamp/domain/repository/stamp_repository.dart';
import 'package:capstone_2026/feature/stamp/domain/service/stamp_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:capstone_2026/feature/information/presentation/screen/information_view_model.dart';
import 'package:capstone_2026/feature/search_store_information/presentation/screen/search_studycafe_pass_selection_view_model.dart';
import 'package:capstone_2026/feature/search_store_information/presentation/screen/search_studycafe_seat_selection_view_model.dart';
import 'package:capstone_2026/feature/search_store_information/presentation/screen/search_store_information_view_model.dart';
import 'package:capstone_2026/feature/seat_selection/presentation/screen/seat_selection_view_model.dart';
import 'package:capstone_2026/feature/studycafe_time_selection/presentation/screen/time_selection_view_model.dart';
import 'package:capstone_2026/feature/salon_reservation_confirm/presentation/screen/salon_reservation_confirm_view_model.dart';

GetIt getIt = GetIt.instance;

void diSetup() {
  // Auth
  getIt.registerLazySingleton<GoogleSignIn>(
        () => GoogleSignIn.instance,
  );
  getIt.registerLazySingleton<FirebaseAuth>(
        () => FirebaseAuth.instance,
  );
  getIt.registerLazySingleton<FirebaseFunctions>(
        () => FirebaseFunctions.instance,
  );

  // Util
  getIt.registerLazySingleton<AppLinks>(
        () => AppLinks(),
  );
  getIt.registerLazySingleton<StoreOperatingHoursValidator>(
        () => const StoreOperatingHoursValidator(),
  );

  // Redirect
  getIt.registerLazySingleton<UserRegistrationStatusNotifier>(
        () => UserRegistrationStatusNotifier(
      authRepository: getIt<AuthRepository>(),
      userRepository: getIt<UserRepository>(),
    ),
  );

  // DB
  getIt.registerLazySingleton<SupabaseClient>(
        () => SupabaseClient(
      dotenv.env['SUPABASE_URL']!,
      dotenv.env['SUPABASE_PUBLISHABLE_KEY']!,
    ),
  );

  // Service
  getIt.registerLazySingleton<SignUpWithEmailService>(
        () => SignUpWithEmailService(
      authRepository: getIt<AuthRepository>(),
      userRepository: getIt<UserRepository>(),
      userRegistrationStatusNotifier: getIt<UserRegistrationStatusNotifier>(),
    ),
  );

  // DataSource
  getIt.registerLazySingleton<NaverStoreSearchDataSource>(
        () => NaverStoreSearchDataSourceImpl(),
  );
  getIt.registerLazySingleton<GooglePlacesDataSource>(
        () => GooglePlacesDataSourceImpl(),
  );
  getIt.registerLazySingleton<UserDataSource>(
        () => UserDataSourceImpl(supabaseClient: getIt<SupabaseClient>()),
  );
  getIt.registerLazySingleton<OwnerVerificationDataSource>(
        () => OwnerVerificationDataSourceImpl(
      supabaseClient: getIt<SupabaseClient>(),
    ),
  );
  getIt.registerLazySingleton<StoreDataSource>(
        () => StoreDataSourceImpl(
      supabaseClient: getIt<SupabaseClient>(),
      firebaseFunctions: getIt<FirebaseFunctions>(),
    ),
  );
  getIt.registerLazySingleton<ReservationDataSource>(
        () => ReservationDataSourceImpl(supabaseClient: getIt<SupabaseClient>()),
  );
  getIt.registerLazySingleton<StudyCafeDataSource>(
    () => StudyCafeDataSourceImpl(
      supabaseClient: getIt<SupabaseClient>(),
      firebaseFunctions: getIt<FirebaseFunctions>(),
    ),
  );
  getIt.registerLazySingleton<SalonDataSource>(
    () => SalonDataSourceImpl(
      supabaseClient: getIt<SupabaseClient>(),
      firebaseFunctions: getIt<FirebaseFunctions>(),
    ),
  );
  getIt.registerLazySingleton<AddressSearchDataSource>(
        () => AddressSearchDataSourceImpl(),
  );

  // Repository
  getIt.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(
      firebaseAuth: getIt<FirebaseAuth>(),
      googleSignIn: getIt<GoogleSignIn>(),
      firebaseFunctions: getIt<FirebaseFunctions>(),
    ),
  );
  getIt.registerLazySingleton<StoreDetailRepository>(
        () => MockStoreDetailRepositoryImpl(),
  );
  getIt.registerLazySingleton<StoreReviewRepository>(
        () => StoreReviewRepositoryImpl(
      googlePlacesDataSource: getIt<GooglePlacesDataSource>(),
      naverStoreSearchDataSource: getIt<NaverStoreSearchDataSource>(),
      supabase: getIt<SupabaseClient>(),
    ),
  );
  getIt.registerLazySingleton<StoreReviewService>(
        () => StoreReviewService(
      storeReviewRepository: getIt<StoreReviewRepository>(),
      authRepository: getIt<AuthRepository>(),
    ),
  );
  getIt.registerLazySingleton<StampRepository>(
        () => StampRepositoryImpl(supabase: getIt<SupabaseClient>()),
  );
  getIt.registerLazySingleton<StampService>(
        () => StampService(
      stampRepository: getIt<StampRepository>(),
      authRepository: getIt<AuthRepository>(),
    ),
  );
  getIt.registerLazySingleton<UserRepository>(
        () => UserRepositoryImpl(userDataSource: getIt<UserDataSource>()),
  );
  getIt.registerLazySingleton<OwnerVerificationRepository>(
        () => OwnerVerificationRepositoryImpl(
      ownerVerificationDataSource: getIt<OwnerVerificationDataSource>(),
      authRepository: getIt<AuthRepository>(),
    ),
  );
  getIt.registerLazySingleton<StoreRepository>(
        () => StoreRepositoryImpl(
      storeDataSource: getIt<StoreDataSource>(),
      authRepository: getIt<AuthRepository>(),
      userRepository: getIt<UserRepository>(),
      operatingHoursValidator: getIt<StoreOperatingHoursValidator>(),
    ),
  );
  getIt.registerLazySingleton<ReservationRepository>(
        () => ReservationRepositoryImpl(
      reservationDataSource: getIt<ReservationDataSource>(),
      storeDataSource: getIt<StoreDataSource>(),
      authRepository: getIt<AuthRepository>(),
    ),
  );
  getIt.registerLazySingleton<StudyCafeRepository>(
    () => StudyCafeRepositoryImpl(
      studyCafeDataSource: getIt<StudyCafeDataSource>(),
      storeDataSource: getIt<StoreDataSource>(),
      authRepository: getIt<AuthRepository>(),
    ),
  );
  getIt.registerLazySingleton<SalonRepository>(
    () => SalonRepositoryImpl(
      salonDataSource: getIt<SalonDataSource>(),
      storeDataSource: getIt<StoreDataSource>(),
      authRepository: getIt<AuthRepository>(),
    ),
  );

  // ViewModel
  getIt.registerFactory<SignInViewModel>(
        () => SignInViewModel(authRepository: getIt<AuthRepository>()),
  );
  getIt.registerFactory<HomeViewModel>(
        () => HomeViewModel(
      storeRepository: getIt<StoreRepository>(),
    ),
  );
  getIt.registerFactory<PartnerOnboardingViewModel>(
        () => PartnerOnboardingViewModel(
      authRepository: getIt<AuthRepository>(),
      firebaseFunctions: getIt<FirebaseFunctions>(),
      userRegistrationStatusNotifier: getIt<UserRegistrationStatusNotifier>(),
    ),
  );
  getIt.registerFactory<PartnerStoreManagementViewModel>(
        () => PartnerStoreManagementViewModel(
      ownerVerificationRepository: getIt<OwnerVerificationRepository>(),
      storeRepository: getIt<StoreRepository>(),
    ),
  );
  getIt.registerFactory<PartnerStoreMenuViewModel>(
        () => PartnerStoreMenuViewModel(
      storeRepository: getIt<StoreRepository>(),
    ),
  );
  getIt.registerFactory<PartnerStoreImageViewModel>(
        () => PartnerStoreImageViewModel(
      storeRepository: getIt<StoreRepository>(),
    ),
  );
  getIt.registerFactory<PartnerReservationsViewModel>(
        () => PartnerReservationsViewModel(
      reservationRepository: getIt<ReservationRepository>(),
    ),
  );
  getIt.registerFactory<PartnerReservationSlotSettingsViewModel>(
        () => PartnerReservationSlotSettingsViewModel(),
  );
  getIt.registerFactory<PartnerStudyCafeLayoutViewModel>(
    () => PartnerStudyCafeLayoutViewModel(
      studyCafeRepository: getIt<StudyCafeRepository>(),
    ),
  );
  getIt.registerFactory<PartnerStudyCafeUsageOptionViewModel>(
    () => PartnerStudyCafeUsageOptionViewModel(
      studyCafeRepository: getIt<StudyCafeRepository>(),
    ),
  );
  getIt.registerFactory<PartnerSalonManagementViewModel>(
    () => PartnerSalonManagementViewModel(),
  );
  getIt.registerFactory<PartnerSalonDesignerManagementViewModel>(
    () => PartnerSalonDesignerManagementViewModel(
      salonRepository: getIt<SalonRepository>(),
      storeRepository: getIt<StoreRepository>(),
    ),
  );
  getIt.registerFactory<PartnerSalonServiceManagementViewModel>(
    () => PartnerSalonServiceManagementViewModel(
      salonRepository: getIt<SalonRepository>(),
    ),
  );
  getIt.registerFactory<PartnerSalonScheduleManagementViewModel>(
    () => PartnerSalonScheduleManagementViewModel(
      salonRepository: getIt<SalonRepository>(),
    ),
  );
  getIt.registerFactory<AddressSearchViewModel>(
        () => AddressSearchViewModel(
      addressSearchDataSource: getIt<AddressSearchDataSource>(),
    ),
  );
  getIt.registerFactory<FindPasswordViewModel>(
        () => FindPasswordViewModel(),
  );
  getIt.registerFactory<SignUpCustomerViewModel>(
        () => SignUpCustomerViewModel(
      signUpWithEmailService: getIt<SignUpWithEmailService>(),
    ),
  );
  getIt.registerFactory<OnBoardingViewModel>(
        () => OnBoardingViewModel(
      authRepository: getIt<AuthRepository>(),
      userRepository: getIt<UserRepository>(),
      userRegistrationStatusNotifier: getIt<UserRegistrationStatusNotifier>(),
    ),
  );
  getIt.registerFactory<SignUpPartnerViewModel>(
        () => SignUpPartnerViewModel(
      signUpWithEmailService: getIt<SignUpWithEmailService>(),
    ),
  );
  getIt.registerFactory<SelectAuthProviderViewModel>(
        () => SelectAuthProviderViewModel(authRepository: getIt<AuthRepository>()),
  );
  getIt.registerFactory<AccountSettingViewModel>(
        () => AccountSettingViewModel(authRepository: getIt<AuthRepository>()),
  );
  getIt.registerFactory<MyPageViewModel>(
        () => MyPageViewModel(authRepository: getIt<AuthRepository>()),
  );
  getIt.registerFactory<PartnerMyPageViewModel>(
        () => PartnerMyPageViewModel(authRepository: getIt<AuthRepository>()),
  );
  getIt.registerFactory<ReviewHistoryViewModel>(
        () => ReviewHistoryViewModel(
      authRepository: getIt<AuthRepository>(),
      storeReviewRepository: getIt<StoreReviewRepository>(),
      stampService: getIt<StampService>(),
    ),
  );
  getIt.registerFactory<StampHistoryViewModel>(
        () => StampHistoryViewModel(stampService: getIt<StampService>()),
  );
  getIt.registerFactory<StoreDetailViewModel>(
        () => StoreDetailViewModel(
      storeDetailRepository: getIt<StoreDetailRepository>(),
      storeReviewService: getIt<StoreReviewService>(),
      stampService: getIt<StampService>(),
    ),
  );

  // ✅ 수정 완료: 이제 Repository를 주입받습니다.
  getIt.registerFactory<InformationViewModel>(
        () => InformationViewModel(
      storeRepository: getIt<StoreRepository>(),
      salonRepository: getIt<SalonRepository>(),
    ),
  );
  getIt.registerFactory<SearchStoreInformationViewModel>(
    () => SearchStoreInformationViewModel(
      storeRepository: getIt<StoreRepository>(),
      salonRepository: getIt<SalonRepository>(),
    ),
  );
  getIt.registerFactory<MapStoreInformationViewModel>(
    () => MapStoreInformationViewModel(
      storeRepository: getIt<StoreRepository>(),
      salonRepository: getIt<SalonRepository>(),
    ),
  );
  getIt.registerFactory<SeatSelectionViewModel>(
    () => SeatSelectionViewModel(
      studyCafeRepository: getIt<StudyCafeRepository>(),
      authRepository: getIt<AuthRepository>(),
    ),
  );
  getIt.registerFactory<TimeSelectionViewModel>(
    () => TimeSelectionViewModel(
      studyCafeRepository: getIt<StudyCafeRepository>(),
      authRepository: getIt<AuthRepository>(),
    ),
  );
  getIt.registerFactory<MapStudycafeSeatSelectionViewModel>(
    () => MapStudycafeSeatSelectionViewModel(
      studyCafeRepository: getIt<StudyCafeRepository>(),
      authRepository: getIt<AuthRepository>(),
    ),
  );
  getIt.registerFactory<MapStudycafePassSelectionViewModel>(
    () => MapStudycafePassSelectionViewModel(
      studyCafeRepository: getIt<StudyCafeRepository>(),
      authRepository: getIt<AuthRepository>(),
    ),
  );
  getIt.registerFactory<SearchStudycafeSeatSelectionViewModel>(
    () => SearchStudycafeSeatSelectionViewModel(
      studyCafeRepository: getIt<StudyCafeRepository>(),
      authRepository: getIt<AuthRepository>(),
    ),
  );
  getIt.registerFactory<SearchStudycafePassSelectionViewModel>(
    () => SearchStudycafePassSelectionViewModel(
      studyCafeRepository: getIt<StudyCafeRepository>(),
      authRepository: getIt<AuthRepository>(),
    ),
  );
  getIt.registerFactory<SalonReservationViewModel>(
    () => SalonReservationViewModel(
      salonRepository: getIt<SalonRepository>(),
      storeRepository: getIt<StoreRepository>(),
    ),
  );
  getIt.registerFactory<SalonReservationConfirmViewModel>(
    () => SalonReservationConfirmViewModel(
      salonRepository: getIt<SalonRepository>(),
      storeRepository: getIt<StoreRepository>(),
    ),
  );
}
