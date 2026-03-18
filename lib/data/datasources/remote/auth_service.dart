import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase/supabase.dart';

import '../../../core/env.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(
    SupabaseClient(
      Env.supabaseUrl,
      Env.supabaseAnonKey,
    ),
  );
});

class AuthService {
  final SupabaseClient client;

  AuthService(this.client);

  Future<void> signIn(String email, String password) async {
    await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signUp(String email, String password) async {
    await client.auth.signUp(
      email: email,
      password: password,
    );
  }
}

