#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

# Google 로그인 + 지도/검색 1차 배포에 필요한 값만 필수.
# 네이버·카카오 OAuth secret은 create_web_env.sh에서 placeholder 처리.
required_vars=(
  SUPABASE_URL
  SUPABASE_PUBLISHABLE_KEY
  GOOGLE_WEB_CLIENT_ID
  NAVER_MAP_CLIENT_ID
  NAVER_PROXY_URL
  KAKAO_REST_API_KEY
)

for var in "${required_vars[@]}"; do
  if [ -z "${!var:-}" ]; then
    echo "[vercel_build] Missing required environment variable: ${var}"
    exit 1
  fi
done

restore_firebase_options() {
  mkdir -p lib

  if [ -f lib/firebase_options.dart ]; then
    echo "[vercel_build] Using existing lib/firebase_options.dart"
    return
  fi

  if [ -z "${FIREBASE_OPTIONS_DART_B64:-}" ]; then
    echo "[vercel_build] lib/firebase_options.dart not found."
    echo "[vercel_build] Set Vercel env FIREBASE_OPTIONS_DART_B64 (base64 of firebase_options.dart)."
    exit 1
  fi

  echo "${FIREBASE_OPTIONS_DART_B64}" | base64 --decode > lib/firebase_options.dart
  echo "[vercel_build] Restored lib/firebase_options.dart from FIREBASE_OPTIONS_DART_B64"
}

restore_firebase_options
bash scripts/create_web_env.sh

ensure_flutter() {
  if command -v flutter >/dev/null 2>&1; then
    echo "[vercel_build] Using Flutter from PATH: $(command -v flutter)"
    return
  fi

  FLUTTER_DIR="${ROOT_DIR}/.vercel-cache/flutter"
  if [ ! -x "${FLUTTER_DIR}/bin/flutter" ]; then
    echo "[vercel_build] Installing Flutter SDK (stable) to ${FLUTTER_DIR}..."
    mkdir -p "$(dirname "${FLUTTER_DIR}")"
    git clone https://github.com/flutter/flutter.git -b stable "${FLUTTER_DIR}" --depth 1
    "${FLUTTER_DIR}/bin/flutter" precache --web
  fi

  export PATH="${FLUTTER_DIR}/bin:${PATH}"
  echo "[vercel_build] Using Flutter from ${FLUTTER_DIR}"
}

ensure_flutter
export CI=true

flutter --version
flutter config --enable-web
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter build web --release

echo "[vercel_build] Done. Output: build/web"
