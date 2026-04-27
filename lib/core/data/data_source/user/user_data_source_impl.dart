import 'package:capstone_2026/core/data/data_source/user/user_data_source.dart';
import 'package:capstone_2026/core/data/dto/user/user_dto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserDataSourceImpl implements UserDataSource {
  final SupabaseClient _supabaseClient;

  UserDataSourceImpl({
    required SupabaseClient supabaseClient,
  }) : _supabaseClient = supabaseClient;

  @override
  Future<UserDto> createUser(UserDto userDto) async {
    final json = await _supabaseClient.from('users').upsert(userDto.toJson());

    return UserDto.fromJson(json);
  }

  @override
  Future<UserDto?> findUserById(String id) async {
    final json = await _supabaseClient
        .from('users')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (json == null) {
      return null;
    }

    return UserDto.fromJson(json);
  }
}
