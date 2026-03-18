import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/remote/auth_service.dart';

final authProvider = StateNotifierProvider<AuthController, bool>((ref) {
  return AuthController(ref);
});

class AuthController extends StateNotifier<bool> {
  final Ref ref;

  AuthController(this.ref) : super(false);

  Future<void> login(String email, String password) async {
    state = true;
    try {
      await ref.read(authServiceProvider).signIn(email, password);
    } finally {
      state = false;
    }
  }

  Future<void> register(String email, String password) async {
    state = true;
    try {
      await ref.read(authServiceProvider).signUp(email, password);
    } finally {
      state = false;
    }
  }
}

