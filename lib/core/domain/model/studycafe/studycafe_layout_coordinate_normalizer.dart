import 'package:capstone_2026/core/domain/model/studycafe/studycafe_detail.dart';
import 'package:capstone_2026/core/domain/model/studycafe/studycafe_layout_element.dart';
import 'package:capstone_2026/core/domain/model/studycafe/studycafe_seat.dart';

/// 좌석·구조물 좌표는 **캔버스 가로·세로에 대한 비율(0.0–1.0)** 로 저장한다.
/// UI에서는 캔버스의 실제 픽셀 크기를 정한 뒤 이 비율을 곱해 배치하면
/// 기기 화면 너비에 맞게 일관되게 스케일된다.
///
/// 과거에 고정 픽셀 좌표로 저장된 데이터는 `x` 또는 `y`가 1을 초과하는 경우로
/// 감지해, 당시 편집기 기준 크기로 나눠 비율 좌표로 바꾼다.
abstract final class StudyCafeLayoutCoordinateNormalizer {
  static const double _pixelReferenceWidth = 400;
  static const double _pixelReferenceHeight = 650;

  static StudyCafeDetail normalizeDetail(StudyCafeDetail detail) {
    return detail.copyWith(
      seats: normalizeSeats(detail.seats),
      elements: normalizeElements(detail.elements),
    );
  }

  static List<StudyCafeSeat> normalizeSeats(List<StudyCafeSeat> seats) {
    return seats.map((StudyCafeSeat seat) {
      final shouldConvertFromPixelSpace = seat.x > 1 || seat.y > 1;
      if (shouldConvertFromPixelSpace) {
        return seat.copyWith(
          x: (seat.x / _pixelReferenceWidth).clamp(0, 1).toDouble(),
          y: (seat.y / _pixelReferenceHeight).clamp(0, 1).toDouble(),
        );
      }
      return seat.copyWith(
        x: seat.x.clamp(0, 1).toDouble(),
        y: seat.y.clamp(0, 1).toDouble(),
      );
    }).toList();
  }

  static List<StudyCafeLayoutElement> normalizeElements(
    List<StudyCafeLayoutElement> elements,
  ) {
    return elements.map((StudyCafeLayoutElement element) {
      final shouldConvertFromPixelSpace = element.x > 1 || element.y > 1;
      final x = shouldConvertFromPixelSpace
          ? element.x / _pixelReferenceWidth
          : element.x;
      final y = shouldConvertFromPixelSpace
          ? element.y / _pixelReferenceHeight
          : element.y;
      return element.copyWith(
        x: x.clamp(0, 1).toDouble(),
        y: y.clamp(0, 1).toDouble(),
        width: element.width.clamp(0.03, 1).toDouble(),
        height: element.height.clamp(0.02, 1).toDouble(),
      );
    }).toList();
  }
}
