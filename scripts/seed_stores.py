import requests
import re
import time
import os
from dotenv import load_dotenv
from supabase import create_client, Client

load_dotenv(dotenv_path=os.path.join(os.path.dirname(__file__), '..', '.env'))

NAVER_CLIENT_ID = os.getenv("NAVER_CLIENT_ID")
NAVER_CLIENT_SECRET = os.getenv("NAVER_CLIENT_SECRET")
SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_SERVICE_ROLE_KEY")

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

# ===== 검색 키워드 (한성대 주변 + 인근 지역) =====
SEARCH_QUERIES = {
    "restaurant": [
        "한성대입구역 맛집",
        "삼선동 식당",
        "혜화동 맛집",
        "성북동 식당",
        "한성대 점심",
        "한성대입구 한식",
        "한성대입구 중식",
        "한성대입구 일식",
        "한성대입구 고기집",
        "한성대입구 분식",
        "삼선교 맛집",
        "동소문동 식당",
        "성신여대입구 맛집",
        "돈암동 식당",
        "길음동 맛집",
        "안암동 식당",
        "종암동 맛집",
        "혜화역 맛집",
        "낙산공원 근처 식당",
        "창경궁 맛집",
    ],
    "cafe": [
        "한성대입구역 카페",
        "삼선동 카페",
        "혜화 카페",
        "성북동 카페",
        "한성대 근처 커피",
        "동소문동 카페",
        "성신여대 카페",
        "돈암동 카페",
        "길음 카페",
        "안암 카페",
        "혜화역 카페",
        "낙산 카페",
        "한성대입구 디저트카페",
        "한성대입구 베이커리",
    ],
    "study_cafe": [
        "한성대 스터디카페",
        "성북구 스터디카페",
        "혜화 스터디카페",
        "성신여대 스터디카페",
        "돈암동 스터디카페",
        "길음 스터디카페",
        "안암 독서실",
        "성북구 독서실",
        "한성대입구 코인독서실",
    ],
    "salon": [
        "한성대입구역 미용실",
        "삼선동 미용실",
        "혜화 미용실",
        "성북구 헤어샵",
        "동소문동 헤어",
        "성신여대 미용실",
        "돈암동 헤어샵",
        "길음 미용실",
        "안암동 헤어",
        "한성대 네일샵",
        "혜화 네일아트",
    ],
}


def search_naver(query, display=5, start=1):
    url = "https://openapi.naver.com/v1/search/local.json"
    headers = {
        "X-Naver-Client-Id": NAVER_CLIENT_ID,
        "X-Naver-Client-Secret": NAVER_CLIENT_SECRET,
    }
    params = {"query": query, "display": display, "start": start}
    res = requests.get(url, headers=headers, params=params)
    return res.json().get("items", [])


def clean_html(text):
    return re.sub(r"<[^>]+>", "", text)


def extract_place_id(link):
    match = re.search(r"place/(\d+)", link)
    return match.group(1) if match else None


def convert_coords(mapx, mapy):
    return float(mapy) / 1e7, float(mapx) / 1e7  # lat, lng


# ===== Supabase에 이미 있는 데이터 미리 로드 =====
print("기존 데이터 확인 중...")
existing = supabase.table("stores").select("name, naver_place_id").execute().data
existing_place_ids = {row["naver_place_id"] for row in existing if row.get("naver_place_id")}
existing_names = {row["name"] for row in existing if row.get("name")}
print(f"  기존 가게 수: {len(existing_names)}개")

seen_this_run = set()
success_count = 0
skip_count = 0

for category, queries in SEARCH_QUERIES.items():
    print(f"\n[{category}] 수집 시작...")
    for query in queries:
        for start in range(1, 46, 5):  # 쿼리당 최대 45개 (start 1,6,11,...,41)
            items = search_naver(query, display=5, start=start)
            if not items:
                break

            for item in items:
                name = clean_html(item.get("title", ""))
                place_id = extract_place_id(item.get("link", ""))

                # 이미 DB에 있거나 이번 실행에서 처리한 경우 스킵
                if place_id and place_id in existing_place_ids:
                    skip_count += 1
                    continue
                if name in existing_names or name in seen_this_run:
                    skip_count += 1
                    continue

                seen_this_run.add(name)

                address = item.get("roadAddress") or item.get("address", "")
                lat, lng = convert_coords(
                    item.get("mapx", "0"), item.get("mapy", "0")
                )
                contact = item.get("telephone") or None

                try:
                    supabase.table("stores").insert({
                        "name": name,
                        "category": category,
                        "address": address,
                        "latitude": lat,
                        "longitude": lng,
                        "naver_place_id": place_id,
                        "contact": contact,
                    }).execute()

                    existing_names.add(name)
                    if place_id:
                        existing_place_ids.add(place_id)

                    print(f"  추가: {name} ({address})")
                    success_count += 1
                except Exception as e:
                    print(f"  실패: {name} - {e}")

            time.sleep(0.3)

print(f"\n완료! 신규 추가: {success_count}개 / 중복 스킵: {skip_count}개")
print(f"현재 총 가게 수: {len(existing_names)}개")
