import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthRefreshNotifier with ChangeNotifier {
  late final StreamSubscription<User?> _sub;

  AuthRefreshNotifier(Stream<User?> authChanges) {
    _sub = authChanges.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}