import 'dart:async';

import 'package:capstone_2026/core/domain/model/enum/store_category.dart';
import 'package:capstone_2026/core/domain/model/store/store_menu.dart';
import 'package:capstone_2026/core/domain/repository/bookmark/bookmark_repository.dart';
import 'package:capstone_2026/core/domain/repository/salon/salon_repository.dart';
import 'package:capstone_2026/core/domain/repository/store/store_repository.dart';
import 'package:capstone_2026/core/domain/util/build_store_share_text.dart';
import 'package:capstone_2026/core/domain/util/parse_integer_price.dart'
    show formatMenuPriceLabel, parseIntegerPrice;
import 'package:capstone_2026/core/domain/util/store_image_display.dart';
import 'package:capstone_2026/core/routing/routes.dart';
import 'package:capstone_2026/di/di_setup.dart';
import 'package:capstone_2026/feature/information/presentation/screen/information_action.dart';
import 'package:capstone_2026/feature/information/presentation/screen/information_event.dart';
import 'package:capstone_2026/feature/information/presentation/screen/information_state.dart';
import 'package:capstone_2026/feature/store_detail/data/data_source/naver_store_search_data_source.dart';
import 'package:flutter/material.dart';

class InformationViewModel extends ChangeNotifier {
  final StoreRepository _storeRepository;
  final SalonRepository _salonRepository;
  final BookmarkRepository _bookmarkRepository;

  InformationViewModel({
    required StoreRepository storeRepository,
    required SalonRepository salonRepository,
    required BookmarkRepository bookmarkRepository,
  }) : _storeRepository = storeRepository,
       _salonRepository = salonRepository,
       _bookmarkRepository = bookmarkRepository;

  InformationState _state = const InformationState();

  InformationState get state => _state;

  final StreamController<InformationEvent> _eventController =
      StreamController<InformationEvent>.broadcast();

  Stream<InformationEvent> get eventStream => _eventController.stream;

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
      final isBookmarked = await _bookmarkRepository.isBookmarked(storeId);

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
        isBookmarked: isBookmarked,
        isLoading: false,
      );

      if (store.isOnboarded &&
          StoreCategory.fromDbValue(store.category) == StoreCategory.salon) {
        final designers =
            (await _salonRepository.getDesignersByStoreId(store.id))
                .where((designer) => designer.isActive && !designer.isDeleted)
                .toList();
        _state = _state.copyWith(salonDesigners: designers);
      }

      // 가져온 업장 종류에 따라 탭 정의
      _initTabs();

      // 네이버 플레이스 실시간 메뉴가 있는 경우 비동기로 가져와 덮어씌움
      if (store.naverPlaceId != null && store.naverPlaceId!.trim().isNotEmpty) {
        _loadNaverMenus(store.naverPlaceId!.trim());
      }
    } catch (_) {
      _state = _state.copyWith(isLoading: false);
      _eventController.add(
        const InformationEvent.showSnackBar('업장 정보를 불러오지 못했습니다.'),
      );
    } finally {
      notifyListeners();
    }
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
      debugPrint('[InformationViewModel] Failed to load Naver menus: $e');
      debugPrint('[InformationViewModel] Stacktrace: $stack');
    }
  }

  void _initTabs() {
    final category = StoreCategory.fromDbValue(state.category);
    final isCafeOrRestaurant =
        (category == StoreCategory.cafe ||
        category == StoreCategory.restaurant);
    if (isCafeOrRestaurant) {
      _state = state.copyWith(
        tabs: const ['홈', '메뉴', '예약', '사진', '리뷰'],
        sliderController: PageController(),
      );
    } else {
      _state = state.copyWith(
        tabs: const ['홈', '예약', '사진', '리뷰'],
        sliderController: PageController(),
      );
    }
  }

  void onAction(InformationAction action) {
    switch (action) {
      case TapInformationBack():
        _eventController.add(const InformationEvent.pop());
        break;
      case TapInformationShare():
        _eventController.add(
          InformationEvent.share(
            text: buildStoreShareText(
              route: StoreShareRoute.home,
              storeId: _state.storeId,
              name: _state.name,
              address: _state.address,
              naverPlaceId: _state.naverPlaceId,
            ),
            subject: _state.name,
          ),
        );
        break;
      case TapInformationBookmark():
        unawaited(_toggleBookmark());
        break;
      case TapInformationReservation():
        if (!_state.isReservationAvailable) {
          _eventController.add(
            const InformationEvent.showSnackBar('아직 입점하지 않은 매장입니다.'),
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
          InformationEvent.push('${action.currentLocation}/$target'),
        );
        break;
      case TapSalonDesignerReservation(
        :final currentLocation,
        :final designerId,
      ):
        if (!_state.isReservationAvailable) {
          _eventController.add(
            const InformationEvent.showSnackBar('아직 입점하지 않은 매장입니다.'),
          );
          return;
        }
        final uri = Uri(
          path: '$currentLocation/${Routes.salonReservation}',
          queryParameters: {'designerId': designerId},
        );
        _eventController.add(InformationEvent.push(uri.toString()));
        break;
      case SliderPageChanged(:final index):
        _state = _state.copyWith(currentSliderPage: index);
        notifyListeners();
        break;
    }
  }

  Future<void> _toggleBookmark() async {
    final storeId = _state.storeId;
    if (storeId.isEmpty) {
      return;
    }

    final wasBookmarked = _state.isBookmarked;

    try {
      if (wasBookmarked) {
        await _bookmarkRepository.removeBookmark(storeId);
        _state = _state.copyWith(isBookmarked: false);
        _eventController.add(
          const InformationEvent.showSnackBar('즐겨찾기를 해제했습니다.'),
        );
      } else {
        await _bookmarkRepository.addBookmark(storeId);
        _state = _state.copyWith(isBookmarked: true);
        _eventController.add(
          const InformationEvent.showSnackBar('즐겨찾기에 추가했습니다.'),
        );
      }
      notifyListeners();
    } catch (_) {
      _eventController.add(
        const InformationEvent.showSnackBar('즐겨찾기 처리에 실패했습니다.'),
      );
    }
  }

  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }
}
