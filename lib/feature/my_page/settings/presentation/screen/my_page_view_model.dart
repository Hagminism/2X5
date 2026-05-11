import 'package:capstone_2026/core/domain/repository/auth/auth_repository.dart';
import 'package:capstone_2026/feature/my_page/settings/presentation/screen/my_page_state.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyPageViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  MyPageViewModel({
    required AuthRepository authRepository,
  }) : _authRepository = authRepository;

  MyPageState _state = MyPageState();

  MyPageState get state => _state;

  Future<void> fetchProfile() async {
    if (state.isLoading) return;

    _state = state.copyWith(isLoading: true);
    notifyListeners();

    final user = _authRepository.getCurrentUser();

    String? imageUrl;
    try {
      final uid = user?.uid;
      if (uid != null) {
        final response = await Supabase.instance.client
            .from('users')
            .select('image_url')
            .eq('id', uid)
            .maybeSingle();
        final raw = response?['image_url'] as String?;
        imageUrl = (raw != null && raw.isNotEmpty) ? raw : null;
      }
    } catch (_) {
      // Supabase 조회 실패 시 Firebase photoURL 사용
    }

    _state = state.copyWith(
      isLoading: false,
      userName: user?.displayName,
      email: user?.email,
      photoUrl: imageUrl ?? user?.photoURL,
    );
    notifyListeners();
  }
}
