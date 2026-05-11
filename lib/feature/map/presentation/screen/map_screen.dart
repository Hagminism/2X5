import 'dart:async';
import 'dart:math' as math;

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
  int _currentZoom = 15;
  bool _mapReady = false;
  List<Map<String, dynamic>> _stores = [];
  String? _selectedCategory;
  Map<String, dynamic>? _selectedStore;
  String? _selectedMarkerId;
  DateTime? _lastMarkerClickTime;
  final Set<String> _registeredMarkerIds = {};

  @override
  void initState() {
    super.initState();
    _naverMapManager = NaverMapManager.createNaverMapManager();
    _mapStatusSubscription = _naverMapManager.onMapLoadStatus.listen((status) {
      if (status is MapLoadSuccess) {
        _naverMapManager.addMapCenterChangedEventListener();
        _naverMapManager.addMapClickEventListener();
        _addMyLocationMarker();
        _mapReady = true;
        if (_stores.isNotEmpty) _addStoreMarkers();
      }
    });
    _markerEventSubscription = _naverMapManager.onMarkerEvent.listen((event) {
      if (event is MarkerClick) {
        final markerId = event.markerId;
        final storeId = markerId.replaceFirst('store_', '');
        final matches = _stores.where((s) => s['id'].toString() == storeId);
        if (matches.isNotEmpty && mounted) {
          _lastMarkerClickTime = DateTime.now();
          final prev = _selectedMarkerId;
          setState(() {
            _selectedStore = matches.first;
            _selectedMarkerId = markerId;
          });
          if (prev != null && prev != markerId) {
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
            DateTime.now().difference(last) < const Duration(milliseconds: 600)) {
          return;
        }
        final prev = _selectedMarkerId;
        setState(() {
          _selectedStore = null;
          _selectedMarkerId = null;
        });
        if (prev != null) _updateMarkerAppearance(prev, isSelected: false);
      }
    });
    _fetchStores();
  }

  Future<void> _fetchStores() async {
    try {
      final response = await Supabase.instance.client
          .from('stores')
          .select('id, name, category, latitude, longitude, address');
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
        '$emoji</div>';
  }

  Future<void> _updateMarkerAppearance(String markerId, {required bool isSelected}) async {
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
        icon: HtmlIcon(content: _buildMarkerHtml(category, isSelected: isSelected)),
      ),
    );
  }

  Future<void> _addStoreMarkers() async {
    // removeMarkerAll() 전에 click event 먼저 해제해야 함
    // SDK 버그: removeMarkerAll()이 markerEventListeners를 초기화하지 않아서
    // addMarkerClickEvent()가 "이미 등록됨"으로 보고 skip함
    for (final id in _registeredMarkerIds) {
      await _naverMapManager.removeMarkerClickEvent(markerId: id);
    }
    _registeredMarkerIds.clear();
    _selectedMarkerId = null;

    await _naverMapManager.removeMarkerAll();
    await _addMyLocationMarker();

    for (final store in _filteredStores) {
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
        position: _fixedCenter,
        icon: HtmlIcon(content: html),
      ),
    );
  }

  Future<void> _moveToMyLocation() async {
    await _naverMapManager.setCenter(center: _fixedCenter);
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
      _fixedCenter.lat,
      _fixedCenter.lng,
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
                  _fetchStores();
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
                categoryEmoji: _categoryEmoji(
                  _selectedStore!['category'] as String? ?? '',
                ),
                categoryLabel: _categoryLabel(
                  _selectedStore!['category'] as String? ?? '',
                ),
                distanceM: _calcDistance(_selectedStore!),
                formatDistance: _formatDistance,
                walkingTime: _walkingTime,
                onClose: () => setState(() => _selectedStore = null),
                onSwipeUp: () {
                  final storeId = _selectedStore!['id']?.toString() ?? '';
                  if (storeId.isNotEmpty) {
                    context.pushNamed(
                      'information',
                      pathParameters: {'storeId': storeId},
                    );
                  }
                },
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
    (label: '전체', value: null as String?, emoji: '🗺'),
    (label: '식당', value: 'restaurant', emoji: '🍽'),
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
                    color:
                        isSelected ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(item.emoji, style: const TextStyle(fontSize: 13)),
                    const SizedBox(width: 5),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : AppColors.textPrimary,
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
  final String categoryEmoji;
  final String categoryLabel;
  final double? distanceM;
  final String Function(double) formatDistance;
  final String Function(double) walkingTime;
  final VoidCallback onClose;
  final VoidCallback onSwipeUp;

  const _StoreBottomSheet({
    required this.store,
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  child: const Icon(Icons.close, size: 20, color: Color(0xFF9CA3AF)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(categoryEmoji, style: const TextStyle(fontSize: 13)),
                const SizedBox(width: 4),
                Text(
                  categoryLabel,
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                if (distanceM != null) ...[
                  const Text(' · ', style: TextStyle(color: AppColors.textSecondary)),
                  const Icon(Icons.place_outlined, size: 13, color: AppColors.textSecondary),
                  const SizedBox(width: 2),
                  Text(
                    formatDistance(distanceM!),
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const Text(' · ', style: TextStyle(color: AppColors.textSecondary)),
                  Text(
                    walkingTime(distanceM!),
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: onSwipeUp,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFF9CA3AF)),
                  SizedBox(width: 2),
                  Text(
                    '자세히 보기',
                    style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
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
