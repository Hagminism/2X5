import 'package:firebase_auth/firebase_auth.dart';

String userFacingErrorMessage(
  Object error, {
  required String fallback,
}) {
  if (error is FirebaseAuthException) {
    return _mapFirebaseAuthError(error.code, fallback: fallback);
  }

  if (error is StateError) {
    final message = error.message.trim();
    if (message.isNotEmpty) {
      return message;
    }
  }

  return fallback;
}

String _mapFirebaseAuthError(
  String code, {
  required String fallback,
}) {
  switch (code) {
    case 'invalid-email':
      return '올바른 이메일 형식을 입력해 주세요.';
    case 'user-disabled':
      return '비활성화된 계정입니다. 고객센터에 문의해 주세요.';
    case 'user-not-found':
    case 'wrong-password':
    case 'invalid-credential':
      return '이메일 또는 비밀번호가 올바르지 않습니다.';
    case 'too-many-requests':
      return '요청이 너무 많습니다. 잠시 후 다시 시도해 주세요.';
    case 'network-request-failed':
      return '네트워크 오류가 발생했습니다. 잠시 후 다시 시도해 주세요.';
    case 'operation-not-allowed':
      return '지원하지 않는 로그인 방식입니다.';
    default:
      return fallback;
  }
}
