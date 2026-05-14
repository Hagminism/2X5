# 미용실 고객 예약 플로우 — 최종 계획 (고정안)

이 문서는 **일반 사용자 미용실 예약**에 대해 합의된 설계를 한곳에 모은 최종 계획입니다. 구현 시 [convention.md](./convention.md) 및 `lib/feature/sign_in` 구조를 따릅니다.

---

## 1. 요약

- **업장 상세(홈·지도·검색)** 예약 탭에서 미용실은 가짜 시간표 대신 **디자이너 카드 목록**(사진·이름·소개)을 보여준다.
- 카드 탭 시 **`salon-reservation` 하위 또는 전용 경로**로 이동해 **캘린더·슬롯·구분선·시술 다중 선택·「다음 단계」**까지 진행한다. (라우팅은 **`~screen_root`에서 `switch(action)`으로만** 분기.)
- **확인 화면**은 `extra` 대신 **`Uri(path: ..., queryParameters: {...})` → `context.push(uri.toString())`** 로 쿼리를 넘긴다. (인코딩은 `Uri`가 처리.)
- **DB**: `salon_reservations.service_id` 제거, **`service_ids uuid[]`**. RPC **`create_salon_reservation(..., p_service_ids uuid[], ...)`** — 시술 **duration 합산**으로 `end_at` 계산, 근무 종료 초과 시 **`salon_end_time_out_of_schedule`**.
- **Information / Map / Search** 각 ViewModel에서 살롱 디자이너를 로드해 탭에 넘기고, 디자이너 탭 시 예약 상세 진입 액션을 보낸다. (DI·기존 셸 라우트 패턴 유지, child route 추가.)

마이그레이션 파일(로컬): `supabase/migrations/20260514000800_salon_reservation_service_ids.sql`  
원격 DB 반영은 **Supabase MCP `apply_migration`** 또는 Supabase CLI로 프로젝트에 적용하면 된다.

---

## 2. 데이터베이스 · RPC

| 항목 | 내용 |
|------|------|
| 컬럼 | `service_id` 제거 → `service_ids uuid[]` NOT NULL (기존 행은 `array[service_id]`로 백필 후 제약) |
| RPC 시그니처 | `create_salon_reservation(p_store_id, p_user_id, p_designer_id, p_service_ids uuid[], p_start_at)` |
| 검증 | 스토어·디자이너·시술(전부 해당 스토어·active)·스케줄·슬롯 정렬·합산 duration·일일 근무 종료 초과 검사 |
| 권한 | `security definer` 함수는 **`service_role`에만 execute grant** (기존 정책과 동일 취지) |
| 클라이언트 | Firebase `createSalonReservation` → `p_service_ids` 배열 전달; 응답·모델은 `service_ids` 반영 |

---

## 3. 라우팅

- `routes.dart` / `router.dart`에 child route 예시:
  - 필요 시 `salon-booking/:designerId` (디자이너별 상세)
  - `salon-booking-confirm` (확인; 쿼리로 `storeId`, `designerId`, `startAt`, `serviceIds` 등 전달)
- **`context.go` / `push`는 root에서만** 처리하고, 화면에서는 ViewModel 액션만 호출한다.

---

## 4. Flutter — 화면 · MVVM

| 영역 | 내용 |
|------|------|
| 예약 탭 | `StoreReservationStatusTab`: **Stateless 지향**, 상위에서 로드한 `List<SalonDesigner>` + 콜백. 미용실은 카드 UI, 하단 버튼 정책은 기존 합의(전체 예약 진입 등) 유지 가능. |
| 디자이너 상세 | 캘린더, 슬롯 그리드, **시술 다중 선택**, 「다음 단계」 — `state`/`action`/`event`는 **freezed + sealed**, `state`는 freezed. |
| 확인 | 쿼리 파싱 후 요약 표시·최종 제출(또는 다음 단계). |
| Scope / DI | `sign_in` 패턴과 동일; `di_setup.dart`에 factory 등록. |
| 기존 `salon_reservation` | 단일 시술 화면은 **`serviceIds: [id]`** 제출 등으로 정리하거나, 신규 플로우로 통합해 중복 진입 제거. |

---

## 5. 슬롯 · 예약 겹침 (설계 메모)

- 현재 정책: **시작 슬롯 단위**로만 막는 방식이 있을 수 있음.
- **개선(합의)**: 기존 예약과 **시간 구간 겹침**을 반영해 슬롯 비활성화 (`start_at`~`end_at` vs 선택 시술 합산 구간). (구현 시 ViewModel·쿼리 일관성 유지.)

---

## 6. 작업 체크리스트 (남은 것)

- [ ] 원격 DB에 `20260514000800_salon_reservation_service_ids` 적용 (MCP `apply_migration` 또는 CLI)
- [ ] `SalonReservation` / Repository / DataSource / Functions — `service_ids` 일원화 (일부는 이미 반영됨)
- [ ] 디자이너 예약 **상세·확인** MVVM + Scope + **child routes** + root `switch`
- [ ] 슬롯 겹침(합산 duration) UI 반영
- [ ] `flutter analyze`, Functions `npm run build` / `lint`

---

## 7. 참고 문서

- [salon_reservation_plan.md](./salon_reservation_plan.md) — 초기 테이블·RPC 개념(일부는 `service_id` 단일 전제; **본 문서가 최종 스키마·플로우 기준**)
- [convention.md](./convention.md) — PR 컨벤션·아키텍처 규칙
