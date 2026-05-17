import 'package:capstone_2026/di/di_setup.dart';
import 'package:capstone_2026/feature/stamp/domain/model/store_stamp_status.dart';
import 'package:capstone_2026/feature/stamp/domain/service/stamp_service.dart';
import 'package:capstone_2026/feature/store_detail/data/store_detail_data.dart';
import 'package:capstone_2026/feature/store_detail/domain/model/internal_review.dart';
import 'package:capstone_2026/feature/store_detail/domain/model/store_detail.dart';
import 'package:capstone_2026/feature/store_detail/domain/service/review_ai_summary_generator.dart';
import 'package:capstone_2026/feature/store_detail/domain/service/store_review_service.dart';
import 'package:capstone_2026/feature/store_detail/presentation/component/review_write_bottom_sheet.dart';
import 'package:capstone_2026/feature/store_detail/presentation/component/store_detail_review_section.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class StoreReviewTab extends StatefulWidget {
  const StoreReviewTab({
    required this.storeId,
    super.key,
  });

  final String storeId;

  @override
  State<StoreReviewTab> createState() => _StoreReviewTabState();
}

class _StoreReviewTabState extends State<StoreReviewTab> {
  bool _isLoading = true;
  List<InternalReview> _reviews = const [];
  StoreStampStatus? _stampStatus;

  StoreReviewService get _storeReviewService => getIt<StoreReviewService>();
  StampService get _stampService => getIt<StampService>();

  StoreDetail get _storeDetail =>
      storeDetailMockMap[widget.storeId] ?? defaultStoreDetail;

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
    final data = _storeDetail;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        StoreDetailReviewSection(
          storeName: data.name,
          location: data.location,
          naverPlaceId: data.naverPlaceId,
          googleSearchQuery: data.googleSearchQuery,
          stampStatus: _stampStatus,
          aiSummary: ReviewAiSummaryGenerator.generate(
            storeName: data.name,
            reviews: _reviews,
          ),
          reviews: _reviews,
          isReviewLoading: _isLoading,
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
    });

    try {
      final (reviews, stampStatus) = await (
        _storeReviewService.loadStoreReviews(storeId: widget.storeId),
        _stampService.loadStoreStampStatus(storeId: widget.storeId),
      ).wait;

      if (!mounted) {
        return;
      }

      setState(() {
        _reviews = reviews;
        _stampStatus = stampStatus;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
      });
      _showMessage('리뷰를 불러오는 중 오류가 발생했습니다.');
    }
  }

  Future<void> _submitReview(ReviewWriteResult result) async {
    final data = _storeDetail;

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
    final uri = _storeReviewService.getGoogleMapSearchUri(
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
