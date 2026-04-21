import 'package:app_links/app_links.dart';
import 'package:capstone_2026/core/domain/repository/auth/auth_repository.dart';
import 'package:capstone_2026/core/presentation/component/custom_bottom_app_bar.dart';
import 'package:capstone_2026/core/routing/core/component/auth_refresh_notifier.dart';
import 'package:capstone_2026/core/routing/routes.dart';
import 'package:capstone_2026/di/di_setup.dart';
import 'package:capstone_2026/feature/find_password/presentation/screen/find_password_screen_root.dart';
import 'package:capstone_2026/feature/find_password/presentation/screen/find_password_view_model.dart';
import 'package:capstone_2026/feature/home/presentation/screen/home_screen.dart';
import 'package:capstone_2026/feature/my_page/account_settings/presentation/screen/account_setting_screen_root.dart';
import 'package:capstone_2026/feature/my_page/account_settings/presentation/screen/account_setting_view_model.dart';
import 'package:capstone_2026/feature/my_page/settings/presentation/screen/edit_profile_screen.dart';
import 'package:capstone_2026/feature/bookmark/presentation/screen/bookmark_screen.dart';
import 'package:capstone_2026/feature/bookmark_store_detail/presentation/screen/bookmark_store_detail_screen.dart';
import 'package:capstone_2026/feature/my_page/settings/presentation/screen/my_page_screen_root.dart';
import 'package:capstone_2026/feature/my_page/settings/presentation/screen/my_page_view_model.dart';
import 'package:capstone_2026/feature/on_boarding/presentation/screen/on_boarding_screen_root.dart';
import 'package:capstone_2026/feature/select_auth_provider/core/presentation/component/scope/select_auth_provider_scope.dart';
import 'package:capstone_2026/feature/select_auth_provider/presentation/screen/select_auth_provider_view_model.dart';
import 'package:capstone_2026/feature/sign_in/core/presentation/component/scope/sign_in_scope.dart';
import 'package:capstone_2026/feature/sign_in/presentation/screen/sign_in_view_model.dart';
import 'package:capstone_2026/feature/map/presentation/screen/map_screen.dart';
import 'package:capstone_2026/feature/store_detail/presentation/screen/store_detail_screen.dart';
import 'package:capstone_2026/feature/sign_up_partner/presentation/sign_up_partner_screen_root.dart';
import 'package:capstone_2026/feature/sign_up_partner/presentation/sign_up_partner_view_model.dart';
import 'package:capstone_2026/feature/sign_up_customer/presentation/screen/sign_up_customer_screen_root.dart';
import 'package:capstone_2026/feature/sign_up_customer/presentation/screen/sign_up_customer_view_model.dart';
import 'package:capstone_2026/feature/sign_up_type/presentation/screen/sign_up_type_screen_root.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _myPageShellNavigatorKey = GlobalKey<NavigatorState>();

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
            // TODO: 소셜 로그인 인증 붙으면 중첩 -> 단일 라우트 분리할 것.
            GoRoute(
              path: Routes.signUpType,
              builder: (context, state) => SignUpTypeScreenRoot(),
              routes: [
                GoRoute(
                  path: Routes.signUpCustomer,
                  builder: (context, state) => SignUpCustomerScreenRoot(
                    viewModel: getIt<SignUpCustomerViewModel>(),
                  ),
                ),
                GoRoute(
                  path: Routes.signUpPartner,
                  builder: (context, state) => SignUpPartnerScreenRoot(
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
                  path: Routes.homeStoreDetail,
                  builder: (context, state) => StoreDetailScreen(
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
          navigatorKey: _myPageShellNavigatorKey,
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
                  builder: (context, state) => const Scaffold(
                    body: SafeArea(
                      child: Center(child: Text('리뷰 내역 페이지')),
                    ),
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
    GoRoute(
      path: Routes.onBoarding,
      builder: (context, state) => const OnBoardingScreenRoot(),
    ),
  ],
  redirect: _redirect,
  refreshListenable: AuthRefreshNotifier(
    getIt<AuthRepository>().authStateChanges(),
  ),
);

// 리다이렉트 로직
// TODO: 회원 탈퇴(deleteAccount) 후 리다이렉션 문제 있는지 추가 확인해야함
Future<String?> _redirect(BuildContext context, GoRouterState state) async {
  final currentUser = getIt<AuthRepository>().getCurrentUser();

  final isLoggedIn = currentUser != null;
  final location = state.matchedLocation;
  final isInAuthFlow =
      location == Routes.signIn || location.startsWith('${Routes.signIn}/');

  if (!isLoggedIn) {
    return isInAuthFlow ? null : Routes.signIn;
  }

  if (isInAuthFlow) {
    return Routes.home;
  }

  return null;
}
