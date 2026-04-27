import 'package:capstone_2026/core/data/data_source/user/user_data_source.dart';
import 'package:capstone_2026/core/data/dto/user/user_dto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserDataSourceImpl implements UserDataSource {
  final SupabaseClient _supabaseClient;

  UserDataSourceImpl({
    required SupabaseClient supabaseClient,
  }) : _supabaseClient = supabaseClient;

  @override
  Future<void> createUser(UserDto userDto) async {
    // TODO: 임시 구현, 에러 핸들링 등 추가해야됨.
    await _supabaseClient.from('users').upsert(userDto.toJson());
  }
}
