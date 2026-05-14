import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'information_screen.dart';
import 'information_view_model.dart';

class InformationScreenRoot extends StatefulWidget {
  final InformationViewModel viewModel;
  final String storeId;

  const InformationScreenRoot({
    super.key,
    required this.viewModel,
    required this.storeId,
  });

  @override
  State<InformationScreenRoot> createState() => _InformationScreenRootState();
}

class _InformationScreenRootState extends State<InformationScreenRoot> {
  @override
  void initState() {
    super.initState();
    // 화면 진입 시 즉시 DB 조회를 시작합니다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
          // 데이터 로딩 중일 때는 로딩 바를 표시합니다.
          if (widget.viewModel.isLoading) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: Color(0xFFFF3D00)),
              ),
            );
          }

          // 조회가 완료되면 뷰모델의 순수 DB 데이터만 사용하여 화면을 그립니다.
          return InformationScreen(
            name: widget.viewModel.name,
            subtitle: widget.viewModel.categorySubtitleLabel,
            address: widget.viewModel.address,
            displayPhone: widget.viewModel.displayPhone,
            rating: widget.viewModel.rating,
            imageUrls: widget.viewModel.imageUrls,
            menus: widget.viewModel.menus,
          );
        },
      ),
    );
  }
}