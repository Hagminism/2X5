import 'package:capstone_2026/ui/app_colors.dart';
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
          if (widget.viewModel.isLoading) {
            return Scaffold(
              backgroundColor: AppColors.surface,
              body: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            );
          }

          return InformationScreen(
            storeId: widget.storeId,
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