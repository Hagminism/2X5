import 'dart:async';

import 'package:capstone_2026/core/domain/model/enum/store_category.dart';
import 'package:capstone_2026/core/domain/repository/store/store_repository.dart';
import 'package:capstone_2026/core/routing/routes.dart';
import 'package:capstone_2026/feature/map_store_information/presentation/screen/map_store_information_action.dart';
import 'package:capstone_2026/feature/map_store_information/presentation/screen/map_store_information_event.dart';
import 'package:capstone_2026/feature/map_store_information/presentation/screen/map_store_information_state.dart';
import 'package:flutter/material.dart';

class MapStoreInformationViewModel extends ChangeNotifier {
  final StoreRepository _storeRepository;

  MapStoreInformationViewModel({
    required StoreRepository storeRepository,
  }) : _storeRepository = storeRepository;

  MapStoreInformationState _state = const MapStoreInformationState();

  MapStoreInformationState get state => _state;

  final StreamController<MapStoreInformationEvent> _eventController =
      StreamController<MapStoreInformationEvent>.broadcast();

  Stream<MapStoreInformationEvent> get eventStream =>
      _eventController.stream;

  Future<void> initialize(String storeId) async {
    final store = await _storeRepository.getStoreById(storeId);
    if (store == null) {
      _eventController.add(
        const MapStoreInformationEvent.showSnackBar('업장 정보를 불러오지 못했습니다.'),
      );
      return;
    }

    _state = _state.copyWith(
      storeId: store.id,
      name: store.name,
      subtitle:
          '${StoreCategory.fromDbValue(store.category)?.displayName ?? store.category} · ${store.address}',
      rating: store.rating,
      category: store.category,
    );
    notifyListeners();
  }

  void onAction(MapStoreInformationAction action) {
    switch (action) {
      case TapMapStoreInformationBack():
        _eventController.add(const MapStoreInformationEvent.pop());
        break;
      case TapMapStoreInformationShare():
        _eventController.add(
          const MapStoreInformationEvent.showSnackBar('공유 기능은 준비 중입니다.'),
        );
        break;
      case TapMapStoreInformationBookmark():
        final isBookmarked = !_state.isBookmarked;
        _state = _state.copyWith(isBookmarked: isBookmarked);
        notifyListeners();
        _eventController.add(
          MapStoreInformationEvent.showSnackBar(
            isBookmarked ? '즐겨찾기에 추가했습니다.' : '즐겨찾기를 해제했습니다.',
          ),
        );
        break;
      case TapMapStoreInformationReservation(:final currentLocation):
        final category = StoreCategory.fromDbValue(_state.category);
        final target = switch (category) {
          StoreCategory.studyCafe => Routes.seat,
          StoreCategory.salon => Routes.salonReservation,
          _ => Routes.reservation,
        };
        _eventController.add(
          MapStoreInformationEvent.push('$currentLocation/$target'),
        );
        break;
    }
  }

  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }
}
