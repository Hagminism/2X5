import 'package:capstone_2026/core/data/data_source/user/user_data_source.dart';
import 'package:capstone_2026/core/data/mapper/user/user_mapper.dart';
import 'package:capstone_2026/core/domain/model/user/user.dart';
import 'package:capstone_2026/core/domain/repository/user/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final UserDataSource _userDataSource;

  const UserRepositoryImpl({
    required UserDataSource userDataSource,
  }) : _userDataSource = userDataSource;

  @override
  Future<void> createUser(User user) async {
    await _userDataSource.createUser(user.toDto());
  }
}
