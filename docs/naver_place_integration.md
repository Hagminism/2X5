# 네이버 플레이스 연동 구현 문서

> 최종 수정일: 2026-05-26

## 1. 개요

지도 화면(`MapScreen`)에서 주변 매장을 검색할 때, 네이버 API를 통해 매장의 **상세 정보(전화번호, 영업시간, 대표 이미지, 네이버 플레이스 ID)** 를 수집하여 Supabase DB에 저장하는 기능입니다.

### 시연용 검색 정책 (`MapScreen`)

1. **시연 전** 비공식 API로 Supabase `stores` 사전 적재 (운영 작업).
2. **신규 enrich**는 mobile search → Summary → Hours 프록시 유지.
3. **지역 중복 방지**: 이전 크롤 bbox와 겹침 비율(분모=현재 bbox) **≥ 90%** 이면 카카오·네이버 **skip**, Supabase bbox 조회만. **&lt; 90%** 이면 API 1세트, **DB에 없는 매장만** 저장.
4. **재검색 쿨다운 3초**: 「현 지도에서 검색」 버튼만 회색 비활성. 로딩은 검색·마커 반영 **완료 후** 해제.

유틸: `lib/core/domain/util/map_search_area.dart`

---

## 2. 아키텍처

### 데이터 수집 파이프라인

```
[1단계] 네이버 공식 로컬 검색 API
   ↓  매장명, 주소, 좌표 확보
[2단계] 네이버 모바일 웹 검색 (m.search.naver.com)
   ↓  Place ID, 전화번호 추출
[3단계] 네이버 플레이스 요약 API (map.naver.com/p/api/place/summary)
   ↓  전화번호, 대표 이미지, 리뷰 점수, 영업시간 요약 텍스트(fallback)
[3-1단계] 로컬 프록시 GraphQL `/api/place/{id}/hours` (신규 등록 시 병렬)
   ↓  요일별 영업시간 → `operating_hours` 구조화 저장
[4단계] Supabase DB 저장
```

### 관련 파일

| 파일 | 역할 |
|---|---|
| `lib/feature/store_detail/data/data_source/naver_store_search_data_source.dart` | 인터페이스 정의 |
| `lib/feature/store_detail/data/data_source/naver_store_search_data_source_impl.dart` | 구현체 |
| `lib/feature/map/presentation/screen/map_screen.dart` | 지도 화면 (매장 검색 & 등록 로직) |
| `lib/core/domain/util/map_search_area.dart` | 검색 bbox·겹침 비율 계산 |

---

## 3. API 상세

### 3-1. 네이버 공식 로컬 검색 API

- **엔드포인트**: `GET https://openapi.naver.com/v1/search/local.json`
- **인증**: `X-Naver-Client-Id`, `X-Naver-Client-Secret` 헤더 (`.env`에서 로드)
- **용도**: 키워드 기반 매장 목록 검색
- **메서드**: `searchStoresByKeyword(keyword, display)`

**반환 데이터**:
| 필드 | 설명 |
|---|---|
| `title` | 매장명 (HTML 태그 포함 가능) |
| `address` | 지번 주소 |
| `roadAddress` | 도로명 주소 |
| `mapx`, `mapy` | 좌표 (카텍 좌표계, 1e7로 나눠야 WGS84) |
| `telephone` | 전화번호 (대부분 빈 값) |
| `link` | 외부 링크 (인스타그램 등, place ID 미포함) |

> **주의**: `link` 필드에 네이버 플레이스 ID가 포함되지 않으므로 별도 추출이 필요합니다.

---

### 3-2. 네이버 모바일 웹 검색 (Place ID + 전화번호 추출)

- **엔드포인트**: `GET https://m.search.naver.com/search.naver?query={매장명}`
- **인증**: 불필요 (User-Agent만 모바일로 설정)
- **용도**: HTML 파싱으로 네이버 플레이스 ID 및 전화번호 추출
- **메서드**: `fetchPlaceInfoFromMobileSearch(storeName)`

**추출 패턴**:
| 데이터 | 정규식 | 예시 |
|---|---|---|
| Place ID | `id[=:](\d{8,})` | `1522947861` |
| 전화번호 | `href="tel:([^"]+)"` 또는 `"phone"\s*:\s*"([^"]+)"` | `02-2617-1114` |

**반환**: `Map<String, String?>?` — `{'placeId': '...', 'phone': '...'}`

> **배경**: 기존에 사용하던 `map.naver.com/p/api/search/allSearch` API는 ncaptcha 봇 차단으로 인해 모바일 앱 환경에서 100% 차단됩니다. 이를 우회하기 위해 모바일 웹 검색 HTML 파싱 방식을 채택했습니다.

---

### 3-3. 네이버 플레이스 요약 API

- **엔드포인트**: `GET https://map.naver.com/p/api/place/summary/{placeId}`
- **인증**: 불필요 (`User-Agent` + `Referer: https://map.naver.com/` 헤더 필요)
- **용도**: 매장 상세 정보 (영업시간, 이미지, 리뷰 점수 등) 조회
- **메서드**: `fetchPlaceSummary(placeId)`

**응답 구조**: `{ "data": { "placeDetail": { ... } } }`

**`placeDetail` 주요 필드**:

| 필드 | 타입 | 내용 | 현재 활용 |
|---|---|---|---|
| `id` | `String` | 네이버 플레이스 ID | ✅ `naver_place_id` 저장 |
| `name` | `String` | 매장명 | 참조용 |
| `businessType` | `String` | `restaurant`, `cafe`, `hairshop` 등 | 미사용 |
| `category.category` | `String` | `카페`, `미용실`, `육류,고기요리` 등 | 미사용 |
| `address` | `Map` | `address`, `roadAddress`, `formattedAddress` | 미사용 |
| `coordinate` | `Map` | `latitude`, `longitude` | 미사용 |
| `businessHours.description` | `String` | `"08:00에 영업 시작"` 등 요약 텍스트 | ✅ GraphQL 실패 시 `{text}` fallback |
| (프록시) `GET /api/place/{id}/hours` | GraphQL | `newBusinessHours` 요일별 start/end | ✅ 신규 등록 시 `monday`~`sunday` 구조 저장 |
| `images.images` | `List<Map>` | `[{"origin": "https://...jpg"}, ...]` | ✅ 대표 이미지 저장 |
| `visitorReviews.score` | `double?` | 방문자 리뷰 평균 점수 (예: `4.92`) | ⬜ 미사용 (활용 가능) |
| `visitorReviews.displayText` | `String` | `"방문자 리뷰 4,072"` | ⬜ 미사용 (활용 가능) |
| `blogReviews.total` | `int` | 블로그 리뷰 수 | ⬜ 미사용 |
| `reprPrice` | `Map?` | `{"price": "25,000", "displayText": "컷 25,000원~"}` | ⬜ 미사용 (활용 가능) |
| `labels` | `Map` | 예약/배달/네이버페이 가능 여부 | ⬜ 미사용 |
| `beautyStyles.reprStyles` | `List?` | 미용실 스타일 이미지 (미용실 전용) | ⬜ 미사용 |
| `naverBookingMenu` | `Map?` | 대부분 빈 데이터 | ❌ 활용 불가 |

> **참고**: 리뷰 본문, 메뉴 상세 목록은 Summary API에서 제공하지 않으며, 별도 상세 API 엔드포인트(`/info`, `/detailed-info` 등)는 404를 반환합니다.

---

## 4. 데이터 흐름 (map_screen.dart)

```
_searchAroundCenter()
  │
  ├─ 1. Reverse Geocoding으로 동 이름 확보
  │
  ├─ 2. 카테고리별 searchStoresByKeyword() 호출
  │     → rawCandidates 리스트 구성
  │
  ├─ 3. uniqueCandidates로 중복 제거 (name|address 기준)
  │
  ├─ 4. DB 중복 체크 (naver_place_id 또는 name+address)
  │     → newStoresToRegister 필터링
  │
  └─ 5. 신규 매장별 병렬 등록:
        ├─ fetchPlaceInfoFromMobileSearch(name)
        │     → placeId, phone 추출
        ├─ fetchPlaceSummary(placeId) ∥ fetchPlaceOperatingHours(placeId)
        │     → 요일별 영업시간(우선) / Summary 텍스트 fallback, 이미지·전화 보강
        ├─ Store 엔티티 생성 → createStoreDynamically()
        └─ 대표 이미지 → addStoreImage()
```

---

## 5. 중복 방지 전략

매장 등록 전 Supabase DB에서 아래 두 기준으로 중복 검사를 수행합니다:

1. **`naver_place_id`가 존재하면** → 해당 ID로 `stores.naver_place_id` 조회
2. **없으면** → `stores.name` + `stores.address` 조합으로 조회

둘 다 일치하는 row가 없는 경우에만 신규 등록합니다.

---

## 6. 디버그 로깅

현재 개발 단계에서 각 API 호출의 성공/실패를 추적하기 위해 아래 태그의 `debugPrint` 로그가 활성화되어 있습니다:

| 태그 | 위치 | 내용 |
|---|---|---|
| `[MobileSearch]` | `naver_store_search_data_source_impl.dart` | 요청 URL, HTTP 상태, placeId/phone 추출 결과 |
| `[NaverSummary]` | `naver_store_search_data_source_impl.dart` | 요청 URL, HTTP 상태, placeDetail 키/값 |
| `[MapCrawl]` | `map_screen.dart` | 매장별 처리 시작/종료, DB 저장 시도/성공/실패 |

> 프로덕션 배포 시 해당 로그를 제거하거나 `kDebugMode` 조건으로 감싸야 합니다.

---

## 7. 알려진 제한사항

| 항목 | 설명 |
|---|---|
| **봇 차단** | `map.naver.com/p/api/search/allSearch`는 ncaptcha 봇 차단으로 사용 불가 |
| **영업시간 상세** | Summary API는 요약 텍스트만 제공 (예: `"08:00에 영업 시작"`) |
| **리뷰 본문** | 평점과 리뷰 수만 제공, 개별 리뷰 텍스트는 불가 |
| **메뉴 목록** | `naverBookingMenu`는 대부분 빈 데이터 |
| **전화번호** | Summary API에는 전화번호 미포함, 모바일 웹 검색에서만 추출 가능 |
| **모바일 웹 파싱 안정성** | 네이버 모바일 웹 구조 변경 시 정규식 패턴 업데이트 필요 |

---

## 8. 향후 확장 가능 항목

- [ ] `visitorReviews.score`를 Store의 `rating` 필드에 반영
- [ ] `reprPrice` 정보를 Store 모델에 추가
- [ ] `beautyStyles` 데이터를 살롱 전용 UI에 활용
- [ ] `blogReviews.total` + `visitorReviews.displayText`를 매장 상세 화면에 표시
- [ ] 디버그 로그를 `kDebugMode` 조건으로 래핑
