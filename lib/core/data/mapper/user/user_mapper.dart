import 'package:capstone_2026/core/data/dto/user/user_dto.dart';
import 'package:capstone_2026/core/domain/model/enum/auth_provider.dart';
import 'package:capstone_2026/core/domain/model/enum/partner_status.dart';
import 'package:capstone_2026/core/domain/model/enum/user_type.dart';
import 'package:capstone_2026/core/domain/model/user/user.dart';

extension UserDtoMapper on UserDto {
  User toModel() {
    return User(
      id: id ?? '',
      authProvider: _parseAuthProvider(authProvider ?? ''),
      name: name ?? '',
      userType: _parseUserType(userType),
      email: email ?? '',
      phone: phone ?? '',
      imageUrl: imageUrl ?? '',
      partnerStatus: _parsePartnerStatus(partnerStatus),
    );
  }

  UserType _parseUserType(String? userType) {
    return (userType == 'customer') ? UserType.customer : UserType.partner;
  }

  PartnerStatus? _parsePartnerStatus(String? partnerStatus) {
    if (partnerStatus == null || partnerStatus.isEmpty) {
      return null;
    }

    switch (partnerStatus) {
      case 'unverified':
        return PartnerStatus.unverified;
      case 'pending':
        return PartnerStatus.pending;
      case 'approved':
        return PartnerStatus.approved;
      case 'rejected':
        return PartnerStatus.rejected;
      default:
        return null;
    }
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
      partnerStatus: partnerStatus?.name,
      email: email,
      phone: phone,
      imageUrl: imageUrl,
    );
  }
}
