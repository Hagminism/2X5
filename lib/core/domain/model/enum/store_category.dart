enum StoreCategory {
  restaurant,
  cafe,
  studyCafe,
  salon
  ;

  String get dbValue => switch (this) {
    StoreCategory.restaurant => 'restaurant',
    StoreCategory.cafe => 'cafe',
    StoreCategory.studyCafe => 'study_cafe',
    StoreCategory.salon => 'salon',
  };

  String get displayName => switch (this) {
    StoreCategory.restaurant => '식당',
    StoreCategory.cafe => '카페',
    StoreCategory.studyCafe => '스터디카페',
    StoreCategory.salon => '미용실',
  };

  static StoreCategory? fromDbValue(String value) {
    for (final category in StoreCategory.values) {
      if (category.dbValue == value) {
        return category;
      }
    }
    return null;
  }
}
