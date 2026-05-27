import 'dart:async';
import 'dart:math' as math;

import 'package:capstone_2026/core/domain/model/store/store.dart';
import 'package:capstone_2026/core/domain/util/map_naver_place_operating_hours.dart';
import 'package:capstone_2026/core/domain/util/map_search_area.dart';
import 'package:capstone_2026/core/domain/repository/store/store_repository.dart';
import 'package:capstone_2026/core/routing/routes.dart';
import 'package:capstone_2026/di/di_setup.dart';
import 'package:capstone_2026/feature/store_detail/data/data_source/kakao_store_search_data_source.dart';
import 'package:capstone_2026/feature/store_detail/data/data_source/naver_store_search_data_source.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:naver_maps_sdk_flutter/enum/naver_map_map_type_id.dart';
import 'package:naver_maps_sdk_flutter/event/map_event.dart';
import 'package:naver_maps_sdk_flutter/event/map_load_status_event.dart';
import 'package:naver_maps_sdk_flutter/event/marker_event.dart';
import 'package:naver_maps_sdk_flutter/model/html_icon.dart';
import 'package:naver_maps_sdk_flutter/model/map_options.dart';
import 'package:naver_maps_sdk_flutter/model/marker_options.dart';
import 'package:naver_maps_sdk_flutter/model/n_lat_lng.dart';
import 'package:naver_maps_sdk_flutter/sdk_app/naver_maps_sdk_flutter_app.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late final NaverMapManager _naverMapManager;
  late final StreamSubscription<MapLoadStatus> _mapStatusSubscription;
  StreamSubscription<MarkerEvent>? _markerEventSubscription;
  StreamSubscription<MapEvent>? _mapEventSubscription;

  static const _fixedCenter = NLatLng(37.5826, 127.0106);
  static const _searchCooldownDuration = Duration(seconds: 3);
  static const _overlapDbOnlyThreshold = 0.9;
  static const _storePreviewSheetHeight = 148.0;
  static const _searchButtonGapAboveSheet = 12.0;
  static const _searchAreaButtonHeight = 40.0;
  // 검색 배치 속도 조절(높으면 로드 빠르나, 403 확률 올라감)
  static const _storeRegisterBatchSize = 12;

  NLatLng _currentCenter = _fixedCenter;
  NLatLng? _myLocationLatLng;
  bool _isSearching = false;
  MapAreaBounds? _lastCrawledBounds;
  /// 직전 API 검색에서 신규 0건이었던 bbox. 겹침 ≥90%이면 카카오 생략.
  MapAreaBounds? _lastZeroNewSearchBounds;
  Timer? _searchCooldownTimer;
  bool _isSearchCooldownActive = false;
  int _currentZoom = 15;
  bool _mapReady = false;
  List<Map<String, dynamic>> _stores = [];
  String? _selectedCategory;
  Map<String, dynamic>? _selectedStore;
  String? _selectedStoreCoverImage;
  String? _selectedMarkerId;
  DateTime? _lastMarkerClickTime;
  final Set<String> _registeredMarkerIds = {};
  final Map<String, NLatLng> _clusterPositions = {};

  @override
  void initState() {
    super.initState();
    _naverMapManager = NaverMapManager.createNaverMapManager();
    _mapStatusSubscription = _naverMapManager.onMapLoadStatus.listen((status) {
      if (status is MapLoadSuccess) {
        _naverMapManager.addMapCenterChangedEventListener();
        _naverMapManager.addMapClickEventListener();
        _naverMapManager.addMapZoomChangedEventListener();
        _naverMapManager.addMapZoomEndEventListener();
        _mapReady = true;
        _setupInitialLocation();
      }
    });
    _markerEventSubscription = _naverMapManager.onMarkerEvent.listen((event) {
      if (event is MarkerClick) {
        final markerId = event.markerId;
        _lastMarkerClickTime = DateTime.now();

        // 클러스터 클릭 → 줌인
        if (markerId.startsWith('cluster_')) {
          final pos = _clusterPositions[markerId];
          if (pos != null && mounted) {
            _currentZoom = (_currentZoom + 3).clamp(1, 21);
            _naverMapManager.setZoom(zoom: _currentZoom);
            _naverMapManager.setCenter(center: pos);
            // 프로그래밍 줌은 MapZoomEnd 이벤트를 발생시키지 않으므로 직접 호출
            unawaited(_addStoreMarkers());
          }
          return;
        }

        // 개별 마커 클릭
        final storeId = markerId.replaceFirst('store_', '');
        final matches = _stores.where((s) => s['id'].toString() == storeId);
        if (matches.isNotEmpty && mounted) {
          final prev = _selectedMarkerId;
          setState(() {
            _selectedStore = matches.first;
            _selectedStoreCoverImage = null;
            _selectedMarkerId = markerId;
          });
          _fetchCoverImage(storeId);
          if (prev != null && prev != markerId && prev.startsWith('store_')) {
            _updateMarkerAppearance(prev, isSelected: false);
          }
          _updateMarkerAppearance(markerId, isSelected: true);
        }
      }
    });
    _mapEventSubscription = _naverMapManager.onMapEvent.listen((event) {
      if (event is MapClick && mounted) {
        final last = _lastMarkerClickTime;
        if (last != null &&
            DateTime.now().difference(last) <
                const Duration(milliseconds: 600)) {
          return;
        }
        final prev = _selectedMarkerId;
        setState(() {
          _selectedStore = null;
          _selectedMarkerId = null;
        });
        if (prev != null && prev.startsWith('store_')) {
          _updateMarkerAppearance(prev, isSelected: false);
        }
      } else if (event is MapZoomChanged) {
        _currentZoom = event.zoom;
      } else if (event is MapZoomEnd && mounted && _mapReady) {
        _addStoreMarkers();
      } else if (event is MapCenterChanged) {
        _currentCenter = event.latLng;
      }
    });
  }

  Future<void> _fetchCoverImage(String storeId) async {
    try {
      final response = await Supabase.instance.client
          .from('store_images')
          .select('image_url')
          .eq('store_id', storeId)
          .eq('is_cover', true)
          .limit(1);
      if (!mounted) return;
      final url = (response as List).isNotEmpty
          ? response.first['image_url'] as String?
          : null;
      setState(() => _selectedStoreCoverImage = url);
    } catch (_) {}
  }

  Future<List<Map<String, dynamic>>> _queryStoresInArea(NLatLng center) async {
    final bounds = mapAreaBoundsFromCenter(
      lat: center.lat,
      lng: center.lng,
    );
    final response = await Supabase.instance.client
        .from('stores')
        .select('id, name, category, latitude, longitude, address, naver_place_id')
        .gte('latitude', bounds.minLat)
        .lte('latitude', bounds.maxLat)
        .gte('longitude', bounds.minLng)
        .lte('longitude', bounds.maxLng);
    return List<Map<String, dynamic>>.from(response);
  }

  bool _storeListsEquivalent(
    List<Map<String, dynamic>> previous,
    List<Map<String, dynamic>> next,
  ) {
    if (previous.length != next.length) {
      return false;
    }
    final previousIds = previous
        .map((store) => store['id']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toSet();
    final nextIds = next
        .map((store) => store['id']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toSet();
    return previousIds.length == nextIds.length &&
        previousIds.containsAll(nextIds);
  }

  Future<void> _fetchStores(
    NLatLng center, {
    bool skipMarkerRefreshIfUnchanged = false,
  }) async {
    try {
      final stores = await _queryStoresInArea(center);
      if (!mounted) return;
      final storesUnchanged = _storeListsEquivalent(_stores, stores);
      setState(() => _stores = stores);
      if (!_mapReady) return;
      if (skipMarkerRefreshIfUnchanged && storesUnchanged) {
        debugPrint('[MapSearch] Marker refresh skip — stores unchanged');
        return;
      }
      await _addStoreMarkers();
    } catch (e) {
      debugPrint('stores fetch error: $e');
    }
  }

  bool _shouldSkipKakaoForZeroNewRegion(MapAreaBounds newBounds) {
    final lastZeroNew = _lastZeroNewSearchBounds;
    if (lastZeroNew == null) {
      return false;
    }
    final ratio = mapAreaOverlapRatioAgainstNew(
      newBounds: newBounds,
      previousBounds: lastZeroNew,
    );
    return ratio >= _overlapDbOnlyThreshold;
  }

  void _rememberZeroNewSearchBounds(MapAreaBounds newBounds) {
    _lastZeroNewSearchBounds = _lastZeroNewSearchBounds == null
        ? newBounds
        : mapAreaBoundsUnion(_lastZeroNewSearchBounds!, newBounds);
  }

  Set<String> _existingStoreLookupKeys(List<Map<String, dynamic>> areaStores) {
    final keys = <String>{};
    for (final store in areaStores) {
      final name = store['name']?.toString() ?? '';
      final address = store['address']?.toString() ?? '';
      if (name.isNotEmpty && address.isNotEmpty) {
        keys.add('$name|$address');
      }
      final placeId = store['naver_place_id']?.toString() ?? '';
      if (placeId.isNotEmpty) {
        keys.add('place:$placeId');
      }
    }
    return keys;
  }

  bool _isStoreAlreadyRegistered(
    Map<String, dynamic> candidate,
    Set<String> lookupKeys,
  ) {
    final name = candidate['name'] as String? ?? '';
    final address = candidate['address'] as String? ?? '';
    if (name.isNotEmpty &&
        address.isNotEmpty &&
        lookupKeys.contains('$name|$address')) {
      return true;
    }
    final fallbackPlaceId = candidate['fallbackPlaceId'] as String? ?? '';
    if (fallbackPlaceId.isNotEmpty &&
        lookupKeys.contains('place:$fallbackPlaceId')) {
      return true;
    }
    return false;
  }

  String _storeDedupeKey(String name, String address) => '$name|$address';

  String _mapCategoryToNaverBusinessType(String category) {
    switch (category) {
      case 'cafe':
      case 'study_cafe':
        return 'cafe';
      case 'salon':
        return 'hairshop';
      default:
        return 'restaurant';
    }
  }

  void _beginSearchCooldownUi() {
    _searchCooldownTimer?.cancel();
    if (!mounted) return;
    setState(() => _isSearchCooldownActive = true);

    _searchCooldownTimer = Timer(_searchCooldownDuration, () {
      if (!mounted) return;
      setState(() {
        _isSearchCooldownActive = false;
        _searchCooldownTimer = null;
      });
    });
  }

  void _requestSearchAroundCenter() {
    if (_isSearching) {
      return;
    }
    if (_isSearchCooldownActive) {
      debugPrint('[MapSearch] cooldown active');
      return;
    }
    _beginSearchCooldownUi();
    unawaited(_searchAroundCenter());
  }

  Future<List<Map<String, dynamic>>> _searchKakaoByCategories({
    required NLatLng center,
    required List<String> categories,
    required KakaoStoreSearchDataSource kakaoSource,
  }) async {
    final futures = categories.map((cat) async {
      final queryKeyword = _categorySearchKeyword(cat);
      if (queryKeyword.isEmpty) {
        return <Map<String, dynamic>>[];
      }
      try {
        final kakaoItems = await kakaoSource.searchStoresByCoordinates(
          keyword: queryKeyword,
          lat: center.lat,
          lng: center.lng,
          radius: 1000,
        );
        return kakaoItems
            .map(
              (item) => {
                'item': item,
                'category': cat,
              },
            )
            .toList();
      } catch (e) {
        debugPrint('Error searching category $cat: $e');
        return <Map<String, dynamic>>[];
      }
    });
    final batches = await Future.wait(futures);
    return batches.expand((batch) => batch).toList();
  }

  Map<String, Map<String, dynamic>> _uniqueCandidatesFromKakao(
    List<Map<String, dynamic>> rawCandidates,
  ) {
    final uniqueCandidates = <String, Map<String, dynamic>>{};
    for (final entry in rawCandidates) {
      final item = entry['item'] as Map<String, dynamic>;
      final category = entry['category'] as String;

      final String name = (item['place_name'] as String? ?? '')
          .replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), '');
      final String address = item['address_name'] as String? ?? '';
      final String roadAddress = item['road_address_name'] as String? ?? '';
      final String targetCheckAddress =
          roadAddress.isNotEmpty ? roadAddress : address;

      final xStr = item['x']?.toString() ?? '';
      final yStr = item['y']?.toString() ?? '';

      double? lat;
      double? lng;

      if (xStr.isNotEmpty && yStr.isNotEmpty) {
        lng = double.tryParse(xStr);
        lat = double.tryParse(yStr);
      }

      if (lat == null || lng == null || lat == 0.0 || lng == 0.0) {
        continue;
      }

      final key = _storeDedupeKey(name, targetCheckAddress);
      if (!uniqueCandidates.containsKey(key)) {
        uniqueCandidates[key] = {
          'name': name,
          'address': targetCheckAddress,
          'category': category,
          'latitude': lat,
          'longitude': lng,
          'fallbackPlaceId': '',
          'telephone': item['phone'] as String? ?? '',
        };
      }
    }
    return uniqueCandidates;
  }

  Future<void> _registerSingleStore({
    required Map<String, dynamic> cand,
    required StoreRepository storeRepo,
    required NaverStoreSearchDataSource naverSource,
  }) async {
    final String name = cand['name'] as String;
    final String address = cand['address'] as String;
    final String category = cand['category'] as String;
    final double lat = cand['latitude'] as double;
    final double lng = cand['longitude'] as double;
    final String telephone = cand['telephone'] as String;
    final String fallbackPlaceId = cand['fallbackPlaceId'] as String;

    String finalPlaceId = fallbackPlaceId;
    String? finalThumUrl;
    final List<String> finalImageUrls = [];
    String finalContact = telephone;
    Map<String, dynamic> operatingHours = {};
    double finalRating = 0.0;

    debugPrint('[MapCrawl] === 매장 처리 시작: $name ($address) ===');

    try {
      String? placeId =
          fallbackPlaceId.isNotEmpty ? fallbackPlaceId : null;
      if (placeId == null) {
        final mobileInfo = await naverSource.fetchPlaceInfoFromMobileSearch(
          storeName: name,
        );
        placeId = mobileInfo?['placeId'];
        final mobilePhone = mobileInfo?['phone'];
        if (mobilePhone != null && mobilePhone.isNotEmpty) {
          finalContact = mobilePhone;
        }
        debugPrint(
          '[MapCrawl] 모바일 검색 - placeId: $placeId, phone: $mobilePhone',
        );
      }

      if (placeId == null || placeId.isEmpty) {
        debugPrint('[MapCrawl] placeId 없음 — 저장 skip: $name');
        return;
      }

      finalPlaceId = placeId;
      final preliminaryBusinessType = _mapCategoryToNaverBusinessType(category);

      final summaryFuture = naverSource.fetchPlaceSummary(placeId: placeId);
      final hoursFuture = naverSource.fetchPlaceOperatingHours(
        placeId: placeId,
        businessType: preliminaryBusinessType,
      );

      final summary = await summaryFuture;
      var hoursPayload = await hoursFuture;

      final businessTypeRaw = summary?['businessType'];
      final businessType = businessTypeRaw is String &&
              businessTypeRaw.trim().isNotEmpty
          ? businessTypeRaw.trim()
          : preliminaryBusinessType;

      if (businessType != preliminaryBusinessType) {
        hoursPayload = await naverSource.fetchPlaceOperatingHours(
          placeId: placeId,
          businessType: businessType,
        );
      }

      final structuredHours = mapNaverWeeklyHoursToStoreOperatingHours(
        hoursPayload,
      );
      if (structuredHours != null && structuredHours.isNotEmpty) {
        operatingHours = structuredHours;
      }

      if (operatingHours.isEmpty) {
        debugPrint('[MapCrawl] 영업시간 없음 — 저장 skip: $name');
        return;
      }

      if (summary != null) {
        final summaryPhone = summary['phone'] as String?;
        if (summaryPhone != null && summaryPhone.isNotEmpty) {
          finalContact = summaryPhone;
        } else {
          final buttons = summary['buttons'] as Map<String, dynamic>?;
          final btnPhone = buttons?['phone'] as String?;
          if (btnPhone != null && btnPhone.isNotEmpty) {
            finalContact = btnPhone;
          }
        }

        final imagesObj = summary['images'] as Map<String, dynamic>?;
        final imagesList = imagesObj?['images'] as List?;
        if (imagesList != null && imagesList.isNotEmpty) {
          for (final img in imagesList) {
            final imgMap = img as Map<String, dynamic>?;
            final imgUrl =
                imgMap?['origin'] as String? ?? imgMap?['url'] as String?;
            if (imgUrl != null && imgUrl.isNotEmpty) {
              finalImageUrls.add(imgUrl);
            }
          }
          if (finalImageUrls.isNotEmpty) {
            finalThumUrl = finalImageUrls.first;
          }
        }

        final visitorReviews =
            summary['visitorReviews'] as Map<String, dynamic>?;
        if (visitorReviews != null) {
          final scoreRaw = visitorReviews['score'];
          if (scoreRaw is num) {
            finalRating = scoreRaw.toDouble();
          } else if (scoreRaw is String) {
            finalRating = double.tryParse(scoreRaw) ?? 0.0;
          }
        }
      }
    } catch (crawlErr) {
      debugPrint('[MapCrawl] 크롤링 실패 for $name: $crawlErr');
      return;
    }

    final store = Store(
      id: '',
      ownerId: '',
      name: name,
      category: category,
      businessNumber: '',
      latitude: lat,
      longitude: lng,
      address: address,
      contact: finalContact,
      naverPlaceId: finalPlaceId,
      operatingHours: operatingHours,
      rating: finalRating,
    );

    try {
      final createdStore = await storeRepo.createStoreDynamically(store);
      debugPrint('[MapCrawl] DB 저장 성공 - storeId=${createdStore.id}');
      if (finalImageUrls.isNotEmpty) {
        for (int i = 0; i < finalImageUrls.length; i++) {
          await storeRepo.addStoreImage(
            createdStore.id,
            finalImageUrls[i],
            isCover: i == 0,
          );
        }
      } else if (finalThumUrl != null && finalThumUrl.isNotEmpty) {
        await storeRepo.addStoreImage(
          createdStore.id,
          finalThumUrl,
          isCover: true,
        );
      }
    } catch (dbErr) {
      debugPrint('[MapCrawl] DB 저장 실패 for $name: $dbErr');
    }
  }

  Future<void> _registerNewStoresInBatches({
    required List<Map<String, dynamic>> newStores,
    required StoreRepository storeRepo,
    required NaverStoreSearchDataSource naverSource,
  }) async {
    for (var i = 0; i < newStores.length; i += _storeRegisterBatchSize) {
      final end = math.min(i + _storeRegisterBatchSize, newStores.length);
      final batch = newStores.sublist(i, end);
      await Future.wait(
        batch.map(
          (cand) => _registerSingleStore(
            cand: cand,
            storeRepo: storeRepo,
            naverSource: naverSource,
          ),
        ),
      );
    }
  }

  Future<void> _runExternalSearchPipeline({
    required NLatLng center,
    required MapAreaBounds newBounds,
  }) async {
    final categoriesToSearch = _selectedCategory != null
        ? [_selectedCategory!]
        : ['restaurant', 'cafe', 'study_cafe', 'salon'];

    final storeRepo = getIt<StoreRepository>();
    final kakaoSource = getIt<KakaoStoreSearchDataSource>();
    final naverSource = getIt<NaverStoreSearchDataSource>();

    final areaStores = await _queryStoresInArea(center);
    final lookupKeys = _existingStoreLookupKeys(areaStores);

    final skipKakao = _shouldSkipKakaoForZeroNewRegion(newBounds);
    var candidateCount = 0;
    final List<Map<String, dynamic>> newStoresToRegister;

    if (skipKakao) {
      newStoresToRegister = [];
      debugPrint(
        '[MapSearch] Kakao skip — prior search had 0 new in overlapping area',
      );
    } else {
      final rawCandidates = await _searchKakaoByCategories(
        center: center,
        categories: categoriesToSearch,
        kakaoSource: kakaoSource,
      );
      final uniqueCandidates = _uniqueCandidatesFromKakao(rawCandidates);
      candidateCount = uniqueCandidates.length;
      newStoresToRegister = uniqueCandidates.values
          .where((cand) => !_isStoreAlreadyRegistered(cand, lookupKeys))
          .toList();
    }

    debugPrint(
      '[MapSearch] API path — candidates=$candidateCount, '
      'new=${newStoresToRegister.length}',
    );

    if (newStoresToRegister.isNotEmpty) {
      _lastZeroNewSearchBounds = null;
      await _registerNewStoresInBatches(
        newStores: newStoresToRegister,
        storeRepo: storeRepo,
        naverSource: naverSource,
      );
    } else {
      _rememberZeroNewSearchBounds(newBounds);
    }

    _lastCrawledBounds = _lastCrawledBounds == null
        ? newBounds
        : mapAreaBoundsUnion(_lastCrawledBounds!, newBounds);
  }

  List<Map<String, dynamic>> get _filteredStores {
    if (_selectedCategory == null) return _stores;
    return _stores.where((s) => s['category'] == _selectedCategory).toList();
  }

  String _categoryColor(String category) {
    switch (category) {
      case 'restaurant':
        return '#E53935';
      case 'cafe':
        return '#6D4C41';
      case 'study_cafe':
        return '#1E88E5';
      case 'salon':
        return '#8E24AA';
      default:
        return '#43A047';
    }
  }

  String _categoryEmoji(String category) {
    switch (category) {
      case 'restaurant':
        return '🍽';
      case 'cafe':
        return '☕';
      case 'study_cafe':
        return '📚';
      case 'salon':
        return '✂';
      default:
        return '📍';
    }
  }

  String _categoryLabel(String category) {
    switch (category) {
      case 'restaurant':
        return '식당';
      case 'cafe':
        return '카페';
      case 'study_cafe':
        return '스터디카페';
      case 'salon':
        return '미용실';
      default:
        return category;
    }
  }

  double _gridSizeForZoom(int zoom) {
    // zoom 15 → ~0.004deg(≈440m), 줌 1 내려갈수록 2배
    return 0.004 * math.pow(2, 15 - zoom);
  }

  Map<String, List<Map<String, dynamic>>> _clusterStores(
    List<Map<String, dynamic>> stores,
    int zoom,
  ) {
    if (zoom >= 17) {
      final clusters = <String, List<Map<String, dynamic>>>{};
      for (final store in stores) {
        final id = store['id']?.toString() ?? '';
        clusters[id] = [store];
      }
      return clusters;
    }
    final gridSize = _gridSizeForZoom(zoom);
    final clusters = <String, List<Map<String, dynamic>>>{};
    for (final store in stores) {
      final lat = store['latitude'] as double?;
      final lng = store['longitude'] as double?;
      final category = store['category'] as String? ?? 'unknown';
      if (lat == null || lng == null) continue;
      final gridLat = (lat / gridSize).floor();
      final gridLng = (lng / gridSize).floor();
      final key = '${category}_${gridLat}_$gridLng';
      clusters.putIfAbsent(key, () => []).add(store);
    }
    return clusters;
  }

  String _dominantCategory(List<Map<String, dynamic>> stores) {
    final counts = <String, int>{};
    for (final s in stores) {
      final cat = s['category'] as String? ?? '';
      counts[cat] = (counts[cat] ?? 0) + 1;
    }
    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  String _buildClusterHtml(int count, String category) {
    final color = _categoryColor(category);
    final emoji = _categoryEmoji(category);
    final size = count > 99 ? 56 : count > 9 ? 50 : 44;
    final countFontSize = count > 99 ? 11 : count > 9 ? 12 : 13;
    return '<div style="background:$color;color:white;border-radius:50%;'
        'width:${size}px;height:${size}px;display:flex;flex-direction:column;'
        'align-items:center;justify-content:center;gap:1px;'
        'border:2.5px solid white;'
        'box-shadow:0 2px 8px rgba(0,0,0,0.35);">'
        '<span style="font-size:16px;line-height:1;font-variant-emoji:text;">$emoji</span>'
        '<span style="font-size:${countFontSize}px;font-weight:700;line-height:1.2;">$count</span>'
        '</div>';
  }

  String _buildMarkerHtml(String category, {bool isSelected = false}) {
    final color = _categoryColor(category);
    final emoji = _categoryEmoji(category);
    final size = isSelected ? 44 : 32;
    final fontSize = isSelected ? 22 : 16;
    final border = isSelected ? 'border:2.5px solid white;' : '';
    final shadow = isSelected
        ? 'box-shadow:0 0 0 3px ${color}80,0 3px 8px rgba(0,0,0,0.4);'
        : 'box-shadow:0 2px 4px rgba(0,0,0,0.3);';
    return '<div style="background:$color;color:white;border-radius:50%;'
        'width:${size}px;height:${size}px;display:flex;align-items:center;'
        'justify-content:center;font-size:${fontSize}px;$border$shadow'
        'transition:all 0.15s;">'
        '<span style="font-variant-emoji:text;">$emoji</span></div>';
  }

  Future<void> _updateMarkerAppearance(
    String markerId, {
    required bool isSelected,
  }) async {
    final storeId = markerId.replaceFirst('store_', '');
    final matches = _stores.where((s) => s['id'].toString() == storeId);
    if (matches.isEmpty) return;
    final store = matches.first;
    final lat = store['latitude'] as double?;
    final lng = store['longitude'] as double?;
    final category = store['category'] as String? ?? '';
    if (lat == null || lng == null) return;
    await _naverMapManager.updateMarker(
      markerId: markerId,
      markerOptions: MarkerOptions(
        position: NLatLng(lat, lng),
        icon: HtmlIcon(
          content: _buildMarkerHtml(category, isSelected: isSelected),
        ),
      ),
    );
  }

  Future<void> _addStoreMarkers() async {
    // SDK 버그: removeMarkerAll()이 markerEventListeners를 초기화하지 않아서
    // addMarkerClickEvent()가 "이미 등록됨"으로 보고 skip함 → 먼저 개별 해제
    for (final id in _registeredMarkerIds) {
      await _naverMapManager.removeMarkerClickEvent(markerId: id);
    }
    _registeredMarkerIds.clear();
    _selectedMarkerId = null;
    _clusterPositions.clear();

    await _naverMapManager.removeMarkerAll();
    await _addMyLocationMarker();

    final clusters = _clusterStores(_filteredStores, _currentZoom);

    for (final entry in clusters.entries) {
      final stores = entry.value;
      if (stores.length == 1) {
        // 개별 마커
        final store = stores.first;
        final lat = store['latitude'] as double?;
        final lng = store['longitude'] as double?;
        final category = store['category'] as String? ?? '';
        final id = store['id']?.toString() ?? '';
        if (lat == null || lng == null) continue;

        await _naverMapManager.addMarker(
          markerId: 'store_$id',
          markerOptions: MarkerOptions(
            position: NLatLng(lat, lng),
            icon: HtmlIcon(content: _buildMarkerHtml(category)),
          ),
        );
        await _naverMapManager.addMarkerClickEvent(markerId: 'store_$id');
        _registeredMarkerIds.add('store_$id');
      } else {
        // 클러스터 마커 — 중심점 계산
        final lat = stores
                .map((s) => s['latitude'] as double)
                .reduce((a, b) => a + b) /
            stores.length;
        final lng = stores
                .map((s) => s['longitude'] as double)
                .reduce((a, b) => a + b) /
            stores.length;
        final category = _dominantCategory(stores);
        final markerId = 'cluster_${entry.key}';
        final position = NLatLng(lat, lng);
        _clusterPositions[markerId] = position;

        await _naverMapManager.addMarker(
          markerId: markerId,
          markerOptions: MarkerOptions(
            position: position,
            icon: HtmlIcon(content: _buildClusterHtml(stores.length, category)),
          ),
        );
        await _naverMapManager.addMarkerClickEvent(markerId: markerId);
        _registeredMarkerIds.add(markerId);
      }
    }
  }

  Future<void> _setupInitialLocation() async {
    final userPos = await _getUserCurrentLocation();
    if (userPos != null) {
      _myLocationLatLng = userPos;
      _currentCenter = userPos;
      if (mounted) {
        setState(() {});
        await _naverMapManager.setCenter(center: userPos);
      }
    }
    await _addMyLocationMarker();
    await _searchAroundCenter();
  }

  Future<NLatLng?> _getUserCurrentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      return NLatLng(position.latitude, position.longitude);
    } catch (e) {
      debugPrint('Error getting location: $e');
      return null;
    }
  }

  String _categorySearchKeyword(String category) {
    switch (category) {
      case 'restaurant':
        return '맛집';
      case 'cafe':
        return '카페';
      case 'study_cafe':
        return '스터디카페';
      case 'salon':
        return '미용실';
      default:
        return '';
    }
  }

  Future<void> _searchAroundCenter() async {
    if (_isSearching) return;
    _isSearching = true;
    if (mounted) setState(() {});

    try {
      final center = _currentCenter;
      final newBounds = mapAreaBoundsFromCenter(
        lat: center.lat,
        lng: center.lng,
      );

      final useDbOnly = shouldSkipExternalSearchForOverlap(
        newBounds: newBounds,
        lastCrawledBounds: _lastCrawledBounds,
        threshold: _overlapDbOnlyThreshold,
      );

      if (useDbOnly) {
        final ratio = mapAreaOverlapRatioAgainstNew(
          newBounds: newBounds,
          previousBounds: _lastCrawledBounds!,
        );
        debugPrint(
          '[MapSearch] DB-only (overlap ${(ratio * 100).toStringAsFixed(0)}%)',
        );
      } else {
        await _runExternalSearchPipeline(
          center: center,
          newBounds: newBounds,
        );
      }

      await _fetchStores(
        center,
        skipMarkerRefreshIfUnchanged: useDbOnly,
      );
    } catch (e) {
      debugPrint('Error searching around center: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  Future<void> _addMyLocationMarker() async {
    const html =
        '<div style="background:#1E88E5;border-radius:50%;'
        'width:18px;height:18px;border:3px solid white;'
        'box-shadow:0 0 0 2px #1E88E5,0 2px 6px rgba(0,0,0,0.4);"></div>';
    await _naverMapManager.addMarker(
      markerId: 'my_location',
      markerOptions: MarkerOptions(
        position: _myLocationLatLng ?? _fixedCenter,
        icon: HtmlIcon(content: html),
      ),
    );
  }

  Future<void> _moveToMyLocation() async {
    final pos = await _getUserCurrentLocation();
    if (pos != null) {
      setState(() {
        _myLocationLatLng = pos;
        _currentCenter = pos;
      });
      await _naverMapManager.setCenter(center: pos);
      await _addMyLocationMarker();
    } else {
      await _naverMapManager.setCenter(center: _myLocationLatLng ?? _fixedCenter);
      _currentCenter = _myLocationLatLng ?? _fixedCenter;
    }
  }

  Future<void> _zoomIn() async {
    _currentZoom = (_currentZoom + 1).clamp(1, 21);
    await _naverMapManager.setZoom(zoom: _currentZoom);
  }

  Future<void> _zoomOut() async {
    _currentZoom = (_currentZoom - 1).clamp(1, 21);
    await _naverMapManager.setZoom(zoom: _currentZoom);
  }

  double? _calcDistance(Map<String, dynamic> store) {
    final lat = store['latitude'] as double?;
    final lng = store['longitude'] as double?;
    if (lat == null || lng == null) return null;
    return Geolocator.distanceBetween(
      _myLocationLatLng?.lat ?? _fixedCenter.lat,
      _myLocationLatLng?.lng ?? _fixedCenter.lng,
      lat,
      lng,
    );
  }

  String _formatDistance(double meters) {
    if (meters < 1000) return '${meters.round()}m';
    return '${(meters / 1000).toStringAsFixed(1)}km';
  }

  String _walkingTime(double meters) {
    final minutes = math.max(1, (meters / 83.3).ceil());
    return '도보 $minutes분';
  }

  @override
  void dispose() {
    _searchCooldownTimer?.cancel();
    _mapStatusSubscription.cancel();
    _markerEventSubscription?.cancel();
    _mapEventSubscription?.cancel();
    _naverMapManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mapOptions = MapOptions(
      center: _fixedCenter,
      zoom: _currentZoom,
      zoomControl: false,
      mapTypeId: NaverMapMapTypeId.normal,
    );

    return Scaffold(
      body: Stack(
        children: [
          NaverMapWidget(
            naverMapManager: _naverMapManager,
            mapOptions: mapOptions,
            showLoading: true,
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SearchBar(onTap: () => context.push('/map/search')),
                _CategoryChips(
                  selected: _selectedCategory,
                  onSelect: (value) {
                    setState(() {
                      _selectedCategory = value;
                      _selectedStore = null;
                    });
                    if (_mapReady) _addStoreMarkers();
                  },
                ),
              ],
            ),
          ),
          Positioned(
            right: 16,
            bottom: _selectedStore != null
                ? _storePreviewSheetHeight +
                      _searchButtonGapAboveSheet +
                      _searchAreaButtonHeight +
                      8
                : 24,
            child: Column(
              children: [
                _MapButton(icon: Icons.my_location, onTap: _moveToMyLocation),
                const SizedBox(height: 8),
                _MapButton(icon: Icons.add, onTap: _zoomIn),
                const SizedBox(height: 4),
                _MapButton(icon: Icons.remove, onTap: _zoomOut),
              ],
            ),
          ),
          Positioned(
            bottom: _selectedStore != null
                ? _storePreviewSheetHeight + _searchButtonGapAboveSheet
                : 20,
            left: 0,
            right: 0,
            child: Center(
              child: _SearchAreaButton(
                enabled: !_isSearchCooldownActive && !_isSearching,
                onTap: () {
                  setState(() => _selectedStore = null);
                  _requestSearchAroundCenter();
                },
              ),
            ),
          ),
          if (_selectedStore != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _StoreBottomSheet(
                store: _selectedStore!,
                coverImageUrl: _selectedStoreCoverImage,
                categoryEmoji: _categoryEmoji(
                  _selectedStore!['category'] as String? ?? '',
                ),
                categoryLabel: _categoryLabel(
                  _selectedStore!['category'] as String? ?? '',
                ),
                distanceM: _calcDistance(_selectedStore!),
                formatDistance: _formatDistance,
                walkingTime: _walkingTime,
                onClose: () => setState(() {
                  _selectedStore = null;
                  _selectedStoreCoverImage = null;
                }),
                onSwipeUp: () {
                  final storeId = _selectedStore!['id']?.toString() ?? '';
                  if (storeId.isNotEmpty) {
                    context.push(
                      '${Routes.map}/${Routes.mapStoreInformation.replaceAll(':storeId', storeId)}',
                    );
                  }
                },
              ),
            ),
          if (_isSearching)
            Positioned.fill(
              child: Container(
                color: Colors.black26,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final VoidCallback onTap;
  const _SearchBar({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: 10),
                Text(
                  '업장 검색',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.2,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  final String? selected;
  final void Function(String? value) onSelect;

  const _CategoryChips({required this.selected, required this.onSelect});

  static const _items = [
    (label: '전체', value: null as String?, emoji: '🌐'),
    (label: '식당', value: 'restaurant', emoji: '🍽️'),
    (label: '카페', value: 'cafe', emoji: '☕'),
    (label: '스터디카페', value: 'study_cafe', emoji: '📚'),
    (label: '미용실', value: 'salon', emoji: '✂'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _items.map((item) {
            final isSelected = selected == item.value;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => onSelect(item.value),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (item.value == 'salon')
                        Icon(
                          Icons.content_cut,
                          size: 13,
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                        )
                      else
                        Text(item.emoji, style: const TextStyle(fontSize: 13)),
                      const SizedBox(width: 5),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.1,
                          color: isSelected
                              ? AppColors.white
                              : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _SearchAreaButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onTap;

  const _SearchAreaButton({
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        enabled ? const Color(0xFF1A1A2E) : AppColors.textSecondary;
    const foregroundColor = AppColors.white;

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.refresh_rounded, color: foregroundColor, size: 16),
            const SizedBox(width: 6),
            const Text(
              '현 지도에서 검색',
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                color: foregroundColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoreBottomSheet extends StatelessWidget {
  final Map<String, dynamic> store;
  final String? coverImageUrl;
  final String categoryEmoji;
  final String categoryLabel;
  final double? distanceM;
  final String Function(double) formatDistance;
  final String Function(double) walkingTime;
  final VoidCallback onClose;
  final VoidCallback onSwipeUp;

  const _StoreBottomSheet({
    required this.store,
    required this.coverImageUrl,
    required this.categoryEmoji,
    required this.categoryLabel,
    required this.distanceM,
    required this.formatDistance,
    required this.walkingTime,
    required this.onClose,
    required this.onSwipeUp,
  });

  @override
  Widget build(BuildContext context) {
    final name = store['name'] as String? ?? '가게';

    return GestureDetector(
      onVerticalDragEnd: (details) {
        if ((details.primaryVelocity ?? 0) < -300) onSwipeUp();
      },
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 16,
              offset: Offset(0, -4),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.signOutArrow,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 64,
                    height: 64,
                    child: coverImageUrl != null
                        ? Image.network(coverImageUrl!, fit: BoxFit.cover)
                        : Container(
                            color: AppColors.signUpWithEmailButton,
                            child: const Icon(
                              Icons.storefront_rounded,
                              size: 28,
                              color: AppColors.textSecondary,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: const TextStyle(
                                fontFamily: AppTextStyles.fontFamily,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.3,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          GestureDetector(
                            onTap: onClose,
                            child: const Icon(
                              Icons.close,
                              size: 20,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          if (categoryLabel == '미용실')
                            const Icon(
                              Icons.content_cut,
                              size: 13,
                              color: AppColors.textSecondary,
                            )
                          else
                            Text(categoryEmoji, style: const TextStyle(fontSize: 13)),
                          const SizedBox(width: 4),
                          Text(
                            categoryLabel,
                            style: const TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              letterSpacing: -0.1,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (distanceM != null) ...[
                            const Text(
                              ' · ',
                              style:
                                  TextStyle(color: AppColors.textSecondary),
                            ),
                            const Icon(
                              Icons.place_outlined,
                              size: 13,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              formatDistance(distanceM!),
                              style: const TextStyle(
                                fontFamily: AppTextStyles.fontFamily,
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                letterSpacing: -0.1,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const Text(
                              ' · ',
                              style: TextStyle(
                                fontFamily: AppTextStyles.fontFamily,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              walkingTime(distanceM!),
                              style: const TextStyle(
                                fontFamily: AppTextStyles.fontFamily,
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                letterSpacing: -0.1,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: onSwipeUp,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: 2),
                  Text(
                    '자세히 보기',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.1,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MapButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            icon,
            size: 20,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
