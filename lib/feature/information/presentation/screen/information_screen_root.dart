import 'package:flutter/material.dart';
import 'information_screen.dart';
import 'information_view_model.dart';

class InformationScreenRoot extends StatefulWidget {
  final InformationViewModel viewModel;
  final String storeId;
  final String name;
  final String subtitle;
  final double rating;

  const InformationScreenRoot({
    super.key,
    required this.viewModel,
    required this.storeId,
    required this.name,
    required this.subtitle,
    required this.rating,
  });

  @override
  State<InformationScreenRoot> createState() => _InformationScreenRootState();
}

class _InformationScreenRootState extends State<InformationScreenRoot> {
  @override
  void initState() {
    super.initState();
    // 화면이 생성될 때 뷰모델에 데이터를 딱 한 번만 전달합니다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.viewModel.setInitialData(
        name: widget.name,
        subtitle: widget.subtitle,
        rating: widget.rating,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        return InformationScreen(
          name: widget.viewModel.name,      // 뷰모델의 데이터를 직접 전달
          subtitle: widget.viewModel.subtitle,
          rating: widget.viewModel.rating,
        );
      },
    );
  }
}