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
        final storeId = event.markerId.replaceFirst('store_', '');
        final matches = _stores.where((s) => s['id'].toString() == storeId);
        if (matches.isNotEmpty && mounted) {
          setState(() => _selectedStore = matches.first);
        }
      }
    });
    _mapEventSubscription = _naverMapManager.onMapEvent.listen((event) {
      if (event is MapClick && mounted) {
        setState(() => _selectedStore = null);
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

  Future<void> _addStoreMarkers() async {
    await _naverMapManager.removeMarkerAll();
    await _addMyLocationMarker();
    for (final store in _filteredStores) {
      final lat = store['latitude'] as double?;
      final lng = store['longitude'] as double?;
      final category = store['category'] as String? ?? '';
      final id = store['id']?.toString() ?? '';
      if (lat == null || lng == null) continue;

      final color = _categoryColor(category);
      final emoji = _categoryEmoji(category);
      final html =
          '<div style="background:$color;color:white;border-radius:50%;'
          'width:32px;height:32px;display:flex;align-items:center;'
          'justify-content:center;font-size:16px;box-shadow:0 2px 4px rgba(0,0,0,0.3);">'
          '$emoji</div>';

      await _naverMapManager.addMarker(
        markerId: 'store_$id',
        markerOptions: MarkerOptions(
          position: NLatLng(lat, lng),
          icon: HtmlIcon(content: html),
        ),
      );
      await _naverMapManager.addMarkerClickEvent(markerId: 'store_$id');
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

  String _walkingTime(double distanceM) {
    final minutes = math.max(1, (distanceM / 83.3).ceil());
    return '도보 $minutes분';
  }

  String? _getDistance(Map<String, dynamic> store) {
    final lat = store['latitude'] as double?;
    final lng = store['longitude'] as double?;
    if (lat == null || lng == null) return null;
    final d = Geolocator.distanceBetween(
      _fixedCenter.lat,
      _fixedCenter.lng,
      lat,
      lng,
    );
    return _walkingTime(d);
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
            bottom: _selectedStore != null ? 220 : 24,
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
            bottom: _selectedStore != null ? 216 : 20,
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
                categoryLabel: _categoryLabel(
                  _selectedStore!['category'] as String? ?? '',
                ),
                distance: _getDistance(_selectedStore!),
                onClose: () => setState(() => _selectedStore = null),
                onReserve: () {
                  final storeId = _selectedStore!['id']?.toString() ?? '';
                  if (storeId.isNotEmpty) {
                    context.push('/home/store/$storeId');
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
    (label: '전체', value: null as String?),
    (label: '식당', value: 'restaurant'),
    (label: '카페', value: 'cafe'),
    (label: '스터디카페', value: 'study_cafe'),
    (label: '미용실', value: 'salon'),
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
                child: Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
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
  final String categoryLabel;
  final String? distance;
  final VoidCallback onClose;
  final VoidCallback onReserve;

  const _StoreBottomSheet({
    required this.store,
    required this.categoryLabel,
    required this.distance,
    required this.onClose,
    required this.onReserve,
  });

  @override
  Widget build(BuildContext context) {
    final name = store['name'] as String? ?? '가게';
    final subtitle = [categoryLabel, distance].whereType<String>().join(' · ');

    return Container(
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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.store_outlined,
                  color: Color(0xFFD1D5DB),
                  size: 32,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                          child: const Icon(
                            Icons.close,
                            size: 20,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: onReserve,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '예약하기',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
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
