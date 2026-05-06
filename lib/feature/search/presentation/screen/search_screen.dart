import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  Map<String, List<Map<String, dynamic>>> _categorizedResults = {};
  bool _isLoading = false;

  // 카테고리 한글 이름 및 아이콘
  static const Map<String, Map<String, dynamic>> categoryInfo = {
    'restaurant': {
      'label': '🍽️ 식당',
    },
    'cafe': {
      'label': '☕ 카페',
    },
    'study_cafe': {
      'label': '📚 스터디카페',
    },
    'salon': {
      'label': '✂️ 미용실',
    },
  };

  // 결과를 카테고리별로 그룹화
  Map<String, List<Map<String, dynamic>>> _groupByCategory(
    List<Map<String, dynamic>> stores,
  ) {
    final grouped = <String, List<Map<String, dynamic>>>{};

    for (final store in stores) {
      final category = store['category'] as String? ?? 'restaurant';
      if (!grouped.containsKey(category)) {
        grouped[category] = [];
      }
      grouped[category]!.add(store);
    }

    return grouped;
  }

  Future<void> _search(String query) async {
    if (query.isEmpty) {
      setState(() {
        _categorizedResults = {};
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final supabase = Supabase.instance.client;
      // 'stores' 테이블에서 실제 존재하는 텍스트 컬럼으로 검색
      final response = await supabase
          .from('stores')
          .select()
          .or(
            'name.ilike.%$query%,address.ilike.%$query%,naver_place_id.ilike.%$query%',
          )
          .limit(50);

      final results = List<Map<String, dynamic>>.from(response);
      final grouped = _groupByCategory(results);

      if (!mounted) return;

      setState(() {
        _categorizedResults = grouped;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('검색 오류: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          decoration: const InputDecoration(
            hintText: '업장, 지역, 키워드로 검색',
            border: InputBorder.none,
          ),
          onSubmitted: _search,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _search(_controller.text),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _categorizedResults.isEmpty
          ? const Center(child: Text('검색어를 입력하세요'))
          : ListView.builder(
              itemCount: _categorizedResults.length,
              itemBuilder: (context, index) {
                final categories = _categorizedResults.keys.toList();
                final category = categories[index];
                final stores = _categorizedResults[category]!;
                final categoryLabel =
                    categoryInfo[category]?['label'] ?? category;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 카테고리 헤더
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        '$categoryLabel (${stores.length})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // 카테고리 내 가게 리스트
                    ...stores.map((store) {
                      final storeName = store['name'] ?? '이름 없음';
                      final storeAddress = store['address'] ?? '주소 없음';

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        title: Text(storeName),
                        subtitle: Text(
                          storeAddress,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () {
                          // 업장 상세로 이동 (나중에 구현)
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('$storeName 선택됨')),
                          );
                        },
                      );
                    }).toList(),
                  ],
                );
              },
            ),
    );
  }
}
