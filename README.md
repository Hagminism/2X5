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

본 프로젝트는 Android/iOS/main.dart 세 곳에서 Kakao 키를 사용합니다.

#### Android

`android/local.properties`에 아래 값을 추가하세요.

```properties
kakaoNativeAppKey=YOUR_KAKAO_NATIVE_APP_KEY
```

#### iOS

`ios/Runner/Secrets.xcconfig`에 아래 값을 추가하세요.

```xcconfig
GOOGLE_REVERSE_CLIENT_ID=YOUR_GOOGLE_REVERSE_CLIENT_ID
KAKAO_NATIVE_APP_KEY=YOUR_KAKAO_NATIVE_APP_KEY
```

> `Secrets.xcconfig`는 iOS 프로젝트의 base configuration으로 연결되어 있으므로 파일이 없으면 iOS 빌드가 실패할 수 있습니다.

#### main.dart Initializing

루트의 `.env`에 아래 값을 추가하세요.

```properties
kakaoNativeAppKey=YOUR_KAKAO_NATIVE_APP_KEY
```

### 4) Naver 로그인 설정

네이버 로그인은 **`.env` + `android/local.properties` + iOS 설정**이 모두 맞아야 동작합니다.

#### 1. 네이버 개발자센터에서 값 준비
- `NAVER_CLIENT_ID`
- `NAVER_CLIENT_SECRET`
- `REDIRECT_URI` (팀 공통값으로 고정)

> `REDIRECT_URI`는 네이버 콘솔 등록값과 앱 설정값이 **완전히 동일**해야 합니다. 슬래시(/) 하나도 허용되지 않으니 유의합니다.

#### 2. 루트의 `.env`에 아래 값을 추가

```properties
NAVER_CLIENT_ID=YOUR_NAVER_CLIENT_ID
NAVER_CLIENT_SECRET=YOUR_NAVER_CLIENT_SECRET
REDIRECT_URI=YOUR_REDIRECT_URI
```

#### 3. (Android) `android/local.properties`에 값 추가

```properties
naverClientId=YOUR_NAVER_CLIENT_ID
naverClientSecret=YOUR_NAVER_CLIENT_SECRET
redirectUri=YOUR_REDIRECT_URI
```

#### 4. (iOS) `ios/Runner/Secrets.xcconfig`에 값 추가

```properties
URL_SCHEME=YOUR_URL_SCHEME
NAVER_CLIENT_ID=YOUR_NAVER_CLIENT_ID
NAVER_CLIENT_SECRET=YOUR_NAVER_CLIENT_SECRET
SERVICE_APP_NAME=team2x5
```

### 5) Naver 지도 설정

#### 1. 네이버 클라우드 플랫폼에서 값 준비
- `NAVER_MAP_CLIENT_ID`
- `NAVER_MAP_CLIENT_SECRET`

> 네이버 클라우드 플랫폼 콘솔 → Maps → 애플리케이션 → **Web 서비스 URL**에 `http://localhost` 를 추가해야 지도가 정상 로드됩니다.

#### 2. 루트의 `.env`에 아래 값을 추가

```properties
NAVER_MAP_CLIENT_ID=YOUR_NAVER_MAP_CLIENT_ID
NAVER_MAP_CLIENT_SECRET=YOUR_NAVER_MAP_CLIENT_SECRET
```

#### 3. (Android) `android/local.properties`에 값 추가

```properties
naverMapClientId=YOUR_NAVER_MAP_CLIENT_ID
naverMapClientSecret=YOUR_NAVER_MAP_CLIENT_SECRET
```

#### 4. (iOS) `ios/Runner/Secrets.xcconfig`에 값 추가

```xcconfig
NAVER_MAP_CLIENT_ID=YOUR_NAVER_MAP_CLIENT_ID
NAVER_MAP_CLIENT_SECRET=YOUR_NAVER_MAP_CLIENT_SECRET
```

### 6) Supabase 설정

#### 루트의 `.env`에 아래 값을 추가하세요.

```properties
SUPABASE_URL=YOUR_SUPABASE_URL
SUPABASE_PUBLISHABLE_KEY=YOUR_SUPABASE_PUBLISHABLE_KEY
```

### 7) Firebase Functions 의존성 설치

```bash
cd functions
npm install
cd ..
```

### 8) iOS Pod 설치 (iOS 개발 시)

```bash
cd ios
pod install
cd ..
```

### 9) 실행

```bash
flutter run
```