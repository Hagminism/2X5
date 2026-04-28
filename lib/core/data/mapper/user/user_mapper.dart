import 'package:capstone_2026/core/data/dto/user/user_dto.dart';
import 'package:capstone_2026/core/domain/model/enum/auth_provider.dart';
import 'package:capstone_2026/core/domain/model/enum/user_type.dart';
import 'package:capstone_2026/core/domain/model/user/user.dart';

extension UserDtoMapper on UserDto {
  User toModel() {
    return User(
      id: id ?? '',
      authProvider: _parseAuthProvider(authProvider ?? ''),
      name: name ?? '',
      userType: (userType == 'customer') ? UserType.customer : UserType.partner,
      email: email ?? '',
      phone: phone ?? '',
      imageUrl: imageUrl ?? '',
      openingDate: _parseOpeningDate(openingDate),
      businessNumber: businessNumber,
    );
  }

  DateTime? _parseOpeningDate(String? dateText) {
    if (dateText == null || dateText.isEmpty) {
      return null;
    }
    return DateTime.tryParse(dateText);
  }

  AuthProvider _parseAuthProvider(String authProvider) {
    AuthProvider result = AuthProvider.email;

    switch (authProvider) {
      case 'password':
        result = AuthProvider.email;
        break;
      case 'google.com':
        result = AuthProvider.google;
        break;
      case 'oidc.naver':
        result = AuthProvider.naver;
        break;
      case 'oidc.kakao':
        result = AuthProvider.kakao;
        break;
    }

    return result;
  }
}

extension UserToDtoMapper on User {
  UserDto toDto() {
    return UserDto(
      id: id,
      authProvider: authProvider.name,
      name: name,
      userType: userType.name,
      email: email,
      phone: phone,
      imageUrl: imageUrl,
      openingDate: _formatDateOnly(openingDate),
      businessNumber: businessNumber,
    );
  }

  String? _formatDateOnly(DateTime? date) {
    if (date == null) {
      return null;
    }
    final normalized = DateTime(date.year, date.month, date.day);
    final year = normalized.year.toString().padLeft(4, '0');
    final month = normalized.month.toString().padLeft(2, '0');
    final day = normalized.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
