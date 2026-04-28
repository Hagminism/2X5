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

# ===== 한성대 주변 검색 키워드 =====
SEARCH_QUERIES = {
    "restaurant": [
        "한성대입구역 맛집",
        "삼선동 식당",
        "혜화동 맛집",
        "성북동 식당",
        "한성대 점심",
    ],
    "cafe": [
        "한성대입구역 카페",
        "삼선동 카페",
        "혜화 카페",
        "성북동 카페",
    ],
    "study_cafe": [
        "한성대 스터디카페",
        "성북구 스터디카페",
        "혜화 스터디카페",
    ],
    "salon": [
        "한성대입구역 미용실",
        "삼선동 미용실",
        "혜화 미용실",
        "성북구 헤어샵",
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
    # 네이버 API 좌표 → WGS84 변환 (1e7로 나눔)
    return float(mapy) / 1e7, float(mapx) / 1e7  # lat, lng


seen_names = set()
success_count = 0

for category, queries in SEARCH_QUERIES.items():
    print(f"\n[{category}] 수집 시작...")
    for query in queries:
        for start in range(1, 26, 5):  # 쿼리당 최대 25개
            items = search_naver(query, display=5, start=start)
            if not items:
                break

            for item in items:
                name = clean_html(item.get("title", ""))
                address = item.get("roadAddress") or item.get("address", "")
                lat, lng = convert_coords(
                    item.get("mapx", "0"), item.get("mapy", "0")
                )
                place_id = extract_place_id(item.get("link", ""))
                contact = item.get("telephone") or None

                if name in seen_names:
                    continue
                seen_names.add(name)

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
                    print(f"  추가: {name}")
                    success_count += 1
                except Exception as e:
                    print(f"  실패: {name} - {e}")

            time.sleep(0.2)

print(f"\n총 {success_count}개 가게 추가 완료!")
