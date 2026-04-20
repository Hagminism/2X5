import 'package:capstone_2026/di/di_setup.dart';
import 'package:capstone_2026/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk_common.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/routing/router.dart';
import 'ui/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

<<<<<<< HEAD
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    await GoogleSignIn.instance.initialize(
      serverClientId: DefaultFirebaseOptions.currentPlatform.androidClientId,
    );

    const kakaoNativeAppKey = String.fromEnvironment('KAKAO_NATIVE_APP_KEY');
    KakaoSdk.init(nativeAppKey: kakaoNativeAppKey);

    await dotenv.load(fileName: '.env');

    diSetup();

    runApp(const App());
  } catch (e, stack) {
    debugPrint('❌ [FATAL ERROR] 앱 초기화 실패: $e');
    debugPrint('❌ [STACK TRACE] $stack');
    
    // 초기화 실패 시 에러 화면을 표시하는 앱 실행
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                const Text('앱 초기화 중 오류가 발생했습니다.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(e.toString(), textAlign: Center, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
      ),
    ));
  }
=======
  await dotenv.load(fileName: '.env');

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Supabase 객체는 전역 싱글톤이므로, getIt에서 가리키는 대상과 같음
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_PUBLISHABLE_KEY'] ?? '',
  );

  // GoogleSignIn 객체는 전역 싱글톤이므로, getIt에서 가리키는 대상과 같음
  await GoogleSignIn.instance.initialize(
    serverClientId: DefaultFirebaseOptions.currentPlatform.androidClientId,
  );

  KakaoSdk.init(
    nativeAppKey: dotenv.env['KAKAO_NATIVE_APP_KEY'] ?? '',
  );

  diSetup();

  runApp(const App());
>>>>>>> 530d80c45c05c28ddad956974b7fdf12011574bd
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
