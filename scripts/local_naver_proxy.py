import re
import json
import httpx
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(title="Naver Place Local Proxy API")

# Flutter 앱이 웹이나 시뮬레이터에서 연동되도록 CORS 허용
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

COMMON_HEADERS = {
    "User-Agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1",
    "Accept": "*/*",
    "Accept-Language": "ko-KR,ko;q=0.9,en-US;q=0.8,en;q=0.7",
}

@app.get("/api/place/{place_id}/menu")
async def get_menu(place_id: str):
    """
    네이버 모바일 플레이스 메뉴 리스트를 긁어서 파싱 후 JSON으로 반환합니다.
    """
    url = f"https://m.place.naver.com/restaurant/{place_id}/menu/list"
    
    headers = {
        **COMMON_HEADERS,
        "Referer": f"https://m.place.naver.com/restaurant/{place_id}/home"
    }
    
    async with httpx.AsyncClient(http2=True) as client:
        try:
            res = await client.get(url, headers=headers)
            if res.status_code != 200:
                raise HTTPException(status_code=res.status_code, detail="Failed to fetch menu page from Naver")
            
            html = res.text
            match = re.search(r'window\.__APOLLO_STATE__\s*=\s*(\{.*?\});', html, re.DOTALL)
            if not match:
                # 404 혹은 상세 메뉴 데이터가 아예 없는 경우
                return {"menus": []}
            
            apollo_json = json.loads(match.group(1))
            menus = []
            
            for key, val in apollo_json.items():
                if isinstance(val, dict) and val.get("__typename") == "Menu":
                    images = val.get("images")
                    img_url = ""
                    if images and isinstance(images, list) and len(images) > 0:
                        img_url = images[0]
                    else:
                        img_url = val.get("imageUrl") or ""

                    menus.append({
                        "id": key,
                        "name": val.get("name"),
                        "price": val.get("price"),
                        "description": val.get("desc") or val.get("description") or "",
                        "imageUrl": img_url
                    })
                    
            return {"menus": menus}
            
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Scraping error: {str(e)}")

@app.get("/api/place/{place_id}/review")
async def get_review(place_id: str, page: int = 1, size: int = 15, after: str = None, business_type: str = "restaurant"):
    """
    네이버 플레이스 내부 GraphQL API를 연동하여 방문자 리뷰 데이터를 긁어와 반환합니다.
    """
    url = "https://pcmap-api.place.naver.com/place/graphql"
    
    headers = {
        **COMMON_HEADERS,
        "Content-Type": "application/json",
        "Origin": "https://m.place.naver.com",
        "Referer": f"https://m.place.naver.com/restaurant/{place_id}/review/visitor"
    }
    
    payload = [
        {
            "operationName": "getVisitorReviews",
            "variables": {
                "input": {
                    "bookingBusinessId": None,
                    "businessId": place_id,
                    "businessType": business_type,
                    "size": size,
                    "getAuthorInfo": True,
                    "includeContent": True,
                    "includeReceiptPhotos": True,
                    "isPhotoUsed": False,
                    "item": "0",
                    "page": page,
                    "sort": "recent",
                    "after": after
                }
            },
            "query": """
            query getVisitorReviews($input: VisitorReviewsInput) {
              visitorReviews(input: $input) {
                items {
                  id
                  cursor
                  rating
                  body
                  created
                  author {
                    id
                    nickname
                    imageUrl
                  }
                  media {
                    type
                    thumbnail
                  }
                }
                total
              }
            }
            """
        }
    ]
    
    async with httpx.AsyncClient(http2=True) as client:
        try:
            print(f"[DEBUG] Requesting Naver GraphQL for page: {page}, display(size): {size}")
            print(f"[DEBUG] Variables sent: {payload[0]['variables']}")
            res = await client.post(url, json=payload, headers=headers)
            print(f"[DEBUG] Naver Response Status: {res.status_code}")
            if res.status_code != 200:
                raise HTTPException(status_code=res.status_code, detail="Failed to fetch reviews from Naver GraphQL")
            
            data = res.json()
            if not data or "errors" in data[0]:
                errors = data[0].get("errors") if data else "Unknown GraphQL error"
                print(f"[DEBUG] GraphQL Errors inside response: {errors}")
                raise HTTPException(status_code=400, detail=f"GraphQL Error: {errors}")
            
            visitor_reviews_data = data[0]['data']['visitorReviews']
            items = visitor_reviews_data.get('items', [])
            total = visitor_reviews_data.get('total', 0)
            
            reviews = []
            for item in items:
                author_info = item.get("author", {})
                media_info = []
                if item.get("media"):
                    for m in item.get("media", []):
                        if m:
                            media_info.append({
                                "type": m.get("type"),
                                "thumbnail": m.get("thumbnail")
                            })
                reviews.append({
                  "id": item.get("id"),
                  "cursor": item.get("cursor"),
                  "rating": item.get("rating"),
                  "body": item.get("body", ""),
                  "created": item.get("created", ""),
                  "author": {
                      "id": author_info.get("id"),
                      "nickname": author_info.get("nickname") or "익명",
                      "imageUrl": author_info.get("imageUrl") or ""
                  },
                  "media": media_info
                })
                
            return {
                "total": total,
                "page": page,
                "size": len(reviews),
                "reviews": reviews
            }
            
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"GraphQL proxy request error: {str(e)}")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("local_naver_proxy:app", host="0.0.0.0", port=8000, reload=True)
