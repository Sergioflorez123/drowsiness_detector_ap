import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EventService {
  final client = Supabase.instance.client;
  static const _queueKey = 'offline_events_queue';

  Future<void> saveEvent({
    required String type,
    required double lat,
    required double lng,
    required String severity,
  }) async {
    final eventData = {
      'type': type,
      'latitude': lat,
      'longitude': lng,
      'severity': severity,
      'created_at': DateTime.now().toIso8601String(),
    };

    try {
      await client.from('events').insert(eventData);
    } catch (e) {
      // Modo Offline: Si falla el internet, se encola localmente
      await _queueEvent(eventData);
    }
  }

  Future<void> _queueEvent(Map<String, dynamic> event) async {
    final prefs = await SharedPreferences.getInstance();
    final queue = prefs.getStringList(_queueKey) ?? [];
    queue.add(jsonEncode(event));
    await prefs.setStringList(_queueKey, queue);
  }

  /// Llamado silenciosamente cuando inicia el Dashboard y hay internet
  Future<void> syncOfflineEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final queue = prefs.getStringList(_queueKey) ?? [];
    
    if (queue.isEmpty) return;

    List<String> failed = [];

    for (final item in queue) {
      try {
        final data = jsonDecode(item);
        await client.from('events').insert(data);
      } catch (e) {
        failed.add(item);
      }
    }

    if (failed.isEmpty) {
      await prefs.remove(_queueKey);
    } else {
      await prefs.setStringList(_queueKey, failed);
    }
  }

  Future<List<Map<String, dynamic>>> getEventsForLastDays(int days) async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) return [];

    final date = DateTime.now().subtract(Duration(days: days));
    
    final response = await client
        .from('events')
        .select()
        .eq('user_id', userId)
        .gte('created_at', date.toIso8601String())
        .order('created_at', ascending: true);
        
    return List<Map<String, dynamic>>.from(response);
  }
}
