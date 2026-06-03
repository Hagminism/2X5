import 'package:capstone_2026/core/data/data_source/review/review_image_data_source_impl.dart';

String reviewSubmitErrorMessage(Object error) {
  if (error is ReviewImageUploadException) {
    return error.message;
  }

  if (error is StateError) {
    final message = error.message;
    if (message != null && message.isNotEmpty) {
      return message;
    }
  }

  return '리뷰 등록 중 오류가 발생했습니다.';
}
