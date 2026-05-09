import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
      // 1. 홈 화면에서 받은 기본 데이터 먼저 세팅
      widget.viewModel.setInitialData(
        name: widget.name,
        subtitle: widget.subtitle,
        rating: widget.rating,
        category: widget.category,
      );

      // 2. ID를 이용해 DB에서 name, address 직접 조회
      widget.viewModel.fetchStoreDetails(widget.storeId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.viewModel,
      child: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          return InformationScreen(
            // DB에서 가져온 값이 있으면 그것을 사용, 없으면 홈에서 받은 값을 우선 사용
            name: widget.viewModel.name.isEmpty ? widget.name : widget.viewModel.name,
            subtitle: widget.viewModel.address.isEmpty ? widget.subtitle : widget.viewModel.address,
            rating: widget.viewModel.rating == 0.0 ? widget.rating : widget.viewModel.rating,
          );
        },
      ),
    );
  }
}