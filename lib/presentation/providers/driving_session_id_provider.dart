import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Active Supabase `driving_sessions.id` while [DrivingScreen] is open.
final drivingSessionIdProvider = StateProvider<String?>((ref) => null);
