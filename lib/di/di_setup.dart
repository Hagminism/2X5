import 'package:app_links/app_links.dart';
import 'package:capstone_2026/core/data/repository/auth_repository_impl.dart';
import 'package:capstone_2026/core/domain/repository/auth_repository.dart';
import 'package:capstone_2026/feature/find_password/presentation/screen/find_password_view_model.dart';
import 'package:capstone_2026/feature/my_page/account_settings/presentation/screen/account_setting_view_model.dart';
import 'package:capstone_2026/feature/my_page/settings/presentation/screen/my_page_view_model.dart';
import 'package:capstone_2026/feature/select_auth_provider/presentation/screen/select_auth_provider_view_model.dart';
import 'package:capstone_2026/feature/sign_in/presentation/screen/sign_in_view_model.dart';
import 'package:capstone_2026/feature/sign_up_customer/presentation/screen/sign_up_customer_view_model.dart';
import 'package:capstone_2026/feature/sign_up_partner/presentation/sign_up_partner_view_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';

GetIt getIt = GetIt.instance;

void diSetup() {
  // ViewModel
  getIt.registerFactory<SignInViewModel>(
    () => SignInViewModel(authRepository: getIt<AuthRepository>()),
  );
  getIt.registerFactory<FindPasswordViewModel>(
    () => FindPasswordViewModel(),
  );
  getIt.registerFactory<SignUpCustomerViewModel>(
    () => SignUpCustomerViewModel(authRepository: getIt<AuthRepository>()),
  );
  getIt.registerFactory<SignUpPartnerViewModel>(
    () => SignUpPartnerViewModel(),
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

  // Repository
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      firebaseAuth: getIt<FirebaseAuth>(),
      googleSignIn: getIt<GoogleSignIn>(),
    ),
  );

  // Auth
  getIt.registerLazySingleton<GoogleSignIn>(
    () => GoogleSignIn.instance,
  );
  getIt.registerLazySingleton<FirebaseAuth>(
    () => FirebaseAuth.instance,
  );
  getIt.registerLazySingleton<AppLinks>(
    () => AppLinks(),
  );
}
