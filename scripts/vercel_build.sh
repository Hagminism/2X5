#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

# Google 로그인 + 지도/검색 1차 배포에 필요한 값만 필수.
# 네이버·카카오 로그인용 secret은 placeholder로 채워 웹 번들 노출을 피한다.
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
    echo "[vercel_build] Local: base64 < lib/firebase_options.dart | pbcopy"
    exit 1
  fi

  echo "${FIREBASE_OPTIONS_DART_B64}" | base64 --decode > lib/firebase_options.dart
  echo "[vercel_build] Restored lib/firebase_options.dart from FIREBASE_OPTIONS_DART_B64"
}

restore_firebase_options

resolve_redirect_uri() {
  if [ -n "${REDIRECT_URI:-}" ]; then
    echo "${REDIRECT_URI}"
    return
  fi
  if [ -n "${VERCEL_URL:-}" ]; then
    echo "https://${VERCEL_URL}"
    return
  fi
  echo "https://placeholder.invalid"
}

KAKAO_NATIVE_APP_KEY_VALUE="${KAKAO_NATIVE_APP_KEY:-unused-web-google-only}"
NAVER_CLIENT_ID_VALUE="${NAVER_CLIENT_ID:-unused-web-google-only}"
NAVER_CLIENT_SECRET_VALUE="${NAVER_CLIENT_SECRET:-unused-web-google-only}"
REDIRECT_URI_VALUE="$(resolve_redirect_uri)"

if [ -z "${KAKAO_NATIVE_APP_KEY:-}" ] ||
  [ -z "${NAVER_CLIENT_ID:-}" ] ||
  [ -z "${NAVER_CLIENT_SECRET:-}" ] ||
  [ -z "${REDIRECT_URI:-}" ]; then
  echo "[vercel_build] OAuth placeholders applied (Google-only web deploy)."
  echo "[vercel_build] Set NAVER_* / REDIRECT_URI in Vercel when enabling Naver login."
fi

cat > .env <<EOF
SUPABASE_URL=${SUPABASE_URL}
SUPABASE_PUBLISHABLE_KEY=${SUPABASE_PUBLISHABLE_KEY}
KAKAO_NATIVE_APP_KEY=${KAKAO_NATIVE_APP_KEY_VALUE}
KAKAO_REST_API_KEY=${KAKAO_REST_API_KEY}
NAVER_MAP_CLIENT_ID=${NAVER_MAP_CLIENT_ID}
NAVER_CLIENT_ID=${NAVER_CLIENT_ID_VALUE}
NAVER_CLIENT_SECRET=${NAVER_CLIENT_SECRET_VALUE}
NAVER_PROXY_URL=${NAVER_PROXY_URL}
REDIRECT_URI=${REDIRECT_URI_VALUE}
GOOGLE_WEB_CLIENT_ID=${GOOGLE_WEB_CLIENT_ID}
GOOGLE_PLACES_API_KEY=${GOOGLE_PLACES_API_KEY:-}
EOF

echo "[vercel_build] .env generated from Vercel environment variables"

if [ ! -d ".flutter" ]; then
  echo "[vercel_build] Installing Flutter SDK (stable)..."
  git clone https://github.com/flutter/flutter.git -b stable .flutter --depth 1
fi

export PATH="$ROOT_DIR/.flutter/bin:$PATH"
export CI=true

flutter --version
flutter config --enable-web
flutter pub get
flutter build web --release

echo "[vercel_build] Done. Output: build/web"
