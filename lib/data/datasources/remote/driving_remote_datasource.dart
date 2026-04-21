import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final drivingRemoteDataSourceProvider =
    Provider<DrivingRemoteDataSource>((ref) {
  return DrivingRemoteDataSource(Supabase.instance.client);
});

/// Persists drowsiness-related analytics per user (see `supabase/migrations/`).
class DrivingRemoteDataSource {
  DrivingRemoteDataSource(this._client);

  final SupabaseClient _client;

  String? get _userId => _client.auth.currentUser?.id;

  String _dateOnlyUtc(DateTime dt) {
    final u = dt.toUtc();
    return '${u.year.toString().padLeft(4, '0')}-'
        '${u.month.toString().padLeft(2, '0')}-'
        '${u.day.toString().padLeft(2, '0')}';
  }

  /// Call once when the authenticated user reaches the home dashboard.
  Future<void> logAppOpenedToday() async {
    final uid = _userId;
    if (uid == null) return;

    final today = _dateOnlyUtc(DateTime.now());
    final now = DateTime.now().toUtc().toIso8601String();

    try {
      final existing = await _client
          .from('app_daily_usage')
          .select('id, open_count')
          .eq('user_id', uid)
          .eq('usage_date', today)
          .maybeSingle();

      if (existing == null) {
        await _client.from('app_daily_usage').insert({
          'user_id': uid,
          'usage_date': today,
          'first_open_at': now,
          'last_open_at': now,
          'open_count': 1,
        });
      } else {
        final count = (existing['open_count'] as num?)?.toInt() ?? 1;
        await _client.from('app_daily_usage').update({
          'last_open_at': now,
          'open_count': count + 1,
        }).eq('id', existing['id']);
      }
    } catch (_) {
      // Table missing or offline: app still works.
    }
  }

  /// Returns new session id, or null if insert failed.
  Future<String?> startDrivingSession() async {
    final uid = _userId;
    if (uid == null) return null;
    try {
      final row = await _client
          .from('driving_sessions')
          .insert({
            'user_id': uid,
            'started_at': DateTime.now().toUtc().toIso8601String(),
          })
          .select('id')
          .single();
      return row['id'] as String;
    } catch (_) {
      return null;
    }
  }

  Future<void> endDrivingSession({
    required String sessionId,
    required int durationSeconds,
    required String maxLevel,
    required int secNormal,
    required int secTired,
    required int secDrowsy,
    required int secCritical,
    required int criticalEvents,
  }) async {
    final uid = _userId;
    if (uid == null) return;
    try {
      await _client.from('driving_sessions').update({
        'ended_at': DateTime.now().toUtc().toIso8601String(),
        'duration_seconds': durationSeconds,
        'max_level': maxLevel,
        'sec_normal': secNormal,
        'sec_tired': secTired,
        'sec_drowsy': secDrowsy,
        'sec_critical': secCritical,
        'critical_events': criticalEvents,
      }).eq('id', sessionId).eq('user_id', uid);
    } catch (_) {}
  }

  Future<void> insertSample({
    required String sessionId,
    required String level,
    required double eyeClosureSec,
  }) async {
    final uid = _userId;
    if (uid == null) return;
    try {
      await _client.from('drowsiness_samples').insert({
        'user_id': uid,
        'session_id': sessionId,
        'level': level,
        'eye_closure_sec': eyeClosureSec,
      });
    } catch (_) {}
  }

  Future<List<Map<String, dynamic>>> dailyOpensLastDays(int days) async {
    final uid = _userId;
    if (uid == null) return [];
    final from = _dateOnlyUtc(DateTime.now().subtract(Duration(days: days - 1)));
    try {
      final res = await _client
          .from('app_daily_usage')
          .select('usage_date, open_count, last_open_at')
          .eq('user_id', uid)
          .gte('usage_date', from)
          .order('usage_date', ascending: true);
      return List<Map<String, dynamic>>.from(res);
    } catch (_) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> sessionsLastDays(int days) async {
    final uid = _userId;
    if (uid == null) return [];
    final since = DateTime.now().toUtc().subtract(Duration(days: days));
    try {
      final res = await _client
          .from('driving_sessions')
          .select(
            'started_at, ended_at, max_level, sec_normal, sec_tired, sec_drowsy, sec_critical, critical_events',
          )
          .eq('user_id', uid)
          .gte('started_at', since.toIso8601String())
          .order('started_at', ascending: true);
      return List<Map<String, dynamic>>.from(res);
    } catch (_) {
      return [];
    }
  }
}
