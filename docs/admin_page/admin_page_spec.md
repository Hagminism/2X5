# 관리자 페이지 기능 명세 (stores 컬럼 반영)

## 1. 문서 목적

이 문서는 `docs/PRD.md`의 관리자 요구사항을 기준으로, 현재 `stores` 테이블 컬럼 구조를 반영한 관리자 페이지 기능 범위를 정리한다. 또한 `docs/requirements_specification.md`, `docs/project_proposal.md`, `docs/convention.md`의 관련 요구를 함께 반영한다.

---

## 2. 범위

- 대상: 업장 운영자(관리자) 페이지
- 기준 문서:
  - `docs/PRD.md`
  - `docs/requirements_specification.md`
  - `docs/project_proposal.md`
  - `docs/convention.md`
- 데이터 기준: 공유된 `stores` 테이블 컬럼

---

## 3. 관리자 페이지 IA

- 대시보드
- 사업자 인증
- 업장 관리
- 예약 자원 관리
- 예약 현황
- 설정

관리자 계정은 회원가입 시 일반 사용자와 동일한 기본 정보만 입력하여 생성하고, 사업자 인증 및 업장 등록은 관리자 페이지 진입 후 진행한다.

---

## 4. stores 컬럼 현황

- `id` (uuid, PK)
- `owner_id` (text)
- `name` (text)
- `category` (store_category enum)
- `business_number` (varchar)
- `address` (text)
- `latitude` (float8)
- `longitude` (float8)
- `naver_place_id` (text)
- `contact` (text)
- `operating_hours` (jsonb)
- `created_at` (timestamptz)

---

## 5. 화면별 데이터 매핑

### 5.1 업장 관리

- 사용 컬럼:
  - `name`, `category`, `address`, `contact`
  - `latitude`, `longitude`, `naver_place_id`
  - `operating_hours`
- 주요 기능:
  - 업장 기본 정보 등록/수정
  - 위치 정보 등록/수정
  - 운영 시간 등록/수정

### 5.2 사업자 인증

- 사용 컬럼:
  - `business_number`
- 추가 입력 요구(요구사항 명세 반영):
  - `representative_name` (대표자명)
  - `opened_on` (개업일자)
- 참고:
  - 사업자등록증 파일, 승인 상태, 반려 사유 등은 `stores`만으로 표현이 제한되므로 별도 인증 테이블이 적합함
  - 국세청 사업자등록정보 진위확인 API 결과를 저장/추적할 수 있어야 함
  - 가입 단계에서는 사업자 세부 정보를 강제하지 않고, 관리자 페이지에서 단계적으로 입력/제출하는 흐름을 기본으로 함

### 5.3 권한 분리

- 사용 컬럼:
  - `owner_id`
- 주요 정책:
  - 관리자는 본인 `owner_id`에 연결된 업장만 조회/수정 가능

### 5.4 예약 자원 관리 / 예약 현황

- 비고:
  - PRD의 `Resource`, `Reservation` 도메인은 `stores` 외 별도 테이블이 필요함
  - `stores`는 업장 마스터 정보 역할에 집중

---

## 6. PRD 기준 필수 기능 반영 체크

- 업장 정보 등록/수정: 가능 (`name`, `category`, `address`, `contact`, 위치 컬럼)
- 운영 시간 관리: 가능 (`operating_hours`)
- 사업자 정보 입력: 가능 (`business_number`)
- 사업자 인증 첨부/승인 상태: 별도 테이블 필요
- 예약 가능 자원 관리: 별도 `resources` 테이블 필요
- 예약 현황 조회: 별도 `reservations` 테이블 필요

### 6.1 가입/인증 분리 정책

- 관리자 회원가입:
  - 일반 사용자와 동일하게 기본 정보만 입력하여 계정 생성
- 관리자 기능 활성화:
  - 사업자 인증 제출 및 승인 상태(`pending`, `approved`, `rejected`)에 따라 단계적으로 허용
- 정책 의도:
  - 가입 이탈률을 낮추고, 검증 실패를 회원가입 실패와 분리하여 UX를 단순화

---

## 7. 스키마 보완 권장사항

### 7.1 owner_id 타입 정합성

- 현재 `owner_id`가 `text`인 경우, 인증 사용자 식별자 타입과 불일치 가능성이 있음
- 권장: 인증 사용자 PK 타입(일반적으로 `uuid`)과 동일하게 맞추고 FK를 설정

### 7.2 business_number 무결성

- 권장:
  - `UNIQUE` 제약으로 동일 사업자번호 중복 등록 방지
  - 형식 검증(숫자 10자리/하이픈 처리 정책) 적용

### 7.3 위치 좌표 유효성

- 권장:
  - `latitude`, `longitude`는 둘 다 있거나 둘 다 없어야 함
  - 좌표 범위 체크 제약 추가 검토

### 7.4 operating_hours 검증

- `jsonb` 사용 자체는 확장에 유리함
- 권장:
  - 요일별 구조/시간 포맷에 대한 JSON 스키마 규칙을 애플리케이션 레이어에서 검증
  - 운영시간 역전(오픈 > 마감) 및 휴무 처리 규칙 명시

### 7.5 멀티테넌트 격리 및 접근 제어

- 권장:
  - 업장/예약/자원 데이터는 `owner_id` 기준으로 조회 범위를 강제
  - 데이터 레이어와 API 레이어 모두에서 테넌트 스코프 누락을 방지
  - 관리자 계정 간 교차 접근을 차단하는 테스트 케이스를 포함

### 7.6 실시간 동기화 운영성

- 권장:
  - 예약 생성/변경/취소 이벤트가 관리자 화면에 지연 없이 반영되도록 설계
  - 동시성 충돌 시 사용자/관리자에게 동일한 최종 상태가 보이도록 상태 동기화를 보장

### 7.7 사용자 역할과 검증 상태 분리

- 권장:
  - 사용자 역할(`role`: `customer`/`partner`)과 관리자 검증 상태(`partner_status`)를 분리 관리
  - `partner_status`가 `approved`가 아니면 업장 공개/예약 수신 등 핵심 관리자 기능을 제한

---

## 8. 후속 테이블 분리 제안

### 8.1 owner_verifications

- 목적: 사업자 인증 제출 이력 및 승인 상태 관리
- 예시 필드:
  - `id`, `owner_id`, `store_id`
  - `representative_name`, `opened_on`, `business_number`
  - `license_file_url`
  - `nts_validation_result`, `nts_validated_at`
  - `status` (`pending`, `approved`, `rejected`)
  - `rejection_reason`
  - `submitted_at`, `reviewed_at`

### 8.2 resources

- 목적: 업장별 예약 가능 자원 관리
- 예시 필드:
  - `id`, `store_id`, `name`, `resource_type`
  - `min_capacity`, `max_capacity`
  - `slot_minutes`, `is_active`

### 8.3 reservations

- 목적: 예약 생성/상태 전이/중복 방지 관리
- 예시 필드:
  - `id`, `store_id`, `resource_id`, `user_id`
  - `date`, `start_time`, `end_time`, `party_size`
  - `status`, `request_note`, `created_at`

---

## 9. 결론

현재 `stores` 스키마는 업장 정보 관리 요구사항을 충실히 수용할 수 있다. 다만 관리자 핵심 기능(사업자 승인 흐름, 예약 자원 관리, 예약 현황 조회)을 완성하려면 `owner_verifications`, `resources`, `reservations`와 같은 도메인 테이블 분리가 필요하다. 추가로 요구사항 명세와 제안서 기준의 사업자 검증 강화(대표자명/개업일자/국세청 검증), 멀티테넌트 격리, 실시간 동기화 요구를 함께 반영해야 운영 안정성을 확보할 수 있다.
