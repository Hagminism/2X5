import 'package:app_links/app_links.dart';
import 'package:capstone_2026/core/domain/model/enum/partner_status.dart';
import 'package:capstone_2026/core/domain/model/enum/user_registration_status.dart';
import 'package:capstone_2026/core/domain/model/enum/user_type.dart';
import 'package:capstone_2026/core/domain/repository/auth/auth_repository.dart';
import 'package:capstone_2026/core/presentation/component/admin_bottom_app_bar.dart';
import 'package:capstone_2026/core/presentation/component/custom_bottom_app_bar.dart';
import 'package:capstone_2026/core/routing/core/component/user_registration_status_notifier.dart';
import 'package:capstone_2026/core/routing/core/component/auth_refresh_notifier.dart';
import 'package:capstone_2026/core/routing/routes.dart';
import 'package:capstone_2026/di/di_setup.dart';
import 'package:capstone_2026/feature/admin_page/presentation/screen/admin_dashboard_screen.dart';
import 'package:capstone_2026/feature/admin_page/presentation/screen/admin_reservations_screen.dart';
import 'package:capstone_2026/feature/admin_page/presentation/screen/admin_store_management_screen.dart';
import 'package:capstone_2026/feature/find_password/presentation/screen/find_password_screen_root.dart';
import 'package:capstone_2026/feature/find_password/presentation/screen/find_password_view_model.dart';
import 'package:capstone_2026/feature/home/presentation/screen/home_screen.dart';
import 'package:capstone_2026/feature/my_page/account_settings/presentation/screen/account_setting_screen_root.dart';
import 'package:capstone_2026/feature/my_page/account_settings/presentation/screen/account_setting_view_model.dart';
import 'package:capstone_2026/feature/my_page/review_history/presentation/screen/review_history_screen_root.dart';
import 'package:capstone_2026/feature/my_page/review_history/presentation/screen/review_history_view_model.dart';
import 'package:capstone_2026/feature/my_page/settings/presentation/screen/edit_profile_screen.dart';
import 'package:capstone_2026/feature/bookmark/presentation/screen/bookmark_screen.dart';
import 'package:capstone_2026/feature/bookmark_store_detail/presentation/screen/bookmark_store_detail_screen.dart';
import 'package:capstone_2026/feature/admin_onboarding/core/presentation/component/scope/admin_onboarding_scope.dart';
import 'package:capstone_2026/feature/admin_onboarding/presentation/screen/admin_onboarding_view_model.dart';
import 'package:capstone_2026/feature/my_page/settings/presentation/screen/my_page_screen_root.dart';
import 'package:capstone_2026/feature/my_page/settings/presentation/screen/my_page_view_model.dart';
import 'package:capstone_2026/feature/on_boarding/presentation/screen/on_boarding_screen_root.dart';
import 'package:capstone_2026/feature/on_boarding/presentation/screen/on_boarding_view_model.dart';
import 'package:capstone_2026/feature/select_auth_provider/core/presentation/component/scope/select_auth_provider_scope.dart';
import 'package:capstone_2026/feature/select_auth_provider/presentation/screen/select_auth_provider_view_model.dart';
import 'package:capstone_2026/feature/sign_in/core/presentation/component/scope/sign_in_scope.dart';
import 'package:capstone_2026/feature/sign_in/presentation/screen/sign_in_view_model.dart';
import 'package:capstone_2026/feature/map/presentation/screen/map_screen.dart';
import 'package:capstone_2026/feature/sign_up_customer/core/presentation/component/scope/sign_up_customer_scope.dart';
import 'package:capstone_2026/feature/sign_up_partner/core/presentation/component/scope/sign_up_partner_scope.dart';
import 'package:capstone_2026/feature/store_detail/presentation/screen/store_detail_screen_root.dart';
import 'package:capstone_2026/feature/store_detail/presentation/screen/store_detail_view_model.dart';
import 'package:capstone_2026/feature/sign_up_partner/presentation/sign_up_partner_view_model.dart';
import 'package:capstone_2026/feature/sign_up_customer/presentation/screen/sign_up_customer_view_model.dart';
import 'package:capstone_2026/feature/sign_up_type/presentation/screen/sign_up_type_screen_root.dart';
import 'package:capstone_2026/feature/search/presentation/screen/search_screen.dart';
import 'package:capstone_2026/feature/reservation/presentation/screen/reservation_screen.dart';
// 🛠️ Detail 대신 Information 폴더 참조로 변경
import 'package:capstone_2026/feature/information/presentation/screen/information_screen_root.dart';
import 'package:capstone_2026/feature/information/presentation/screen/information_view_model.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  initialLocation: Routes.signIn,
  navigatorKey: _rootNavigatorKey,
  routes: [
    GoRoute(
      path: Routes.signIn,
      builder: (context, state) => SignInScope(
        viewModel: getIt<SignInViewModel>(),
        appLinks: getIt<AppLinks>(),
      ),
      routes: [
        GoRoute(
          path: Routes.findPassword,
          builder: (context, state) => FindPasswordScreenRoot(
            viewModel: getIt<FindPasswordViewModel>(),
          ),
        ),
        GoRoute(
          path: Routes.selectAuthProvider,
          builder: (context, state) => SelectAuthProviderScope(
            viewModel: getIt<SelectAuthProviderViewModel>(),
            appLinks: getIt<AppLinks>(),
          ),
          routes: [
            GoRoute(
              path: Routes.signUpType,
              builder: (context, state) => SignUpTypeScreenRoot(),
              routes: [
                GoRoute(
                  path: Routes.signUpCustomer,
                  builder: (context, state) => SignUpCustomerScope(
                    viewModel: getIt<SignUpCustomerViewModel>(),
                  ),
                ),
                GoRoute(
                  path: Routes.signUpPartner,
                  builder: (context, state) => SignUpPartnerScope(
                    viewModel: getIt<SignUpPartnerViewModel>(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return CustomBottomAppBar(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.home,
              builder: (context, state) => const HomeScreen(),
              routes: [
                GoRoute(
                  parentNavigatorKey: _rootNavigatorKey,
                  path: Routes.search,
                  builder: (context, state) => const SearchScreen(),
                ),
                GoRoute(
                  name: 'information', // 🛠️ 경로명 변경
                  parentNavigatorKey: _rootNavigatorKey,
                  path: 'information/:storeId', // 🛠️ Routes.homeStoreDetail 대신 명시적 경로 사용 권장
                  builder: (context, state) {
                    final storeId = state.pathParameters['storeId'] ?? '';
                    return InformationScreenRoot( // 🛠️ 클래스명 변경
                      viewModel: getIt<InformationViewModel>(),
                      storeId: storeId,
                    );
                  },
                  routes: [
                    GoRoute(
                      path: Routes.reservation,
                      parentNavigatorKey: _rootNavigatorKey,
                      builder: (context, state) => const ReservationScreen(),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.map,
              builder: (context, state) => const MapScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.bookmark,
              builder: (context, state) => const BookmarkScreen(),
              routes: [
                GoRoute(
                  path: Routes.bookmarkStoreDetail,
                  builder: (context, state) => BookmarkStoreDetailScreen(
                    storeId: state.pathParameters['storeId'] ?? '',
                  ),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.myPage,
              builder: (context, state) => MyPageScreenRoot(
                viewModel: getIt<MyPageViewModel>(),
              ),
              routes: [
                GoRoute(
                  path: Routes.notifications,
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const Scaffold(
                    body: SafeArea(
                      child: Center(child: Text('알림 페이지')),
                    ),
                  ),
                ),
                GoRoute(
                  path: Routes.profileEdit,
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const EditProfileScreen(),
                ),
                GoRoute(
                  path: Routes.reservationHistory,
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const Scaffold(
                    body: SafeArea(
                      child: Center(child: Text('이용 내역 페이지')),
                    ),
                  ),
                ),
                GoRoute(
                  path: Routes.reviewHistory,
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => ReviewHistoryScreenRoot(
                    viewModel: getIt<ReviewHistoryViewModel>(),
                  ),
                ),
                GoRoute(
                  path: Routes.accountSettings,
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) {
                    return AccountSettingScreenRoot(
                      viewModel: getIt<AccountSettingViewModel>(),
                    );
                  },
                ),
                GoRoute(
                  path: Routes.notificationSettings,
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const Scaffold(
                    body: SafeArea(
                      child: Center(child: Text('알림 설정 페이지')),
                    ),
                  ),
                ),
                GoRoute(
                  path: Routes.inquiry,
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const Scaffold(
                    body: SafeArea(
                      child: Center(child: Text('1:1 문의 페이지')),
                    ),
                  ),
                ),
                GoRoute(
                  path: Routes.notices,
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const Scaffold(
                    body: SafeArea(
                      child: Center(child: Text('공지사항 페이지')),
                    ),
                  ),
                ),
                GoRoute(
                  path: Routes.terms,
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const Scaffold(
                    body: SafeArea(
                      child: Center(child: Text('이용약관 페이지')),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AdminBottomAppBar(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.adminHome,
              builder: (context, state) => const AdminDashboardScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.adminStore,
              builder: (context, state) => const AdminStoreManagementScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.adminReservations,
              builder: (context, state) => const AdminReservationsScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: Routes.onBoarding,
      builder: (context, state) => OnBoardingScreenRoot(
        viewModel: getIt<OnBoardingViewModel>(),
      ),
    ),
    GoRoute(
      path: Routes.adminOnboarding,
      builder: (context, state) => AdminOnboardingScope(
        viewModel: getIt<AdminOnboardingViewModel>(),
      ),
    ),
  ],
  redirect: _redirect,
  refreshListenable: Listenable.merge([
    AuthRefreshNotifier(getIt<AuthRepository>().authStateChanges()),
    getIt<UserRegistrationStatusNotifier>(),
  ]),
);

Future<String?> _redirect(BuildContext context, GoRouterState state) async {
  final currentUser = getIt<AuthRepository>().getCurrentUser();
  final registrationNotifier = getIt<UserRegistrationStatusNotifier>();
  final registrationStatus = registrationNotifier.status;
  final userProfile = registrationNotifier.currentUserProfile;

  final isLoggedIn = currentUser != null;
  final location = state.matchedLocation;

  final isInAuthFlow =
      location == Routes.signIn || location.startsWith('${Routes.signIn}/');
  final isInSignUpFlow = location.startsWith(
    '${Routes.signIn}/${Routes.selectAuthProvider}/${Routes.signUpType}',
  );
  final isInAdminOnboarding = location == Routes.adminOnboarding;
  final isInAdminShell =
      location == Routes.adminHome ||
          location.startsWith('${Routes.adminHome}/') ||
          location == Routes.adminStore ||
          location.startsWith('${Routes.adminStore}/') ||
          location == Routes.adminReservations ||
          location.startsWith('${Routes.adminReservations}/');
  final isInUserShell =
      location == Routes.home ||
          location.startsWith('${Routes.home}/') ||
          location == Routes.map ||
          location.startsWith('${Routes.map}/') ||
          location == Routes.bookmark ||
          location.startsWith('${Routes.bookmark}/') ||
          location == Routes.myPage ||
          location.startsWith('${Routes.myPage}/');

  if (!isLoggedIn) {
    return isInAuthFlow ? null : Routes.signIn;
  }

  if (registrationStatus == UserRegistrationStatus.unknown ||
      registrationStatus == UserRegistrationStatus.loading ||
      registrationStatus == UserRegistrationStatus.error) {
    return null;
  }

  if (registrationStatus == UserRegistrationStatus.notExists) {
    if (isInSignUpFlow) {
      return null;
    }
    return location == Routes.onBoarding ? null : Routes.onBoarding;
  }

  if (registrationStatus == UserRegistrationStatus.exists &&
      userProfile != null &&
      userProfile.userType == UserType.partner &&
      userProfile.partnerStatus != PartnerStatus.approved) {
    return isInAdminOnboarding ? null : Routes.adminOnboarding;
  }

  final isApprovedPartner =
      registrationStatus == UserRegistrationStatus.exists &&
          userProfile != null &&
          userProfile.userType == UserType.partner &&
          userProfile.partnerStatus == PartnerStatus.approved;

  if (isApprovedPartner) {
    if (isInAdminOnboarding || isInAuthFlow || location == Routes.onBoarding || isInUserShell) {
      return Routes.adminHome;
    }
    return null;
  }

  if (isInAdminOnboarding || isInAdminShell) {
    return Routes.home;
  }

  if (isInAuthFlow || location == Routes.onBoarding) {
    return Routes.home;
  }

  return null;
}