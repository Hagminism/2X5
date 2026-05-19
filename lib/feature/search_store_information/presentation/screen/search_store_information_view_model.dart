import 'dart:async';

import 'package:capstone_2026/core/domain/model/enum/store_category.dart';
import 'package:capstone_2026/core/domain/util/format_today_operating_hours.dart';
import 'package:capstone_2026/core/domain/util/store_image_display.dart';
import 'package:capstone_2026/core/domain/repository/salon/salon_repository.dart';
import 'package:capstone_2026/core/domain/repository/store/store_repository.dart';
import 'package:capstone_2026/core/routing/routes.dart';
import 'package:capstone_2026/feature/search_store_information/presentation/screen/search_store_information_action.dart';
import 'package:capstone_2026/feature/search_store_information/presentation/screen/search_store_information_event.dart';
import 'package:capstone_2026/feature/search_store_information/presentation/screen/search_store_information_state.dart';
import 'package:flutter/material.dart';

class SearchStoreInformationViewModel extends ChangeNotifier {
  final StoreRepository _storeRepository;
  final SalonRepository _salonRepository;

  SearchStoreInformationViewModel({
    required StoreRepository storeRepository,
    required SalonRepository salonRepository,
  }) : _storeRepository = storeRepository,
       _salonRepository = salonRepository;

  SearchStoreInformationState _state = const SearchStoreInformationState();

  SearchStoreInformationState get state => _state;

  final StreamController<SearchStoreInformationEvent> _eventController =
      StreamController<SearchStoreInformationEvent>.broadcast();

  Stream<SearchStoreInformationEvent> get eventStream =>
      _eventController.stream;

  Future<void> initialize(String storeId) async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    try {
      final (store, menus, images) = await (
        _storeRepository.getStoreById(storeId),
        _storeRepository.getStoreMenusByStoreId(storeId),
        _storeRepository.getStoreImagesByStoreId(storeId),
      ).wait;

      final imageUrls = storeImageDisplayUrls(images);

      _state = _state.copyWith(
        storeId: store.id,
        name: store.name,
        subtitle:
            '${StoreCategory.fromDbValue(store.category)?.displayName ?? store.category} · ${store.address}',
        rating: store.rating,
        category: store.category,
        address: store.address,
        displayPhone: store.contact.trim(),
        operatingHoursText: formatTodayOperatingHours(store.operatingHours),
        menus: menus,
        imageUrls: imageUrls,
        imageUrl: storeHeaderImageUrl(images),
        isLoading: false,
      );

      if (StoreCategory.fromDbValue(store.category) == StoreCategory.salon) {
        final designers =
            (await _salonRepository.getDesignersByStoreId(store.id))
                .where((designer) => designer.isActive && !designer.isDeleted)
                .toList();
        _state = _state.copyWith(salonDesigners: designers);
      }
    } catch (_) {
      _state = _state.copyWith(isLoading: false);
      _eventController.add(
        const SearchStoreInformationEvent.showSnackBar('업장 정보를 불러오지 못했습니다.'),
      );
    }

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
      case TapSearchStoreInformationSalonDesignerReservation(
        :final currentLocation,
        :final designerId,
      ):
        final uri = Uri(
          path: '$currentLocation/${Routes.salonReservation}',
          queryParameters: {'designerId': designerId},
        );
        _eventController.add(SearchStoreInformationEvent.push(uri.toString()));
        break;
    }
  }

  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }
}
