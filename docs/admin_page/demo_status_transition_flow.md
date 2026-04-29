# 관리자 인증 상태 전이 데모 플로우

## 목적

- 관리자 인증 제출 이후 상태 전이를 시현할 수 있도록 데모 절차를 정의한다.
- 운영진 승인/반려 액션은 Firebase Functions를 통해 수행한다.

---

## 현재 동작 요약

1. 파트너 회원가입 시 `users.partner_status`는 `unverified`로 생성된다.
2. 관리자 온보딩에서 인증 정보를 제출하면 `submitPartnerVerification` 함수가 실행된다.
3. 함수에서 다음 작업을 수행한다.
   - `owner_verifications`에 제출 정보 저장
   - `users.partner_status`를 `pending`으로 갱신
4. 앱은 `pending` 상태를 감지하면 심사중 화면을 노출한다.

---

## 데모용 운영진 액션

### 1) 승인 처리 함수

- 함수명: `approvePartnerForDemo`
- 용도: `pending -> approved`
- 제한: `DEMO_ADMIN_KEY` 값이 일치할 때만 실행

### 2) 반려 처리 함수

- 함수명: `rejectPartnerForDemo`
- 용도: `pending -> rejected`
- 제한: `DEMO_ADMIN_KEY` 값이 일치할 때만 실행

---

## Postman 호출 예시

### 승인

- `POST https://<region>-<project>.cloudfunctions.net/approvePartnerForDemo`
- Body(JSON):

```json
{
  "targetUid": "firebase_uid_here",
  "demoKey": "DEMO_ADMIN_KEY 값"
}
```

### 반려

- `POST https://<region>-<project>.cloudfunctions.net/rejectPartnerForDemo`
- Body(JSON):

```json
{
  "targetUid": "firebase_uid_here",
  "demoKey": "DEMO_ADMIN_KEY 값"
}
```

---

## 앱에서의 상태 반영

- `pending` 화면에서 `상태 새로고침` 버튼을 누르면 최신 상태를 조회한다.
- `approved`로 변경되면 라우터 리다이렉트에 따라 홈으로 이동한다.
- `rejected`로 변경되면 반려 화면이 노출되고 `재제출하기`를 통해 폼으로 복귀한다.

---

## 상태 전이 규칙

- 허용:
  - `pending -> approved`
  - `pending -> rejected`
- 비허용:
  - `approved -> rejected`
  - `rejected -> approved`
  - `unverified -> approved/rejected` (제출 없이 처리 금지)
