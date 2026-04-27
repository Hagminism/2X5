import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:capstone_2026/feature/home/presentation/component/home_search_bar.dart';
import 'package:naver_maps_sdk_flutter/enum/naver_map_map_type_id.dart';
import 'package:naver_maps_sdk_flutter/event/map_load_status_event.dart';
import 'package:naver_maps_sdk_flutter/model/map_options.dart';
import 'package:naver_maps_sdk_flutter/model/marker_options.dart';
import 'package:naver_maps_sdk_flutter/model/n_lat_lng.dart';
import 'package:naver_maps_sdk_flutter/sdk_app/naver_maps_sdk_flutter_app.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late final NaverMapManager _naverMapManager;
  late final StreamSubscription _mapStatusSubscription;

  NLatLng _initialCenter = NLatLng(37.5665, 126.9780);
  int _currentZoom = 15;
  bool _locationReady = false;

  @override
  void initState() {
    super.initState();
    _naverMapManager = NaverMapManager.createNaverMapManager();
    _mapStatusSubscription = _naverMapManager.onMapLoadStatus.listen((status) {
      if (status is MapLoadSuccess) {
        _naverMapManager.addMapCenterChangedEventListener();
        _addMyLocationMarker();
      }
    });
    _loadCurrentLocation();
  }

  Future<void> _loadCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) return;

      final position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _initialCenter = NLatLng(position.latitude, position.longitude);
          _locationReady = true;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _locationReady = true);
    }
  }

  Future<void> _addMyLocationMarker() async {
    await _naverMapManager.addMarker(
      markerId: 'my_location',
      markerOptions: MarkerOptions(position: _initialCenter),
    );
  }

  Future<void> _moveToMyLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      final myLocation = NLatLng(position.latitude, position.longitude);
      await _naverMapManager.setCenter(center: myLocation);
    } catch (_) {}
  }

  Future<void> _zoomIn() async {
    _currentZoom = (_currentZoom + 1).clamp(1, 21);
    await _naverMapManager.setZoom(zoom: _currentZoom);
  }

  Future<void> _zoomOut() async {
    _currentZoom = (_currentZoom - 1).clamp(1, 21);
    await _naverMapManager.setZoom(zoom: _currentZoom);
  }

  @override
  void dispose() {
    _mapStatusSubscription.cancel();
    _naverMapManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_locationReady) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final mapOptions = MapOptions(
      center: _initialCenter,
      zoom: _currentZoom,
      zoomControl: false,
      mapTypeId: NaverMapMapTypeId.normal,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Material(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: HomeSearchBar(onTap: () {}),
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  NaverMapWidget(
                    naverMapManager: _naverMapManager,
                    mapOptions: mapOptions,
                    showLoading: true,
                  ),
                  Positioned(
                    right: 16,
                    bottom: 24,
                    child: Column(
                      children: [
                        _ZoomButton(
                          icon: Icons.my_location,
                          onTap: _moveToMyLocation,
                        ),
                        const SizedBox(height: 8),
                        _ZoomButton(icon: Icons.add, onTap: _zoomIn),
                        const SizedBox(height: 4),
                        _ZoomButton(icon: Icons.remove, onTap: _zoomOut),
                      ],
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

class _ZoomButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ZoomButton({required this.icon, required this.onTap});

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
