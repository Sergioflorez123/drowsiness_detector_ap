import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final activityLogDataSourceProvider = Provider<ActivityLogDataSource>((ref) {
  return ActivityLogDataSource(Supabase.instance.client);
});

/// Tipos de actividad registrados en Supabase.
abstract class ActivityType {
  static const appOpen = 'app_open';
  static const drivingStart = 'driving_start';
  static const drivingEnd = 'driving_end';
  static const drowsinessAlert = 'drowsiness_alert';
  static const emergencyContactSaved = 'emergency_contact_saved';
  static const sensitivityChanged = 'sensitivity_changed';
}

class ActivityLogDataSource {
  ActivityLogDataSource(this._client);

  final SupabaseClient _client;

  String? get _userId => _client.auth.currentUser?.id;

  Future<void> log({
    required String activityType,
    Map<String, dynamic>? details,
  }) async {
    final uid = _userId;
    if (uid == null) return;
    try {
      await _client.from('activity_logs').insert({
        'user_id': uid,
        'activity_type': activityType,
        'recorded_at': DateTime.now().toUtc().toIso8601String(),
        if (details != null) 'details': details,
      });
    } catch (_) {
      // Sin tabla o sin red: la app sigue funcionando.
    }
  }

  Future<List<Map<String, dynamic>>> recent({int limit = 80}) async {
    final uid = _userId;
    if (uid == null) return [];
    try {
      final res = await _client
          .from('activity_logs')
          .select('activity_type, recorded_at, details')
          .eq('user_id', uid)
          .order('recorded_at', ascending: false)
          .limit(limit);
      return List<Map<String, dynamic>>.from(res);
    } catch (_) {
      return [];
    }
  }

  /// Agrupa conteos por día (últimos [days] días).
  Future<Map<String, int>> countByDay({int days = 14}) async {
    final uid = _userId;
    if (uid == null) return {};
    final since = DateTime.now().toUtc().subtract(Duration(days: days));
    try {
      final res = await _client
          .from('activity_logs')
          .select('recorded_at')
          .eq('user_id', uid)
          .gte('recorded_at', since.toIso8601String());
      final counts = <String, int>{};
      for (final row in res) {
        final raw = row['recorded_at'] as String?;
        if (raw == null) continue;
        final dt = DateTime.parse(raw).toLocal();
        final key =
            '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
        counts[key] = (counts[key] ?? 0) + 1;
      }
      return counts;
    } catch (_) {
      return {};
    }
  }
}
