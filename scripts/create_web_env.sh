#!/usr/bin/env bash
set -euo pipefail

# Vercel / GitHub Actions 웹 빌드용 .env 생성.
# 필수 env는 호출 스크립트에서 검증한다.

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
  echo "[create_web_env] OAuth placeholders applied (Google-only web deploy)."
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

echo "[create_web_env] .env generated"
