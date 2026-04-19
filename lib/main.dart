import 'package:capstone_2026/di/di_setup.dart';
import 'package:capstone_2026/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk_common.dart';

import 'core/routing/router.dart';
import 'ui/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    // GoogleSignIn 객체는 전역 싱글톤이므로, getIt에서 가리키는 대상과 같음
    await GoogleSignIn.instance.initialize(
      serverClientId: DefaultFirebaseOptions.currentPlatform.androidClientId,
    );

    // 'String.fromEnvironment'를 사용해 빌드 타임 변수를 읽어옵니다.
    // const를 사용해야 컴파일 시점에 최적화되어 보안에 더 유리합니다.
    const kakaoNativeAppKey = String.fromEnvironment('KAKAO_NATIVE_APP_KEY');

    KakaoSdk.init(
      nativeAppKey: kakaoNativeAppKey,
    );

    await dotenv.load(fileName: '.env');

    diSetup();

    runApp(const App());
  } catch (e, stack) {
    debugPrint('❌ [ERROR] 초기화 중 오류 발생: $e');
  }
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Reservation Hub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF7FAFF),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
        ),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
