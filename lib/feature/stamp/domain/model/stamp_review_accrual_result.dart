import 'package:capstone_2026/feature/stamp/domain/model/store_stamp_status.dart';

class StampReviewAccrualResult {
  const StampReviewAccrualResult({
    required this.status,
    required this.didAccrue,
  });

  final StoreStampStatus status;
  final bool didAccrue;
}
