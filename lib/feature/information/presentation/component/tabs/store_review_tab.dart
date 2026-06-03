import 'package:capstone_2026/core/routing/routes.dart';
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
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:capstone_2026/feature/store_detail/data/data_source/naver_store_search_data_source.dart';
import 'package:capstone_2026/core/presentation/util/app_snack_bar.dart';

enum ReviewPlatform {
  internal,
  naver,
  google,
}

class StoreReviewTab extends StatefulWidget {
  const StoreReviewTab({
    required this.storeId,
    required this.storeName,
    required this.location,
    this.naverPlaceId,
    this.initialShowWriteReview = false,
    super.key,
  });

  final String storeId;
  final String storeName;
  final String location;
  final String? naverPlaceId;
  final bool initialShowWriteReview;

  @override
  State<StoreReviewTab> createState() => _StoreReviewTabState();
}

class _StoreReviewTabState extends State<StoreReviewTab> {
  ReviewPlatform _selectedPlatform = ReviewPlatform.internal;
  bool _isLoading = true;
  List<InternalReview> _reviews = const [];
  StoreStampStatus? _stampStatus;
  GooglePlaceReviewInfo? _googlePlaceReviewInfo;

  bool _isNaverLoading = false;
  List<Map<String, dynamic>> _naverReviews = const [];

  int _naverPage = 1;
  bool _hasMoreNaver = true;
  bool _isMoreNaverLoading = false;

  StoreReviewService get _storeReviewService => getIt<StoreReviewService>();
  StampService get _stampService => getIt<StampService>();
  NaverStoreSearchDataSource get _naverStoreSearchDataSource =>
      getIt<NaverStoreSearchDataSource>();

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
    _loadReviewData().then((_) {
      if (widget.initialShowWriteReview && mounted) {
        _showWriteReviewBottomSheetExternally();
      }
    });
  }

  void _showWriteReviewBottomSheetExternally() {
    if (!mounted) return;

    setState(() {
      _selectedPlatform = ReviewPlatform.internal;
    });

    final data = _reviewTarget;

    showModalBottomSheet<ReviewWriteResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => ReviewWriteBottomSheet(storeName: data.name),
    ).then((result) {
      if (result != null && mounted) {
        _submitReview(result);
      }
    });
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

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (_selectedPlatform == ReviewPlatform.naver) {
          final metrics = notification.metrics;
          final maxScroll = metrics.maxScrollExtent;
          final currentScroll = metrics.pixels;
          if (maxScroll - currentScroll <= 200) {
            _loadMoreNaverReviews();
          }
        }
        return false;
      },
      child: ListView(
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
              googleReviews: _googlePlaceReviewInfo?.reviews ?? const [],
            ),
            reviews: _reviews,
            isReviewLoading: _isLoading,
            naverReviews: _naverReviews,
            isNaverDataLoading: _isNaverLoading,
            selectedPlatform: _selectedPlatform,
            onPlatformChanged: (ReviewPlatform platform) {
              setState(() {
                _selectedPlatform = platform;
              });
            },
            googleReviews: _googlePlaceReviewInfo?.reviews ?? const [],
            onSubmitReview: _submitReview,
            onTapNaverReview: () => _openNaverReview(data),
            onTapGoogleReview: () => _openGoogleReview(data),
          ),
          if (_selectedPlatform == ReviewPlatform.naver && _isMoreNaverLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF03C75A)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _loadReviewData() async {
    setState(() {
      _isLoading = true;
      _isNaverLoading = true;
      _naverPage = 1;
      _hasMoreNaver = true;
      _isMoreNaverLoading = false;
    });

    try {
      final data = _reviewTarget;

      Future<List<Map<String, dynamic>>> loadNaverReviews() async {
        if (data.naverPlaceId.isEmpty) return const [];
        try {
          return await _naverStoreSearchDataSource.fetchStoreReviews(
            placeId: data.naverPlaceId,
          );
        } catch (_) {
          return const [];
        }
      }

      final (
        reviews,
        stampStatus,
        googlePlaceReviewInfo,
        naverReviews,
      ) = await (
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

  Future<void> _loadMoreNaverReviews() async {
    if (_isMoreNaverLoading || !_hasMoreNaver) return;

    setState(() {
      _isMoreNaverLoading = true;
    });

    try {
      final data = _reviewTarget;
      if (data.naverPlaceId.isEmpty) {
        setState(() {
          _hasMoreNaver = false;
          _isMoreNaverLoading = false;
        });
        return;
      }

      final nextPage = _naverPage + 1;
      final lastReview = _naverReviews.isNotEmpty ? _naverReviews.last : null;
      final afterCursor = lastReview?['cursor'] as String?;
      final newReviews = await _naverStoreSearchDataSource.fetchStoreReviews(
        placeId: data.naverPlaceId,
        page: nextPage,
        after: afterCursor,
      );

      if (!mounted) return;

      setState(() {
        if (newReviews.isEmpty) {
          _hasMoreNaver = false;
        } else {
          _naverReviews = [..._naverReviews, ...newReviews];
          _naverPage = nextPage;
          if (newReviews.length < 15) {
            _hasMoreNaver = false;
          }
        }
        _isMoreNaverLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isMoreNaverLoading = false;
      });
    }
  }

  Future<void> _submitReview(ReviewWriteResult result) async {
    final data = _reviewTarget;
    final wasRewardUnlocked = _stampStatus?.isRewardUnlocked ?? false;

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

      if (!wasRewardUnlocked && updatedStampStatus.isRewardUnlocked) {
        await _showRewardUnlockedDialog(updatedStampStatus);
        return;
      }

      _showMessage(
        '리뷰가 등록되었습니다. 스탬프 1개가 적립되었습니다.',
        variant: AppSnackBarVariant.success,
      );
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

  void _showMessage(
    String message, {
    AppSnackBarVariant variant = AppSnackBarVariant.error,
  }) {
    AppSnackBar.show(context, message, variant: variant);
  }

  Future<void> _showRewardUnlockedDialog(StoreStampStatus status) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('스탬프 보상 달성!'),
          content: Text(
            '${status.storeName}에서 ${status.goalCount}개의 스탬프를 모두 모았습니다.\n'
            '${status.rewardTitle} 보상을 확인해 보세요.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('닫기'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                if (!mounted) {
                  return;
                }
                context.push('${Routes.myPage}/${Routes.stampHistory}');
              },
              child: const Text('확인하러 가기'),
            ),
          ],
        );
      },
    );
  }
}
