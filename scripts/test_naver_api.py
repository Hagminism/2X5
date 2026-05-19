import re

def test():
    with open('scripts/search_response.html', 'r', encoding='utf-8') as f:
        html = f.read()
        
    # Match mobile place urls
    place_urls = re.findall(r'https://m\.place\.naver\.com/(?:place|restaurant|accommodation|hairshop)/(\d+)', html)
    print("Found place URLs count:", len(place_urls))
    print("Distinct IDs found:", set(place_urls))
    
    # Let's inspect context of one found ID
    if place_urls:
        target_id = place_urls[0]
        idx = html.find(target_id)
        start = max(0, idx - 200)
        end = min(len(html), idx + 500)
        print(f"\nContext around {target_id}:")
        print(html[start:end].replace('\n', ' '))

if __name__ == '__main__':
    test()
