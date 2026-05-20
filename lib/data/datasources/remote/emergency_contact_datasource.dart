import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final emergencyContactDataSourceProvider =
    Provider<EmergencyContactDataSource>((ref) {
  return EmergencyContactDataSource(Supabase.instance.client);
});

class EmergencyContactDataSource {
  EmergencyContactDataSource(this._client);

  final SupabaseClient _client;

  String? get _userId => _client.auth.currentUser?.id;

  Future<({String name, String phone})?> fetch() async {
    final uid = _userId;
    if (uid == null) return null;
    try {
      final row = await _client
          .from('emergency_contacts')
          .select('name, phone')
          .eq('user_id', uid)
          .maybeSingle();
      if (row == null) return null;
      return (
        name: row['name'] as String? ?? '',
        phone: row['phone'] as String? ?? '',
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> upsert({
    required String name,
    required String phone,
  }) async {
    final uid = _userId;
    if (uid == null) return;
    final now = DateTime.now().toUtc().toIso8601String();
    try {
      await _client.from('emergency_contacts').upsert({
        'user_id': uid,
        'name': name,
        'phone': phone,
        'updated_at': now,
      });
    } catch (e) {
      debugPrint('Emergency contact upsert: $e');
    }
  }
}
