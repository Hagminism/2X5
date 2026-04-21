enum SecurityActivity {
  changePassword
  ;

  String toDisplayName() => switch (this) {
    SecurityActivity.changePassword => '비밀번호 변경',
  };
}
