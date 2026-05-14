import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 1. Provider 임포트 추가
import 'information_screen.dart';
import 'information_view_model.dart';

class InformationScreenRoot extends StatefulWidget {
  final InformationViewModel viewModel;
  final String storeId;
  final String name;
  final String subtitle;
  final double rating;
  final String category;

  const InformationScreenRoot({
    super.key,
    required this.viewModel,
    required this.storeId,
    required this.name,
    required this.subtitle,
    required this.rating,
    required this.category,
  });

  @override
  State<InformationScreenRoot> createState() => _InformationScreenRootState();
}

class _InformationScreenRootState extends State<InformationScreenRoot> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.viewModel.setInitialData(
        name: widget.name,
        subtitle: widget.subtitle,
        rating: widget.rating,
        category: widget.category,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // 2. ChangeNotifierProvider.value를 사용하여 하위 위젯들에게 뷰모델을 주입합니다.
    return ChangeNotifierProvider.value(
      value: widget.viewModel,
      child: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          return InformationScreen(
            storeId: widget.storeId,
            name: widget.viewModel.name.isEmpty ? widget.name : widget.viewModel.name,
            subtitle: widget.viewModel.subtitle.isEmpty ? widget.subtitle : widget.viewModel.subtitle,
            rating: widget.viewModel.rating == 0.0 ? widget.rating : widget.viewModel.rating,
          );
        },
      ),
    );
  }
}
