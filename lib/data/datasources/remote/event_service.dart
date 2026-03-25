import 'package:supabase_flutter/supabase_flutter.dart';

class EventService {
  final client = Supabase.instance.client;

  Future<void> saveEvent({
    required String type,
    required double lat,
    required double lng,
    required String severity,
  }) async {
    await client.from('events').insert({
      'type': type,
      'latitude': lat,
      'longitude': lng,
      'severity': severity,
      'created_at': DateTime.now().toIso8601String(),
    });
  }
}
