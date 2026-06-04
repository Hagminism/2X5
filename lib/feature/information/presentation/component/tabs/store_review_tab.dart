import 'dart:async';

import 'package:capstone_2026/core/presentation/component/dialog/app_info_dialog.dart';
import 'package:capstone_2026/core/routing/routes.dart';
import 'package:capstone_2026/di/di_setup.dart';
import 'package:capstone_2026/feature/stamp/domain/model/store_stamp_status.dart';
import 'package:capstone_2026/feature/stamp/domain/service/stamp_service.dart';
import 'package:capstone_2026/feature/store_detail/data/store_detail_data.dart';
import 'package:capstone_2026/feature/store_detail/domain/model/google_place_review_info.dart';
import 'package:capstone_2026/feature/store_detail/domain/model/internal_review.dart';
import 'package:capstone_2026/feature/store_detail/domain/model/review_ai_summary.dart';
import 'package:capstone_2026/feature/store_detail/domain/model/store_detail.dart';
import 'package:capstone_2026/feature/store_detail/domain/service/store_review_service.dart';
import 'package:capstone_2026/feature/store_detail/domain/service/store_review_summary_service.dart';
import 'package:capstone_2026/feature/store_detail/presentation/component/review_write_bottom_sheet.dart';
import 'package:capstone_2026/feature/store_detail/presentation/component/store_detail_review_section.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:capstone_2026/feature/store_detail/data/data_source/naver_store_search_data_source.dart';
import 'package:capstone_2026/core/presentation/util/app_snack_bar.dart';
import 'package:capstone_2026/core/presentation/util/review_submit_error_message.dart';
import 'package:capstone_2026/core/presentation/util/review_submit_loading.dart';

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
    required this.reviewTabIndex,
    this.naverPlaceId,
    this.initialShowWriteReview = false,
    this.isTabActive,
    this.shrinkWrapList = false,
    super.key,
  });

  final String storeId;
  final String storeName;
  final String location;
  final int reviewTabIndex;
  final String? naverPlaceId;
  final bool initialShowWriteReview;

  /// [DefaultTabController] 미사용 화면(북마크 상세 등)에서 현재 리뷰 탭 선택 여부.
  final bool? isTabActive;

  /// Column 안에 넣을 때 ListView shrinkWrap.
  final bool shrinkWrapList;

  @override
  State<StoreReviewTab> createState() => _StoreReviewTabState();
}

class _StoreReviewTabState extends State<StoreReviewTab>
    with AutomaticKeepAliveClientMixin {
  ReviewPlatform _selectedPlatform = ReviewPlatform.internal;
  bool _isLoading = false;
  List<InternalReview> _reviews = const [];
  StoreStampStatus? _stampStatus;
  GooglePlaceReviewInfo? _googlePlaceReviewInfo;

  bool _isNaverLoading = false;
  List<Map<String, dynamic>> _naverReviews = const [];

  int _naverPage = 1;
  bool _hasMoreNaver = true;
  bool _isMoreNaverLoading = false;

  ReviewAiSummary? _aiSummary;
  bool _isSummaryLoading = false;
  String? _summaryError;

  bool _reviewSessionStarted = false;
  bool _summaryRequested = false;
  TabController? _tabController;
  bool _tabListenerAttached = false;

  StoreReviewService get _storeReviewService => getIt<StoreReviewService>();

  StoreReviewSummaryService get _storeReviewSummaryService =>
      getIt<StoreReviewSummaryService>();

  StampService get _stampService => getIt<StampService>();

  NaverStoreSearchDataSource get _naverStoreSearchDataSource =>
      getIt<NaverStoreSearchDataSource>();

  @override
  bool get wantKeepAlive => true;

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
    if (widget.isTabActive == true) {
      _ensureReviewSessionStarted();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.isTabActive != null) {
      return;
    }

    final controller = DefaultTabController.maybeOf(context);
    if (controller == null || identical(_tabController, controller)) {
      return;
    }

    _tabController?.removeListener(_onTabControllerChanged);
    _tabController = controller;
    if (!_tabListenerAttached) {
      controller.addListener(_onTabControllerChanged);
      _tabListenerAttached = true;
    }

    if (_isReviewTabActive) {
      _ensureReviewSessionStarted();
    }
  }

  @override
  void didUpdateWidget(covariant StoreReviewTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.storeId != widget.storeId) {
      _resetReviewSession();
      if (_isReviewTabActive) {
        _ensureReviewSessionStarted();
      }
      return;
    }

    if (widget.isTabActive == true && !_reviewSessionStarted) {
      _ensureReviewSessionStarted();
    }
  }

  @override
  void dispose() {
    _tabController?.removeListener(_onTabControllerChanged);
    super.dispose();
  }

  bool get _isReviewTabActive {
    final external = widget.isTabActive;
    if (external != null) {
      return external;
    }
    final controller = _tabController ?? DefaultTabController.maybeOf(context);
    if (controller == null) {
      return false;
    }
    return controller.index == widget.reviewTabIndex;
  }

  void _onTabControllerChanged() {
    if (_isReviewTabActive) {
      _ensureReviewSessionStarted();
    }
  }

  void _resetReviewSession() {
    _reviewSessionStarted = false;
    _summaryRequested = false;
    _reviews = const [];
    _stampStatus = null;
    _googlePlaceReviewInfo = null;
    _naverReviews = const [];
    _aiSummary = null;
    _summaryError = null;
    _isLoading = false;
    _isNaverLoading = false;
    _isSummaryLoading = false;
    _naverPage = 1;
    _hasMoreNaver = true;
    _isMoreNaverLoading = false;
  }

  void _ensureReviewSessionStarted() {
    if (_reviewSessionStarted) {
      return;
    }
    _reviewSessionStarted = true;
    unawaited(
      _loadReviewData().then((_) {
        if (widget.initialShowWriteReview && mounted) {
          _showWriteReviewBottomSheetExternally();
        }
      }),
    );
  }

  void _showWriteReviewBottomSheetExternally() {
    if (!mounted) {
      return;
    }

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
    ).then((result) async {
      if (result != null && mounted) {
        await runWithReviewSubmitLoading(
          context,
          () => _submitReview(result),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
        shrinkWrap: widget.shrinkWrapList,
        physics: widget.shrinkWrapList
            ? const ClampingScrollPhysics()
            : null,
        padding: const EdgeInsets.all(20),
        children: [
          StoreDetailReviewSection(
            storeName: data.name,
            location: data.location,
            naverPlaceId: data.naverPlaceId,
            googleSearchQuery: data.googleSearchQuery,
            stampStatus: _stampStatus,
            aiSummary: _aiSummary,
            isSummaryLoading: _isSummaryLoading,
            summaryError: _summaryError,
            onRetrySummary:
                _summaryError != null ? () => unawaited(_retrySummary()) : null,
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
        if (data.naverPlaceId.isEmpty) {
          return const [];
        }
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
        _storeReviewSummaryService.loadPlatformReviewsForSummary(
          storeId: widget.storeId,
        ),
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

      await _loadAiSummaryOnce();
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

  Future<void> _loadAiSummaryOnce() async {
    if (_summaryRequested) {
      return;
    }
    _summaryRequested = true;

    if (!mounted) {
      return;
    }

    setState(() {
      _isSummaryLoading = true;
      _summaryError = null;
    });

    try {
      final summary = await _storeReviewSummaryService.summarize(
        storeId: widget.storeId,
        storeName: _reviewTarget.name,
        platformReviews: _reviews,
        naverReviews: _naverReviews,
        googleReviews: _googlePlaceReviewInfo?.reviews ?? const [],
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _aiSummary = summary;
        _isSummaryLoading = false;
      });
    } on FirebaseFunctionsException catch (e, stackTrace) {
      debugPrint(
        '[ReviewSummary] callable failed: code=${e.code}, '
        'message=${e.message}, details=${e.details}',
      );
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) {
        return;
      }

      setState(() {
        _isSummaryLoading = false;
        _summaryError = '리뷰 요약을 불러오지 못했습니다.';
      });
    } catch (e, stackTrace) {
      debugPrint('[ReviewSummary] failed: $e');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) {
        return;
      }

      setState(() {
        _isSummaryLoading = false;
        _summaryError = '리뷰 요약을 불러오지 못했습니다.';
      });
    }
  }

  Future<void> _retrySummary() async {
    _summaryRequested = false;
    await _loadAiSummaryOnce();
  }

  Future<void> _loadMoreNaverReviews() async {
    if (_isMoreNaverLoading || !_hasMoreNaver) {
      return;
    }

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

      if (!mounted) {
        return;
      }

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
      if (!mounted) {
        return;
      }
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
      final accrual = await _stampService.accrueStampForReview(
        storeId: widget.storeId,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _reviews = [createdReview, ..._reviews];
        _stampStatus = accrual.status;
      });

      try {
        await _storeReviewSummaryService.invalidateSummary(
          storeId: widget.storeId,
        );
      } catch (_) {}

      if (accrual.didAccrue &&
          !wasRewardUnlocked &&
          accrual.status.isRewardUnlocked) {
        await _showRewardUnlockedDialog(accrual.status);
        return;
      }

      final message = accrual.didAccrue
          ? '리뷰가 등록되었습니다. 스탬프 1개가 적립되었습니다.'
          : '리뷰가 등록되었습니다.';

      _showMessage(
        message,
        variant: AppSnackBarVariant.success,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(reviewSubmitErrorMessage(error));
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
    await showAppInfoDialog(
      context,
      title: '스탬프 보상 달성!',
      message:
          '${status.storeName}에서 ${status.goalCount}개의 스탬프를 모두 모았습니다.\n'
          '${status.rewardTitle} 보상을 확인해 보세요.',
      closeLabel: '닫기',
      ctaLabel: '확인하러 가기',
      onCtaPressed: () {
        if (!mounted) {
          return;
        }
        context.push('${Routes.myPage}/${Routes.stampHistory}');
      },
    );
  }
}
