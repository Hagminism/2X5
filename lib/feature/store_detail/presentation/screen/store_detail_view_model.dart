import 'dart:async';

import 'package:capstone_2026/feature/store_detail/domain/repository/store_detail_repository.dart';
import 'package:capstone_2026/feature/store_detail/domain/repository/store_review_repository.dart';
import 'package:capstone_2026/feature/store_detail/presentation/component/review_write_bottom_sheet.dart';
import 'package:capstone_2026/feature/store_detail/presentation/screen/store_detail_action.dart';
import 'package:capstone_2026/feature/store_detail/presentation/screen/store_detail_event.dart';
import 'package:capstone_2026/feature/store_detail/presentation/screen/store_detail_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StoreDetailViewModel extends ChangeNotifier {
  final StoreDetailRepository _storeDetailRepository;
  final StoreReviewRepository _storeReviewRepository;

  StoreDetailViewModel({
    required StoreDetailRepository storeDetailRepository,
    required StoreReviewRepository storeReviewRepository,
  }) : _storeDetailRepository = storeDetailRepository,
       _storeReviewRepository = storeReviewRepository;

  StoreDetailState _state = const StoreDetailState();
  String _currentStoreId = '';

  StoreDetailState get state => _state;

  final StreamController<StoreDetailEvent> _eventController =
      StreamController<StoreDetailEvent>();

  Stream<StoreDetailEvent> get eventStream => _eventController.stream;

  Future<void> initialize(String storeId) async {
    _currentStoreId = storeId;
    _state = state.copyWith(
      selectedTab: 0,
      isReviewLoading: true,
      reviews: const [],
      data: _storeDetailRepository.getStoreDetailById(storeId),
    );
    notifyListeners();

    final reviews = await _storeReviewRepository.fetchStoreReviews(
      storeId: storeId,
    );

    _state = state.copyWith(
      isReviewLoading: false,
      reviews: reviews,
    );
    notifyListeners();
  }

  Future<void> submitReview(ReviewWriteResult review) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final userId = currentUser?.uid ?? 'mock-user';
    final userName =
        currentUser?.displayName?.trim().isNotEmpty == true
        ? currentUser!.displayName!.trim()
        : currentUser?.email?.split('@').first ?? '방문자';

    final createdReview = await _storeReviewRepository.submitReview(
      storeId: _currentStoreId,
      storeName: state.data.name,
      userId: userId,
      userName: userName,
      review: review,
    );

    _state = state.copyWith(
      reviews: [createdReview, ...state.reviews],
    );
    notifyListeners();

    _showSoonMessage('리뷰가 등록되었습니다.');
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
        _showSoonMessage('예약 바텀시트는 다음 단계에서 연결됩니다.');
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
    final target = await _storeReviewRepository.getNaverReviewLinkTarget(
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
    final webUri = _storeReviewRepository.getGoogleMapSearchUri(
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
