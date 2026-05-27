import 'dart:async';

import 'package:capstone_2026/core/domain/model/enum/store_category.dart';
import 'package:capstone_2026/core/domain/model/store/store.dart';
import 'package:capstone_2026/core/domain/model/store/store_menu.dart';
import 'package:capstone_2026/core/domain/util/build_store_share_text.dart';
import 'package:capstone_2026/core/domain/util/parse_integer_price.dart'
    show formatMenuPriceLabel, parseIntegerPrice;
import 'package:capstone_2026/core/domain/util/store_image_display.dart';
import 'package:capstone_2026/core/domain/repository/reservation/reservation_repository.dart';
import 'package:capstone_2026/core/domain/repository/salon/salon_repository.dart';
import 'package:capstone_2026/core/domain/repository/store/store_repository.dart';
import 'package:capstone_2026/core/routing/routes.dart';
import 'package:capstone_2026/di/di_setup.dart';
import 'package:capstone_2026/feature/map_store_information/store_information/presentation/screen/map_store_information_action.dart';
import 'package:capstone_2026/feature/map_store_information/store_information/presentation/screen/map_store_information_event.dart';
import 'package:capstone_2026/feature/map_store_information/store_information/presentation/screen/map_store_information_state.dart';
import 'package:capstone_2026/feature/store_detail/data/data_source/naver_store_search_data_source.dart';
import 'package:flutter/material.dart';

class MapStoreInformationViewModel extends ChangeNotifier {
  final StoreRepository _storeRepository;
  final SalonRepository _salonRepository;
  final ReservationRepository _reservationRepository;

  Store? _cachedStore;

  MapStoreInformationViewModel({
    required StoreRepository storeRepository,
    required SalonRepository salonRepository,
    required ReservationRepository reservationRepository,
  }) : _storeRepository = storeRepository,
       _salonRepository = salonRepository,
       _reservationRepository = reservationRepository;

  MapStoreInformationState _state = const MapStoreInformationState();

  MapStoreInformationState get state => _state;

  final StreamController<MapStoreInformationEvent> _eventController =
      StreamController<MapStoreInformationEvent>.broadcast();

  Stream<MapStoreInformationEvent> get eventStream => _eventController.stream;

  Future<void> initialize(String storeId) async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    try {
      final (store, menus, images, layoutDetail) = await (
        _storeRepository.getStoreById(storeId),
        _storeRepository.getStoreMenusByStoreId(storeId),
        _storeRepository.getStoreImagesByStoreId(storeId),
        _storeRepository.getStoreLayoutByStoreId(storeId),
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
        storeDescription: store.description?.trim() ?? '',
        operatingHours: store.operatingHours,
        menus: menus,
        imageUrls: imageUrls,
        imageUrl: storeHeaderImageUrl(images),
        naverPlaceId: store.naverPlaceId ?? '',
        isReservationAvailable: store.isOnboarded,
        layoutDetail: layoutDetail,
        isLoading: false,
      );

      _cachedStore = store;

      final storeCategory = StoreCategory.fromDbValue(store.category);
      if (store.isOnboarded &&
          (storeCategory == StoreCategory.restaurant ||
              storeCategory == StoreCategory.cafe)) {
        final today = DateTime.now();
        final todayDate = DateTime(today.year, today.month, today.day);
        _state = _state.copyWith(reservationAvailabilityDate: todayDate);
        unawaited(_loadReservationAvailability(todayDate));
      }

      if (store.isOnboarded && storeCategory == StoreCategory.salon) {
        final designers =
            (await _salonRepository.getDesignersByStoreId(store.id))
                .where((designer) => designer.isActive && !designer.isDeleted)
                .toList();
        _state = _state.copyWith(salonDesigners: designers);
      }
      _initTabs();

      // 네이버 플레이스 실시간 메뉴가 있는 경우 비동기로 가져와 덮어씌움
      if (store.naverPlaceId != null && store.naverPlaceId!.trim().isNotEmpty) {
        _loadNaverMenus(store.naverPlaceId!.trim());
      }
    } catch (_) {
      _state = _state.copyWith(isLoading: false);
      _eventController.add(
        const MapStoreInformationEvent.showSnackBar('업장 정보를 불러오지 못했습니다.'),
      );
    }

    notifyListeners();
  }

  Future<void> _loadNaverMenus(String naverPlaceId) async {
    try {
      final naverDataSource = getIt<NaverStoreSearchDataSource>();
      final rawMenus = await naverDataSource.fetchStoreMenus(
        placeId: naverPlaceId,
      );

      if (rawMenus.isNotEmpty) {
        final List<StoreMenu> naverMenus = rawMenus.asMap().entries.map((
          entry,
        ) {
          final index = entry.key;
          final item = entry.value;
          return StoreMenu(
            id: item['id']?.toString(),
            name: item['name']?.toString() ?? '',
            price: parseIntegerPrice(item['price']),
            priceDisplay: formatMenuPriceLabel(item['price']),
            description: item['description']?.toString() ?? '',
            imageUrl: item['imageUrl']?.toString() ?? '',
            sortOrder: index,
            isAvailable: true,
          );
        }).toList();

        _state = _state.copyWith(menus: naverMenus);
        notifyListeners();
      }
    } catch (e, stack) {
      debugPrint(
        '[MapStoreInformationViewModel] Failed to load Naver menus: $e',
      );
      debugPrint('[MapStoreInformationViewModel] Stacktrace: $stack');
    }
  }

  void _initTabs() {
    final category = StoreCategory.fromDbValue(state.category);
    final isCafeOrRestaurant =
        (category == StoreCategory.cafe ||
        category == StoreCategory.restaurant);
    if (isCafeOrRestaurant) {
      _state = state.copyWith(
        tabs: const ['홈', '메뉴', '내부', '예약', '사진', '리뷰'],
        sliderController: PageController(),
      );
    } else {
      _state = state.copyWith(
        tabs: const ['홈', '예약', '사진', '리뷰'],
        sliderController: PageController(),
      );
    }
  }

  void onAction(MapStoreInformationAction action) {
    switch (action) {
      case TapMapStoreInformationBack():
        _eventController.add(const MapStoreInformationEvent.pop());
        break;
      case TapMapStoreInformationShare():
        _eventController.add(
          MapStoreInformationEvent.share(
            text: buildStoreShareText(
              route: StoreShareRoute.map,
              storeId: _state.storeId,
              name: _state.name,
              address: _state.address,
              naverPlaceId: _state.naverPlaceId,
            ),
            subject: _state.name,
          ),
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
        if (!_state.isReservationAvailable) {
          _eventController.add(
            const MapStoreInformationEvent.showSnackBar(
              '아직 입점하지 않은 매장입니다.',
            ),
          );
          return;
        }
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
      case TapMapStoreInformationSalonDesignerReservation(
        :final currentLocation,
        :final designerId,
      ):
        if (!_state.isReservationAvailable) {
          _eventController.add(
            const MapStoreInformationEvent.showSnackBar(
              '아직 입점하지 않은 매장입니다.',
            ),
          );
          return;
        }
        final uri = Uri(
          path: '$currentLocation/${Routes.salonReservation}',
          queryParameters: {'designerId': designerId},
        );
        _eventController.add(MapStoreInformationEvent.push(uri.toString()));
        break;
      case SliderMapStoreInformationPageChanged(:final index):
        _state = _state.copyWith(currentSliderPage: index);
        notifyListeners();
        break;
      case ChangeMapStoreInformationReservationAvailabilityDate(:final date):
        final calendarDate = DateTime(date.year, date.month, date.day);
        _state = _state.copyWith(reservationAvailabilityDate: calendarDate);
        notifyListeners();
        unawaited(_loadReservationAvailability(calendarDate));
        break;
    }
  }

  Future<void> _loadReservationAvailability(DateTime date) async {
    final store = _cachedStore;
    if (store == null || !store.isOnboarded) {
      return;
    }

    _state = _state.copyWith(isReservationAvailabilityLoading: true);
    notifyListeners();

    try {
      final slots = await _reservationRepository.getAvailabilityForDate(
        store: store,
        date: date,
      );
      _state = _state.copyWith(
        isReservationAvailabilityLoading: false,
        reservationAvailabilitySlots: slots,
      );
      notifyListeners();
    } catch (_) {
      _state = _state.copyWith(
        isReservationAvailabilityLoading: false,
        reservationAvailabilitySlots: const [],
      );
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }
}
