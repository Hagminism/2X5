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
    return InformationScreen(
      storeId: storeId,
      name: "가게 ID: $storeId",
      subtitle: "상세 정보를 불러오는 중입니다...",
      rating: 4.5,
    );
  }
}