import 'package:capstone_2026/core/data/dto/user/user_dto.dart';

abstract interface class UserDataSource {
  Future<void> createUser(UserDto userDto);
}