import 'package:capstone_2026/core/data/dto/user/user_dto.dart';
import 'package:capstone_2026/core/domain/model/enum/auth_provider.dart';
import 'package:capstone_2026/core/domain/model/enum/user_type.dart';
import 'package:capstone_2026/core/domain/model/user/user.dart';

extension UserDtoMapper on UserDto {
  User toModel() {
    return User(
      id: id ?? '',
      authProvider: buildAuthProvider(authProvider ?? ''),
      name: name ?? '',
      userType: (userType == 'customer') ? UserType.customer : UserType.partner,
      email: email ?? '',
      phone: phone ?? '',
      imageUrl: imageUrl ?? '',
    );
  }

  AuthProvider buildAuthProvider(String authProvider) {
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
    );
  }
}
