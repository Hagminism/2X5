import 'dart:async';

import 'package:capstone_2026/feature/stamp/domain/service/stamp_service.dart';
import 'package:capstone_2026/feature/store_detail/domain/repository/store_detail_repository.dart';
import 'package:capstone_2026/feature/store_detail/domain/service/store_review_service.dart';
import 'package:capstone_2026/feature/store_detail/presentation/component/review_write_bottom_sheet.dart';
import 'package:capstone_2026/feature/store_detail/presentation/screen/store_detail_action.dart';
import 'package:capstone_2026/feature/store_detail/presentation/screen/store_detail_event.dart';
import 'package:capstone_2026/feature/store_detail/presentation/screen/store_detail_state.dart';
import 'package:flutter/foundation.dart';

import 'package:capstone_2026/feature/store_detail/data/data_source/naver_store_search_data_source.dart';

const bool _allowReviewStampTestingBypass = bool.fromEnvironment(
  'ALLOW_REVIEW_STAMP_TEST_BYPASS',
  defaultValue: !kReleaseMode,
);

class StoreDetailViewModel extends ChangeNotifier {
  StoreDetailViewModel({
    required StoreDetailRepository storeDetailRepository,
    required StoreReviewService storeReviewService,
    required StampService stampService,
    required NaverStoreSearchDataSource naverStoreSearchDataSource,
  }) : _storeDetailRepository = storeDetailRepository,
       _storeReviewService = storeReviewService,
       _stampService = stampService,
       _naverStoreSearchDataSource = naverStoreSearchDataSource;

  final StoreDetailRepository _storeDetailRepository;
  final StoreReviewService _storeReviewService;
  final StampService _stampService;
  final NaverStoreSearchDataSource _naverStoreSearchDataSource;

  StoreDetailState _state = const StoreDetailState();
  String _currentStoreId = '';

  StoreDetailState get state => _state;

  final StreamController<StoreDetailEvent> _eventController =
      StreamController<StoreDetailEvent>();

  Stream<StoreDetailEvent> get eventStream => _eventController.stream;

  Future<void> initialize(String storeId) async {
    _currentStoreId = storeId;
    final storeDetail = _storeDetailRepository.getStoreDetailById(storeId);

    _state = state.copyWith(
      selectedTab: 0,
      isReviewLoading: true,
      isNaverDataLoading: storeDetail.naverPlaceId.isNotEmpty,
      reviews: const [],
      naverMenus: const [],
      naverReviews: const [],
      data: storeDetail,
    );
    notifyListeners();

    // 로컬 프록시 API 호출을 통한 실시간 네이버 데이터 병렬 로드
    Future<void> loadNaverData() async {
      if (storeDetail.naverPlaceId.isEmpty) return;
      try {
        final (menus, reviews) = await (
          _naverStoreSearchDataSource.fetchStoreMenus(placeId: storeDetail.naverPlaceId),
          _naverStoreSearchDataSource.fetchStoreReviews(placeId: storeDetail.naverPlaceId),
        ).wait;

        _state = state.copyWith(
          naverMenus: menus,
          naverReviews: reviews,
          isNaverDataLoading: false,
        );
        notifyListeners();
      } catch (e) {
        debugPrint('[StoreDetailViewModel] Failed to fetch Naver data: $e');
        _state = state.copyWith(isNaverDataLoading: false);
        notifyListeners();
      }
    }

    try {
      final (reviews, stampStatus, _) = await (
        _storeReviewService.loadStoreReviews(storeId: storeId),
        _stampService.loadStoreStampStatus(storeId: storeId),
        loadNaverData(),
      ).wait;

      _state = state.copyWith(
        isReviewLoading: false,
        reviews: reviews,
        stampStatus: stampStatus,
      );
      notifyListeners();
    } catch (_) {
      _state = state.copyWith(isReviewLoading: false, isNaverDataLoading: false);
      notifyListeners();
      _showSoonMessage('데이터를 불러오는 중 오류가 발생했습니다.');
    }
  }


  Future<void> submitReview(ReviewWriteResult review) async {
    final stampStatus = state.stampStatus;
    if (!_allowReviewStampTestingBypass &&
        stampStatus != null &&
        !stampStatus.canWriteReview) {
      _showSoonMessage(stampStatus.reviewEligibilityMessage);
      return;
    }

    try {
      final createdReview = await _storeReviewService.submitReview(
        storeId: _currentStoreId,
        storeName: state.data.name,
        review: review,
      );
      final updatedStampStatus = await _stampService.accrueStampForReview(
        storeId: _currentStoreId,
      );

      _state = state.copyWith(
        reviews: [createdReview, ...state.reviews],
        stampStatus: updatedStampStatus,
      );
      notifyListeners();

      final message = updatedStampStatus.isRewardUnlocked
          ? '리뷰가 등록되었습니다. 스탬프 적립이 완료되어 보상을 받을 수 있습니다.'
          : '리뷰가 등록되었습니다. 스탬프 1개가 적립되었습니다.';
      _showSoonMessage(message);
    } catch (_) {
      _showSoonMessage('리뷰 등록 중 오류가 발생했습니다.');
    }
  }

  void onAction(StoreDetailAction action) {
    switch (action) {
      case TapBack():
      case TapHome():
        break;
      case MoveTab():
        _moveTab(action.index);
        break;
      case TapSearch():
        _showSoonMessage('검색 기능은 준비 중입니다.');
        break;
      case TapBookmark():
        _showSoonMessage('저장 기능은 준비 중입니다.');
        break;
      case TapShare():
        _showSoonMessage('공유 기능은 준비 중입니다.');
        break;
      case TapCall():
        _showSoonMessage('전화 연결 기능은 준비 중입니다.');
        break;
      case TapReserve():
        _showSoonMessage('예약 버튼은 다음 단계에서 연결됩니다.');
        break;
      case TapNaverReviewButton():
        _openNaverReview();
        break;
      case TapGoogleReviewButton():
        _openGoogleReview();
        break;
    }
  }

  void _moveTab(int index) {
    if (state.selectedTab == index) return;

    _state = state.copyWith(selectedTab: index);
    notifyListeners();
  }

  void _showSoonMessage(String message) {
    _eventController.add(StoreDetailEvent.showMessage(message));
  }

  Future<void> _openNaverReview() async {
    final target = await _storeReviewService.getNaverReviewLinkTarget(
      storeName: state.data.name,
      location: state.data.location,
      placeId: state.data.naverPlaceId,
    );

    _eventController.add(
      StoreDetailEvent.openNaverReview(
        webUri: target.webUri,
        appUri: target.appUri,
      ),
    );
  }

  void _openGoogleReview() {
    final webUri = _storeReviewService.getGoogleMapSearchUri(
      state.data.googleSearchQuery,
    );
    _eventController.add(StoreDetailEvent.openGoogleMap(webUri));
  }

  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }
}
