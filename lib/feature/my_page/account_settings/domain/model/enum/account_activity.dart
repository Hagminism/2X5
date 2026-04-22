enum AccountActivity {
  signOut,
  deleteAccount;

  String toDisplayName() => switch (this) {
    AccountActivity.signOut => '로그아웃',
    AccountActivity.deleteAccount => '회원 탈퇴',
  };
}
