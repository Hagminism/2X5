import 'package:flutter/material.dart';
import 'information_screen.dart';
import 'information_view_model.dart';

class InformationScreenRoot extends StatelessWidget {
  final InformationViewModel viewModel;
  final String storeId;

  const InformationScreenRoot({
    super.key,
    required this.viewModel,
    required this.storeId,
  });

  @override
  Widget build(BuildContext context) {
    // 현재는 ViewModel을 사용하지 않으므로 기존 InformationScreen만 리턴합니다.
    // 나중에 데이터 연동이 필요하면 여기서 ListenableBuilder 등을 사용하면 됩니다.
    return const InformationScreen(
      name: "가게 이름", // 임시 데이터
      subtitle: "가게 설명",
      rating: 4.5,
    );
  }
}