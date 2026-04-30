import 'dart:async';

import 'package:capstone_2026/core/domain/model/user/user.dart' as model_user;
import 'package:capstone_2026/core/domain/model/enum/user_registration_status.dart';
import 'package:capstone_2026/core/domain/repository/auth/auth_repository.dart';
import 'package:capstone_2026/core/domain/repository/user/user_repository.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth_user;
import 'package:flutter/foundation.dart';

class UserRegistrationStatusNotifier extends ChangeNotifier {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  late final StreamSubscription<auth_user.User?> _authSubscription;

  String? _lastUid;
  model_user.User? _currentUserProfile;

  bool _isRefreshing = false;

  UserRegistrationStatus _status = UserRegistrationStatus.unknown;

  UserRegistrationStatus get status => _status;

  model_user.User? get currentUserProfile => _currentUserProfile;

  UserRegistrationStatusNotifier({
    required AuthRepository authRepository,
    required UserRepository userRepository,
  }) : _authRepository = authRepository,
       _userRepository = userRepository {
    _authSubscription = _authRepository.authStateChanges().listen((user) {
      if (user == null) {
        reset();
        return;
      }
      unawaited(refresh(user.uid));
    });

    final currentUser = _authRepository.getCurrentUser();
    if (currentUser != null) {
      unawaited(refresh(currentUser.uid));
    }
  }

  Future<void> refresh(String uid) async {
    if (_isRefreshing && _lastUid == uid) return;

    _isRefreshing = true;
    _lastUid = uid;

    _status = UserRegistrationStatus.loading;
    notifyListeners();

    try {
      final user = await _userRepository.findUserById(uid);
      _currentUserProfile = user;
      _status = user == null
          ? UserRegistrationStatus.notExists
          : UserRegistrationStatus.exists;
    } catch (_) {
      _currentUserProfile = null;
      _status = UserRegistrationStatus.error;
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  void reset() {
    _lastUid = null;
    _isRefreshing = false;
    _currentUserProfile = null;
    _status = UserRegistrationStatus.unknown;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
}
