import 'package:capstone_2026/core/domain/model/reservation/restaurant_time_slot.dart';
import 'package:capstone_2026/core/domain/model/salon/salon_designer.dart';
import 'package:capstone_2026/core/domain/model/store/store_menu.dart';
import 'package:capstone_2026/core/domain/model/store/store_layout_detail.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'information_state.freezed.dart';

@freezed
abstract class InformationState with _$InformationState {
  const factory InformationState({
    @Default('') String storeId,
    @Default('') String name,
    @Default('') String subtitle,
    @Default(0) double rating,
    @Default('') String category,
    @Default('') String address,
    @Default('') String displayPhone,
    @Default('') String storeDescription,
    @Default(<String, dynamic>{}) Map<String, dynamic> operatingHours,
    @Default(<StoreMenu>[]) List<StoreMenu> menus,
    @Default(<String>[]) List<String> imageUrls,
    String? imageUrl,
    @Default(false) bool isBookmarked,
    @Default(false) bool isLoading,
    @Default([]) List<SalonDesigner> salonDesigners,
    @Default([]) List<String> tabs,
    PageController? sliderController,
    @Default(0) int currentSliderPage,
    @Default('') String naverPlaceId,
    @Default(true) bool isReservationAvailable,
    StoreLayoutDetail? layoutDetail,
    @Default(false) bool isReservationAvailabilityLoading,
    DateTime? reservationAvailabilityDate,
    @Default([]) List<RestaurantTimeSlot> reservationAvailabilitySlots,
  }) = _InformationState;
}
