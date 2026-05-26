import 'dart:async';
import 'dart:math' as math;

import 'package:capstone_2026/core/domain/model/store/store.dart';
import 'package:capstone_2026/core/domain/util/map_naver_place_operating_hours.dart';
import 'package:capstone_2026/core/domain/repository/store/store_repository.dart';
import 'package:capstone_2026/core/routing/routes.dart';
import 'package:capstone_2026/di/di_setup.dart';
import 'package:capstone_2026/feature/store_detail/data/data_source/kakao_store_search_data_source.dart';
import 'package:capstone_2026/feature/store_detail/data/data_source/naver_store_search_data_source.dart';
import 'package:capstone_2026/ui/app_colors.dart';
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
  NLatLng _currentCenter = _fixedCenter;
  NLatLng? _myLocationLatLng;
  bool _isSearching = false;
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

  Future<void> _fetchStores(NLatLng center) async {
    try {
      final double latOffset = 0.0135;
      final double lngOffset = 0.017;
      final minLat = center.lat - latOffset;
      final maxLat = center.lat + latOffset;
      final minLng = center.lng - lngOffset;
      final maxLng = center.lng + lngOffset;

      final response = await Supabase.instance.client
          .from('stores')
          .select('id, name, category, latitude, longitude, address')
          .gte('latitude', minLat)
          .lte('latitude', maxLat)
          .gte('longitude', minLng)
          .lte('longitude', maxLng);

      if (!mounted) return;
      setState(() => _stores = List<Map<String, dynamic>>.from(response));
      if (_mapReady) _addStoreMarkers();
    } catch (e) {
      debugPrint('stores fetch error: $e');
    }
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
    setState(() {});

    try {
      final center = _currentCenter;

      final categoriesToSearch = _selectedCategory != null
          ? [_selectedCategory!]
          : ['restaurant', 'cafe', 'study_cafe', 'salon'];

      final storeRepo = getIt<StoreRepository>();
      final kakaoSource = getIt<KakaoStoreSearchDataSource>();
      final naverSource = getIt<NaverStoreSearchDataSource>();
      final List<Map<String, dynamic>> rawCandidates = [];

      for (final cat in categoriesToSearch) {
        final queryKeyword = _categorySearchKeyword(cat);
        if (queryKeyword.isEmpty) continue;

        try {
          final kakaoItems = await kakaoSource.searchStoresByCoordinates(
            keyword: queryKeyword,
            lat: center.lat,
            lng: center.lng,
            radius: 1000,
          );
          for (final item in kakaoItems) {
            rawCandidates.add({
              'item': item,
              'category': cat,
            });
          }
        } catch (e) {
          debugPrint('Error searching category $cat: $e');
        }
      }

      final Map<String, Map<String, dynamic>> uniqueCandidates = {};

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

        final key = '$name|$targetCheckAddress';
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

      final candidatesList = uniqueCandidates.values.toList();
      final List<Map<String, dynamic>> newStoresToRegister = [];

      final checkFutures = candidatesList.map((cand) async {
        try {
          Map<String, dynamic>? existing;

          final fallbackPlaceId = cand['fallbackPlaceId'] as String;
          if (fallbackPlaceId.isNotEmpty) {
            existing = await Supabase.instance.client
                .from('stores')
                .select('id')
                .eq('naver_place_id', fallbackPlaceId)
                .maybeSingle();
          }

          existing ??= await Supabase.instance.client
              .from('stores')
              .select('id')
              .eq('name', cand['name'] as String)
              .eq('address', cand['address'] as String)
              .maybeSingle();

          if (existing == null) {
            newStoresToRegister.add(cand);
          }
        } catch (e) {
          debugPrint('Error checking DB existence for ${cand['name']}: $e');
        }
      });

      await Future.wait(checkFutures);

      if (newStoresToRegister.isNotEmpty) {
        final registerFutures = newStoresToRegister.map((cand) async {
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
          debugPrint('[MapCrawl] 좌표: lat=$lat, lng=$lng, fallbackPlaceId=$fallbackPlaceId, telephone=$telephone');

          try {
            // 1단계: 모바일 웹 검색으로 place ID + 전화번호 확보
            String? placeId = fallbackPlaceId.isNotEmpty ? fallbackPlaceId : null;
            if (placeId == null) {
              final mobileInfo = await naverSource.fetchPlaceInfoFromMobileSearch(
                storeName: name,
              );
              placeId = mobileInfo?['placeId'];
              final mobilePhone = mobileInfo?['phone'];
              if (mobilePhone != null && mobilePhone.isNotEmpty) {
                finalContact = mobilePhone;
              }
              debugPrint('[MapCrawl] 모바일 검색 결과 - placeId: $placeId, phone: $mobilePhone');
            }

            if (placeId != null && placeId.isNotEmpty) {
              finalPlaceId = placeId;

              // 2단계: Summary → businessType 반영 후 영업시간(GraphQL) 수집
              final summary = await naverSource.fetchPlaceSummary(
                placeId: placeId,
              );
              final businessTypeRaw = summary?['businessType'];
              final businessType = businessTypeRaw is String &&
                      businessTypeRaw.trim().isNotEmpty
                  ? businessTypeRaw.trim()
                  : 'restaurant';
              final hoursPayload =
                  await naverSource.fetchPlaceOperatingHours(
                placeId: placeId,
                businessType: businessType,
              );

              debugPrint(
                '[MapCrawl] fetchPlaceSummary 결과: ${summary != null ? "성공 (keys: ${summary.keys.toList()})" : "null"}',
              );

              final structuredHours = mapNaverWeeklyHoursToStoreOperatingHours(
                hoursPayload,
              );
              if (structuredHours != null && structuredHours.isNotEmpty) {
                operatingHours = structuredHours;
                debugPrint(
                  '[MapCrawl] 구조화 영업시간 저장 keys: ${structuredHours.keys.toList()}',
                );
              }

              if (summary != null) {
                // 전화번호
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

                // 영업시간: GraphQL 실패 시 Summary 한 줄 텍스트 fallback
                if (operatingHours.isEmpty) {
                  final bizHoursObj =
                      summary['businessHours'] as Map<String, dynamic>?;
                  final bizHours = bizHoursObj?['description'] as String?;
                  if (bizHours != null && bizHours.isNotEmpty) {
                    operatingHours = {'text': bizHours};
                  }
                }

                // 대표 이미지 및 다중 이미지
                final imagesObj = summary['images'] as Map<String, dynamic>?;
                final imagesList = imagesObj?['images'] as List?;
                if (imagesList != null && imagesList.isNotEmpty) {
                  for (final img in imagesList) {
                    final imgMap = img as Map<String, dynamic>?;
                    final imgUrl = imgMap?['origin'] as String? ?? imgMap?['url'] as String?;
                    if (imgUrl != null && imgUrl.isNotEmpty) {
                      finalImageUrls.add(imgUrl);
                    }
                  }
                  if (finalImageUrls.isNotEmpty) {
                    finalThumUrl = finalImageUrls.first;
                  }
                }

                // 리뷰 평점
                final visitorReviews = summary['visitorReviews'] as Map<String, dynamic>?;
                if (visitorReviews != null) {
                  final scoreRaw = visitorReviews['score'];
                  if (scoreRaw != null) {
                    if (scoreRaw is num) {
                      finalRating = scoreRaw.toDouble();
                    } else if (scoreRaw is String) {
                      finalRating = double.tryParse(scoreRaw) ?? 0.0;
                    }
                  }
                }

                debugPrint('[MapCrawl] 최종 - contact=$finalContact, bizHours=$operatingHours, thumUrl=$finalThumUrl, rating=$finalRating');
              }
            } else {
              debugPrint('[MapCrawl] placeId 확보 실패 for $name');
            }
          } catch (crawlErr) {
            debugPrint(
              '[MapCrawl] 크롤링 실패 for $name: $crawlErr',
            );
          }

          debugPrint('[MapCrawl] DB 저장 시도 - name=$name, placeId=$finalPlaceId, contact=$finalContact, operatingHours=$operatingHours, thumUrl=$finalThumUrl, rating=$finalRating');

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
                final imgUrl = finalImageUrls[i];
                await storeRepo.addStoreImage(
                  createdStore.id,
                  imgUrl,
                  isCover: i == 0,
                );
                debugPrint('[MapCrawl] 이미지 저장 성공 ($i) - $imgUrl, isCover: ${i == 0}');
              }
            } else if (finalThumUrl != null && finalThumUrl.isNotEmpty) {
              await storeRepo.addStoreImage(
                createdStore.id,
                finalThumUrl,
                isCover: true,
              );
              debugPrint('[MapCrawl] 이미지 저장 성공 (단일) - $finalThumUrl');
            }
          } catch (dbErr) {
            debugPrint('[MapCrawl] DB 저장 실패 for $name: $dbErr');
          }
        });

        await Future.wait(registerFutures);
      }

      await _fetchStores(center);

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
            bottom: _selectedStore != null ? 148 : 24,
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
            bottom: _selectedStore != null ? 144 : 20,
            left: 0,
            right: 0,
            child: Center(
              child: _SearchAreaButton(
                onTap: () {
                  setState(() => _selectedStore = null);
                  _searchAroundCenter();
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
              color: Colors.white,
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
                Icon(Icons.search_rounded, color: Color(0xFF6B7280)),
                SizedBox(width: 10),
                Text(
                  '업장 검색',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF9CA3AF),
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
                    color: isSelected ? AppColors.primary : Colors.white,
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
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
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
  final VoidCallback onTap;
  const _SearchAreaButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.refresh_rounded, color: Colors.white, size: 16),
            SizedBox(width: 6),
            Text(
              '현 지도에서 검색',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
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
          color: Colors.white,
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
                  color: const Color(0xFFD1D5DB),
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
                            color: const Color(0xFFF3F4F6),
                            child: const Icon(
                              Icons.storefront_rounded,
                              size: 28,
                              color: Color(0xFF9CA3AF),
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
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
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
                              color: Color(0xFF9CA3AF),
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
                              fontSize: 13,
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
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const Text(
                              ' · ',
                              style: TextStyle(
                                  color: AppColors.textSecondary),
                            ),
                            Text(
                              walkingTime(distanceM!),
                              style: const TextStyle(
                                fontSize: 13,
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
                    color: Color(0xFF9CA3AF),
                  ),
                  SizedBox(width: 2),
                  Text(
                    '자세히 보기',
                    style:
                        TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(icon, size: 20, color: Colors.black87),
        ),
      ),
    );
  }
}
