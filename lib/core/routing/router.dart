import 'package:app_links/app_links.dart';
import 'package:capstone_2026/core/domain/model/enum/partner_status.dart';
import 'package:capstone_2026/core/domain/model/enum/user_registration_status.dart';
import 'package:capstone_2026/core/domain/model/enum/user_type.dart';
import 'package:capstone_2026/core/domain/repository/auth/auth_repository.dart';
import 'package:capstone_2026/feature/address_search/presentation/screen/address_search_screen_root.dart';
import 'package:capstone_2026/feature/address_search/presentation/screen/address_search_view_model.dart';
import 'package:capstone_2026/feature/partner_my_page/settings/presentation/screen/partner_my_page_screen_root.dart';
import 'package:capstone_2026/feature/partner_my_page/settings/presentation/screen/partner_my_page_view_model.dart';
import 'package:capstone_2026/feature/partner_reservation_slot_settings/core/presentation/component/scope/partner_reservation_slot_settings_scope.dart';
import 'package:capstone_2026/feature/partner_reservation_slot_settings/presentation/screen/partner_reservation_slot_settings_view_model.dart';
import 'package:capstone_2026/core/presentation/component/custom_bottom_app_bar.dart';
import 'package:capstone_2026/core/presentation/component/partner_bottom_app_bar.dart';
import 'package:capstone_2026/core/routing/core/component/user_registration_status_notifier.dart';
import 'package:capstone_2026/core/routing/core/component/auth_refresh_notifier.dart';
import 'package:capstone_2026/core/routing/routes.dart';
import 'package:capstone_2026/di/di_setup.dart';
import 'package:capstone_2026/feature/partner_dashboard/presentation/screen/partner_dashboard_screen.dart';
import 'package:capstone_2026/feature/partner_page/core/presentation/component/scope/partner_store_management_scope.dart';
import 'package:capstone_2026/feature/partner_reservations/presentation/screen/partner_reservations_screen_root.dart';
import 'package:capstone_2026/feature/partner_reservations/presentation/screen/partner_reservations_view_model.dart';
import 'package:capstone_2026/feature/partner_page/presentation/screen/partner_store_management_view_model.dart';
import 'package:capstone_2026/feature/partner_store_image/core/presentation/component/scope/partner_store_image_scope.dart';
import 'package:capstone_2026/feature/partner_store_image/presentation/screen/partner_store_image_view_model.dart';
import 'package:capstone_2026/feature/partner_store_menu/core/presentation/component/scope/partner_store_menu_scope.dart';
import 'package:capstone_2026/feature/partner_store_menu/presentation/screen/partner_store_menu_view_model.dart';
import 'package:capstone_2026/feature/find_password/presentation/screen/find_password_screen_root.dart';
import 'package:capstone_2026/feature/find_password/presentation/screen/find_password_view_model.dart';
import 'package:capstone_2026/feature/home/core/presentation/component/scope/home_scope.dart';
import 'package:capstone_2026/feature/home/presentation/screen/home_view_model.dart';
import 'package:capstone_2026/feature/my_page/account_settings/presentation/screen/account_setting_screen_root.dart';
import 'package:capstone_2026/feature/my_page/terms/presentation/screen/terms_screen.dart';
import 'package:capstone_2026/feature/my_page/account_settings/presentation/screen/account_setting_view_model.dart';
import 'package:capstone_2026/feature/my_page/review_history/presentation/screen/review_history_screen_root.dart';
import 'package:capstone_2026/feature/my_page/review_history/presentation/screen/review_history_view_model.dart';
import 'package:capstone_2026/feature/my_page/stamp_history/presentation/screen/stamp_history_screen_root.dart';
import 'package:capstone_2026/feature/my_page/stamp_history/presentation/screen/stamp_history_view_model.dart';
import 'package:capstone_2026/feature/my_page/settings/presentation/screen/edit_profile_screen.dart';
import 'package:capstone_2026/feature/bookmark/presentation/screen/bookmark_screen.dart';
import 'package:capstone_2026/feature/partner_onboarding/core/presentation/component/scope/partner_onboarding_scope.dart';
import 'package:capstone_2026/feature/partner_onboarding/presentation/screen/partner_onboarding_view_model.dart';
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
import 'package:capstone_2026/feature/sign_up_partner/presentation/sign_up_partner_view_model.dart';
import 'package:capstone_2026/feature/sign_up_customer/presentation/screen/sign_up_customer_view_model.dart';
import 'package:capstone_2026/feature/sign_up_type/presentation/screen/sign_up_type_screen_root.dart';
import 'package:capstone_2026/feature/search/presentation/screen/search_screen.dart';
import 'package:capstone_2026/feature/reservation/presentation/screen/reservation_screen.dart';
import 'package:capstone_2026/feature/information/presentation/screen/information_screen_root.dart';
import 'package:capstone_2026/feature/information/presentation/screen/information_view_model.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import '../../studycafe/presentation/screen/seat_selection_screen.dart';
import '../../studycafe/presentation/screen/time_selection_screen.dart';

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
              builder: (context, state) => HomeScope(
                viewModel: getIt<HomeViewModel>(),
              ),
              routes: [
                GoRoute(
                  parentNavigatorKey: _rootNavigatorKey,
                  path: Routes.search,
                  builder: (context, state) => const SearchScreen(),
                ),

                GoRoute(
                  name: 'information',
                  parentNavigatorKey: _rootNavigatorKey,
                  path: 'information/:storeId',
                  builder: (context, state) {
                    final storeId = state.pathParameters['storeId'] ?? '';
                    final extraData = state.extra is Map<String, dynamic>
                        ? state.extra as Map<String, dynamic>
                        : <String, dynamic>{};

                    return InformationScreenRoot(
                      viewModel: getIt<InformationViewModel>(),
                      storeId: storeId,
                    );
                  },
                  routes: [
                    // ... 기존 자식 루트들 (reservation, seat 등)
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
              routes: [
                GoRoute(
                  parentNavigatorKey: _rootNavigatorKey,
                  path: Routes.search,
                  builder: (context, state) => const SearchScreen(),
                ),
              ],
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
                  name: 'bookmark_information',
                  parentNavigatorKey: _rootNavigatorKey,
                  path: Routes.bookmarkStoreInformation,
                  builder: (context, state) {
                    final storeId = state.pathParameters['storeId'] ?? '';
                    final extraData = state.extra is Map<String, dynamic>
                        ? state.extra as Map<String, dynamic>
                        : <String, dynamic>{};

                    return InformationScreenRoot(
                      viewModel: getIt<InformationViewModel>(),
                      storeId: storeId,
                      name: extraData['name']?.toString() ?? '가게 이름 없음',
                      subtitle: extraData['subtitle']?.toString() ?? '',
                      rating: (extraData['rating'] as num?)?.toDouble() ?? 0.0,
                      category: extraData['category']?.toString() ?? '',
                    );
                  },
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
                  path: Routes.stampHistory,
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => StampHistoryScreenRoot(
                    viewModel: getIt<StampHistoryViewModel>(),
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
                  builder: (context, state) => const TermsScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return PartnerBottomAppBar(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.partnerHome,
              builder: (context, state) => const PartnerDashboardScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.partnerStore,
              builder: (context, state) => PartnerStoreManagementScope(
                viewModel: getIt<PartnerStoreManagementViewModel>(),
              ),
              routes: [
                GoRoute(
                  path: Routes.partnerAddressSearch,
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => AddressSearchScreenRoot(
                    viewModel: getIt<AddressSearchViewModel>(),
                  ),
                ),
                GoRoute(
                  path: Routes.partnerStoreMenus,
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => PartnerStoreMenuScope(
                    viewModel: getIt<PartnerStoreMenuViewModel>(),
                  ),
                ),
                GoRoute(
                  path: Routes.partnerStoreImages,
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => PartnerStoreImageScope(
                    viewModel: getIt<PartnerStoreImageViewModel>(),
                  ),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.partnerReservations,
              builder: (context, state) => PartnerReservationsScreenRoot(
                viewModel: getIt<PartnerReservationsViewModel>(),
              ),
              routes: [
                GoRoute(
                  path: Routes.partnerReservationSlotSettings,
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) =>
                      PartnerReservationSlotSettingsScope(
                        viewModel:
                            getIt<PartnerReservationSlotSettingsViewModel>(),
                      ),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.partnerMyPage,
              builder: (context, state) => PartnerMyPageScreenRoot(
                viewModel: getIt<PartnerMyPageViewModel>(),
              ),
              routes: [
                GoRoute(
                  path: Routes.partnerMyPageNotifications,
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const Scaffold(
                    body: SafeArea(
                      child: Center(child: Text('알림 페이지')),
                    ),
                  ),
                ),
                GoRoute(
                  path: Routes.partnerMyPageProfileEdit,
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const EditProfileScreen(),
                ),
                GoRoute(
                  path: Routes.partnerMyPageReservationHistory,
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const Scaffold(
                    body: SafeArea(
                      child: Center(child: Text('이용 내역 페이지')),
                    ),
                  ),
                ),
                GoRoute(
                  path: Routes.partnerMyPageReviewHistory,
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => ReviewHistoryScreenRoot(
                    viewModel: getIt<ReviewHistoryViewModel>(),
                  ),
                ),
                GoRoute(
                  path: Routes.partnerMyPageAccountSettings,
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) {
                    return AccountSettingScreenRoot(
                      viewModel: getIt<AccountSettingViewModel>(),
                    );
                  },
                ),
                GoRoute(
                  path: Routes.partnerMyPageNotificationSettings,
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const Scaffold(
                    body: SafeArea(
                      child: Center(child: Text('알림 설정 페이지')),
                    ),
                  ),
                ),
                GoRoute(
                  path: Routes.partnerMyPageInquiry,
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const Scaffold(
                    body: SafeArea(
                      child: Center(child: Text('1:1 문의 페이지')),
                    ),
                  ),
                ),
                GoRoute(
                  path: Routes.partnerMyPageNotices,
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const Scaffold(
                    body: SafeArea(
                      child: Center(child: Text('공지사항 페이지')),
                    ),
                  ),
                ),
                GoRoute(
                  path: Routes.partnerMyPageTerms,
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
    GoRoute(
      path: Routes.onBoarding,
      builder: (context, state) => OnBoardingScreenRoot(
        viewModel: getIt<OnBoardingViewModel>(),
      ),
    ),
    GoRoute(
      path: Routes.partnerOnboarding,
      builder: (context, state) => PartnerOnboardingScope(
        viewModel: getIt<PartnerOnboardingViewModel>(),
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
  final isInPartnerOnboarding = location == Routes.partnerOnboarding;
  final partnerShellBasePaths = [
    Routes.partnerHome,
    Routes.partnerStore,
    Routes.partnerReservations,
    Routes.partnerMyPage,
  ];
  final isInPartnerShell = partnerShellBasePaths.any(
    (path) => location == path || location.startsWith('$path/'),
  );
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
    return isInPartnerOnboarding ? null : Routes.partnerOnboarding;
  }

  final isApprovedPartner =
      registrationStatus == UserRegistrationStatus.exists &&
      userProfile != null &&
      userProfile.userType == UserType.partner &&
      userProfile.partnerStatus == PartnerStatus.approved;

  if (isApprovedPartner) {
    if (isInPartnerOnboarding ||
        isInAuthFlow ||
        location == Routes.onBoarding ||
        isInUserShell) {
      return Routes.partnerHome;
    }
    return null;
  }

  if (isInPartnerOnboarding || isInPartnerShell) {
    return Routes.home;
  }

  if (isInAuthFlow || location == Routes.onBoarding) {
    return Routes.home;
  }

  return null;
}
