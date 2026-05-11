import 'dart:async';

import 'package:capstone_2026/core/domain/model/enum/store_category.dart';
import 'package:capstone_2026/core/domain/repository/store/store_repository.dart';
import 'package:capstone_2026/core/routing/routes.dart';
import 'package:capstone_2026/feature/search_store_information/presentation/screen/search_store_information_action.dart';
import 'package:capstone_2026/feature/search_store_information/presentation/screen/search_store_information_event.dart';
import 'package:capstone_2026/feature/search_store_information/presentation/screen/search_store_information_state.dart';
import 'package:flutter/material.dart';

class SearchStoreInformationViewModel extends ChangeNotifier {
  final StoreRepository _storeRepository;

  SearchStoreInformationViewModel({
    required StoreRepository storeRepository,
  }) : _storeRepository = storeRepository;

  SearchStoreInformationState _state = const SearchStoreInformationState();

  SearchStoreInformationState get state => _state;

  final StreamController<SearchStoreInformationEvent> _eventController =
      StreamController<SearchStoreInformationEvent>.broadcast();

  Stream<SearchStoreInformationEvent> get eventStream =>
      _eventController.stream;

  Future<void> initialize(String storeId) async {
    final store = await _storeRepository.getStoreById(storeId);
    if (store == null) {
      _eventController.add(
        const SearchStoreInformationEvent.showSnackBar('업장 정보를 불러오지 못했습니다.'),
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

  void onAction(SearchStoreInformationAction action) {
    switch (action) {
      case TapSearchStoreInformationBack():
        _eventController.add(const SearchStoreInformationEvent.pop());
        break;
      case TapSearchStoreInformationShare():
        _eventController.add(
          const SearchStoreInformationEvent.showSnackBar('공유 기능은 준비 중입니다.'),
        );
        break;
      case TapSearchStoreInformationBookmark():
        final isBookmarked = !_state.isBookmarked;
        _state = _state.copyWith(isBookmarked: isBookmarked);
        notifyListeners();
        _eventController.add(
          SearchStoreInformationEvent.showSnackBar(
            isBookmarked ? '즐겨찾기에 추가했습니다.' : '즐겨찾기를 해제했습니다.',
          ),
        );
        break;
      case TapSearchStoreInformationReservation(:final currentLocation):
        final category = StoreCategory.fromDbValue(_state.category);
        final target = switch (category) {
          StoreCategory.studyCafe => Routes.seat,
          StoreCategory.salon => Routes.salonReservation,
          _ => Routes.reservation,
        };
        _eventController.add(
          SearchStoreInformationEvent.push('$currentLocation/$target'),
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
