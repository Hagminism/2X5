import 'package:capstone_2026/di/di_setup.dart';
import 'package:capstone_2026/feature/stamp/domain/model/store_stamp_status.dart';
import 'package:capstone_2026/feature/stamp/domain/service/stamp_service.dart';
import 'package:capstone_2026/feature/store_detail/data/store_detail_data.dart';
import 'package:capstone_2026/feature/store_detail/domain/model/google_place_review_info.dart';
import 'package:capstone_2026/feature/store_detail/domain/model/internal_review.dart';
import 'package:capstone_2026/feature/store_detail/domain/model/store_detail.dart';
import 'package:capstone_2026/feature/store_detail/domain/service/review_ai_summary_generator.dart';
import 'package:capstone_2026/feature/store_detail/domain/service/store_review_service.dart';
import 'package:capstone_2026/feature/store_detail/presentation/component/review_write_bottom_sheet.dart';
import 'package:capstone_2026/feature/store_detail/presentation/component/store_detail_review_section.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:capstone_2026/feature/store_detail/data/data_source/naver_store_search_data_source.dart';

class StoreReviewTab extends StatefulWidget {
  const StoreReviewTab({
    required this.storeId,
    required this.storeName,
    required this.location,
    this.naverPlaceId,
    super.key,
  });

  final String storeId;
  final String storeName;
  final String location;
  final String? naverPlaceId;

  @override
  State<StoreReviewTab> createState() => _StoreReviewTabState();
}

class _StoreReviewTabState extends State<StoreReviewTab> {
  bool _isLoading = true;
  List<InternalReview> _reviews = const [];
  StoreStampStatus? _stampStatus;
  GooglePlaceReviewInfo? _googlePlaceReviewInfo;

  bool _isNaverLoading = false;
  List<Map<String, dynamic>> _naverReviews = const [];

  StoreReviewService get _storeReviewService => getIt<StoreReviewService>();
  StampService get _stampService => getIt<StampService>();
  NaverStoreSearchDataSource get _naverStoreSearchDataSource => getIt<NaverStoreSearchDataSource>();

  StoreDetail get _reviewTarget {
    final mockDetail = storeDetailMockMap[widget.storeId];
    if (mockDetail != null) {
      return mockDetail;
    }

    final storeName = widget.storeName.trim();
    final location = widget.location.trim();
    final query = [
      storeName,
      location,
    ].where((value) => value.isNotEmpty).join(' ');

    return defaultStoreDetail.copyWith(
      name: storeName.isEmpty ? defaultStoreDetail.name : storeName,
      location: location.isEmpty ? defaultStoreDetail.location : location,
      naverPlaceId: widget.naverPlaceId?.trim() ?? '',
      googleSearchQuery: query.isEmpty ? storeName : query,
    );
  }

  @override
  void initState() {
    super.initState();
    _loadReviewData();
  }

  @override
  void didUpdateWidget(covariant StoreReviewTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.storeId != widget.storeId) {
      _loadReviewData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = _reviewTarget;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        StoreDetailReviewSection(
          storeName: data.name,
          location: data.location,
          naverPlaceId: data.naverPlaceId,
          googleSearchQuery: data.googleSearchQuery,
          stampStatus: _stampStatus,
          googlePlaceReviewInfo: _googlePlaceReviewInfo,
          aiSummary: ReviewAiSummaryGenerator.generate(
            storeName: data.name,
            reviews: _reviews,
          ),
          reviews: _reviews,
          isReviewLoading: _isLoading,
          naverReviews: _naverReviews,
          isNaverDataLoading: _isNaverLoading,
          onSubmitReview: _submitReview,
          onTapNaverReview: () => _openNaverReview(data),
          onTapGoogleReview: () => _openGoogleReview(data),
        ),
      ],
    );
  }

  Future<void> _loadReviewData() async {
    setState(() {
      _isLoading = true;
      _isNaverLoading = true;
    });

    try {
      final data = _reviewTarget;

      Future<List<Map<String, dynamic>>> loadNaverReviews() async {
        if (data.naverPlaceId.isEmpty) return const [];
        try {
          return await _naverStoreSearchDataSource.fetchStoreReviews(placeId: data.naverPlaceId);
        } catch (_) {
          return const [];
        }
      }

      final (reviews, stampStatus, googlePlaceReviewInfo, naverReviews) = await (
        _storeReviewService.loadStoreReviews(storeId: widget.storeId),
        _stampService.loadStoreStampStatus(storeId: widget.storeId),
        _storeReviewService.fetchGooglePlaceReviewInfo(
          storeName: data.name,
          location: data.location,
        ),
        loadNaverReviews(),
      ).wait;

      if (!mounted) {
        return;
      }

      setState(() {
        _reviews = reviews;
        _stampStatus = stampStatus;
        _googlePlaceReviewInfo = googlePlaceReviewInfo;
        _naverReviews = naverReviews;
        _isLoading = false;
        _isNaverLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _isNaverLoading = false;
      });
      _showMessage('리뷰를 불러오는 중 오류가 발생했습니다.');
    }
  }

  Future<void> _submitReview(ReviewWriteResult result) async {
    final data = _reviewTarget;

    try {
      final createdReview = await _storeReviewService.submitReview(
        storeId: widget.storeId,
        storeName: data.name,
        review: result,
      );
      final updatedStampStatus = await _stampService.accrueStampForReview(
        storeId: widget.storeId,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _reviews = [createdReview, ..._reviews];
        _stampStatus = updatedStampStatus;
      });

      final message = updatedStampStatus.isRewardUnlocked
          ? '리뷰가 등록되었습니다. 스탬프 적립이 완료되어 보상을 받을 수 있습니다.'
          : '리뷰가 등록되었습니다. 스탬프 1개가 적립되었습니다.';
      _showMessage(message);
    } catch (_) {
      if (!mounted) {
        return;
      }

      _showMessage('리뷰 등록 중 오류가 발생했습니다.');
    }
  }

  Future<void> _openNaverReview(StoreDetail data) async {
    final target = await _storeReviewService.getNaverReviewLinkTarget(
      storeName: data.name,
      location: data.location,
      placeId: data.naverPlaceId,
    );

    try {
      if (target.appUri != null && await canLaunchUrl(Uri.parse('nmap://'))) {
        await launchUrl(target.appUri!, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(target.webUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showMessage('외부 리뷰 페이지를 열 수 없습니다.');
    }
  }

  Future<void> _openGoogleReview(StoreDetail data) async {
    final uri =
        _googlePlaceReviewInfo?.googleMapsUri ??
        _storeReviewService.getGoogleMapSearchUri(
          data.googleSearchQuery,
        );

    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showMessage('외부 리뷰 페이지를 열 수 없습니다.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
