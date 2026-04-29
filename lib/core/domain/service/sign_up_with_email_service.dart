import 'package:capstone_2026/core/domain/model/enum/auth_provider.dart';
import 'package:capstone_2026/core/domain/model/enum/user_type.dart';
import 'package:capstone_2026/core/domain/model/user/user.dart';
import 'package:capstone_2026/core/domain/repository/auth/auth_repository.dart';
import 'package:capstone_2026/core/domain/repository/user/user_repository.dart';
import 'package:capstone_2026/core/exception/sign_up_profile_creation_exception.dart';
import 'package:capstone_2026/core/routing/core/component/user_registration_status_notifier.dart';

class SignUpWithEmailService {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  final UserRegistrationStatusNotifier _userRegistrationStatusNotifier;

  const SignUpWithEmailService({
    required AuthRepository authRepository,
    required UserRepository userRepository,
    required UserRegistrationStatusNotifier userRegistrationStatusNotifier,
  }) : _authRepository = authRepository,
       _userRepository = userRepository,
       _userRegistrationStatusNotifier = userRegistrationStatusNotifier;

  Future<void> signUpAndCreateProfile({
    required String name,
    required String phone,
    required String email,
    required String password,
    required UserType userType,
  }) async {
    await _authRepository.signUpWithEmail(
      email: email.trim(),
      password: password,
      name: name.trim(),
      phone: phone.trim(),
    );

    final firebaseUser = _authRepository.getCurrentUser();
    if (firebaseUser == null) {
      throw const SignUpProfileCreationException('회원가입 후 사용자 정보를 확인할 수 없습니다.');
    }

    try {
      await _userRepository.createUser(
        User(
          id: firebaseUser.uid,
          authProvider: AuthProvider.email,
          name: name.trim(),
          userType: userType,
          email: email.trim(),
          phone: phone.trim(),
          imageUrl: firebaseUser.photoURL ?? '',
        ),
      );
      await _userRegistrationStatusNotifier.refresh(firebaseUser.uid);
    } catch (_) {
      throw const SignUpProfileCreationException(
        '회원 정보 저장에 실패했습니다. 가입하기 버튼으로 다시 시도해 주세요.',
      );
    }
  }
}
