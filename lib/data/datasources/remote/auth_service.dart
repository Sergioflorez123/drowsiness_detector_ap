import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(Supabase.instance.client);
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

  Future<void> signUp(String email, String password, String name) async {
    await client.auth.signUp(
      email: email,
      password: password,
      data: {'name': name},
    );
  }
}

