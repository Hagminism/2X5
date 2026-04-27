import 'package:capstone_2026/core/data/dto/user/user_dto.dart';

abstract interface class UserDataSource {
  Future<UserDto> createUser(UserDto userDto);

  Future<UserDto?> findUserById(String id);
}