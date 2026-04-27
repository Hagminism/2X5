import 'package:capstone_2026/core/domain/model/user/user.dart';

abstract interface class UserRepository {
  Future<void> createUser(User user);
}