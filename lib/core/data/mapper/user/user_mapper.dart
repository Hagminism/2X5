import 'package:capstone_2026/core/data/dto/user/user_dto.dart';
import 'package:capstone_2026/core/domain/model/enum/user_type.dart';
import 'package:capstone_2026/core/domain/model/user/user.dart';

extension UserDtoMapper on UserDto {
  User toModel() {
    return User(
      id: id!,
      name: name!,
      userType: (userType == 'customer') ? UserType.customer : UserType.partner,
      email: email!,
      phone: phone!,
      imageUrl: imageUrl!,
    );
  }
}

extension UserToDtoMapper on User {
  UserDto toDto() {
    return UserDto(
      id: id,
      name: name,
      userType: userType.name,
      email: email,
      phone: phone,
      imageUrl: imageUrl,
    );
  }
}
