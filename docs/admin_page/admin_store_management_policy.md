# 관리자 업장 관리 정책 (초안 확정본)

## 1. 목적

관리자 업장 관리(기본 정보/위치/운영시간) 구현 전, 권한과 데이터 검증 기준을 확정한다.

---

## 2. 권한 정책

- `partner_status == approved`인 사용자에게만 업장 관리 기능을 허용한다.
- `partner_status != approved`인 사용자는 업장 관리 조회/수정/저장을 모두 차단한다.
- 클라이언트 라우팅 제어와 별개로, 서버(API/함수)에서도 동일 정책을 강제한다.

---

## 3. stores 필수 입력/수정 정책

## 필수 필드

- `owner_id`
- `name`
- `category`
- `business_number`
- `address`
- `latitude`
- `longitude`
- `contact`
- `operating_hours`

## 수정 정책

- `business_number`는 최초 생성 후 수정 불가(immutable)로 처리한다.
- `owner_id`는 인증 사용자 식별자와 동일해야 하며, 클라이언트 입력값을 신뢰하지 않는다.

---

## 4. 위치 정보 정책

- `address` 입력 시 좌표(`latitude`, `longitude`)가 함께 저장되어야 한다.
- 좌표는 둘 다 존재해야 하며, 단일 값만 저장되는 상태를 허용하지 않는다.

---

## 5. operating_hours 정책

## 데이터 구조

- 요일별 객체에 `isOpened`만 사용한다.
- `isClosed`는 사용하지 않는다.

예시(JSON):

```json
{
  "mon": { "isOpened": true, "openTime": "09:00", "closeTime": "18:00" },
  "tue": { "isOpened": true, "openTime": "22:00", "closeTime": "02:00" },
  "wed": { "isOpened": false, "openTime": null, "closeTime": null }
}
```

## 검증 규칙

- `isOpened == false`이면 `openTime`, `closeTime`은 `null`이어야 한다.
- `isOpened == true`이면 `openTime`, `closeTime`은 모두 필수다.
- 시간 포맷은 `HH:mm`(24시간제)로 고정한다.
- `openTime == closeTime`은 허용하지 않는다.
- 야간 영업은 허용한다. (`openTime > closeTime`이면 익일 마감으로 해석)

---

## 6. 구현 우선순위

1. 정책 문서 기준으로 도메인 모델/DTO를 정의한다.
2. 저장/수정 API에서 권한(`approved`)과 필드 검증을 강제한다.
3. 화면 폼 유효성 검증을 API 규칙과 동일하게 맞춘다.
4. 테스트에서 교차 테넌트 접근 차단 및 `business_number` 수정 불가를 검증한다.
