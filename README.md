# capstone_2026

2026 한성대학교 모바일 캡스톤디자인 2X5 

## Getting Started

클론 후 바로 실행하려면 아래 순서대로 세팅해주세요.

### 1) Flutter/Dart 환경 준비

- Dart SDK: `^3.10.1` (pubspec 기준)
- 의존성 설치:

```bash
flutter pub get
```

### 2) Firebase 설정

이 프로젝트는 Firebase 초기화 파일을 Git에 포함하지 않습니다.

- `lib/firebase_options.dart`
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

아래 명령으로 각 파일을 생성하세요.

```bash
flutterfire configure
```

### 3) Kakao 키 설정

본 프로젝트는 Android/iOS/Dart 세 곳에서 Kakao 키를 사용합니다.

#### Android

`android/local.properties`에 아래 값을 추가하세요.

```properties
kakaoNativeAppKey=YOUR_KAKAO_NATIVE_APP_KEY
```

#### iOS

`ios/Runner/Secrets.xcconfig` 파일을 생성하고 아래 값을 넣어주세요.

```xcconfig
GOOGLE_REVERSE_CLIENT_ID=YOUR_GOOGLE_REVERSE_CLIENT_ID
KAKAO_NATIVE_APP_KEY=YOUR_KAKAO_NATIVE_APP_KEY
```

> `Secrets.xcconfig`는 iOS 프로젝트의 base configuration으로 연결되어 있으므로 파일이 없으면 iOS 빌드가 실패할 수 있습니다.

#### Dart 런타임

`main.dart`에서 `String.fromEnvironment('KAKAO_NATIVE_APP_KEY')`를 사용하므로, 실행 시 `--dart-define` 전달이 필요합니다.

### 4) iOS Pod 설치 (iOS 개발 시)

```bash
cd ios
pod install
cd ..
```

### 5) 실행

```bash
flutter run --dart-define=KAKAO_NATIVE_APP_KEY=YOUR_KAKAO_NATIVE_APP_KEY
```

### 6) Android Studio Run Configuration에서 dart-define 설정

Android Studio를 사용하는 경우 매번 터미널 명령을 입력하지 않고 Run Configuration에 `dart-define`을 고정할 수 있습니다.

1. 상단 실행 구성 드롭다운에서 **Edit Configurations...** 선택
2. Flutter 실행 구성(예: `main.dart`) 선택
3. **Additional run args**(또는 Extra arguments) 항목에 아래 값 입력

```text
--dart-define=KAKAO_NATIVE_APP_KEY=YOUR_KAKAO_NATIVE_APP_KEY
```

4. Apply -> OK 후 실행