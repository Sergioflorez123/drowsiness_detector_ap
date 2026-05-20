import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/remote/driving_remote_datasource.dart';
import '../../data/datasources/remote/event_service.dart';
import '../../domain/entities/driving_session_record.dart';

final sessionHistoryProvider =
    FutureProvider.autoDispose<List<DrivingSessionRecord>>((ref) async {
  final driving = ref.read(drivingRemoteDataSourceProvider);
  final events = EventService();

  final sessionRows = await driving.recentSessions(limit: 40);
  final eventRows = await events.getEventsForLastDays(60);

  // Pre-procesar y pre-filtrar los eventos una sola vez para evitar O(N * M) parseos de fechas
  final parsedEvents = <_ParsedEvent>[];
  for (final ev in eventRows) {
    final createdRaw = ev['created_at'] as String?;
    if (createdRaw == null) continue;

    final severity = ev['severity'] as String? ?? '';
    if (!_isDrowsinessSeverity(severity)) continue;

    final lat = (ev['latitude'] as num?)?.toDouble();
    final lng = (ev['longitude'] as num?)?.toDouble();
    if (lat == null || lng == null) continue;

    try {
      final at = DateTime.parse(createdRaw).toLocal();
      parsedEvents.add(_ParsedEvent(
        at: at,
        severity: severity,
        lat: lat,
        lng: lng,
      ));
    } catch (_) {
      // Ignorar fotogramas defectuosos
    }
  }

  final records = <DrivingSessionRecord>[];

  for (final row in sessionRows) {
    final id = row['id'] as String?;
    final startedRaw = row['started_at'] as String?;
    if (id == null || startedRaw == null) continue;

    final startedAt = DateTime.parse(startedRaw).toLocal();
    final endedRaw = row['ended_at'] as String?;
    final endedAt =
        endedRaw != null ? DateTime.parse(endedRaw).toLocal() : null;
    final windowEnd = endedAt ?? DateTime.now().add(const Duration(hours: 1));

    final points = <SessionMapPoint>[];
    for (final ev in parsedEvents) {
      if (ev.at.isBefore(startedAt) || ev.at.isAfter(windowEnd)) continue;

      points.add(SessionMapPoint(
        latitude: ev.lat,
        longitude: ev.lng,
        severity: ev.severity,
        at: ev.at,
      ));
    }

    points.sort((a, b) => b.at.compareTo(a.at));

    records.add(DrivingSessionRecord(
      id: id,
      startedAt: startedAt,
      endedAt: endedAt,
      durationSeconds: (row['duration_seconds'] as num?)?.toInt(),
      maxLevel: row['max_level'] as String? ?? 'normal',
      secNormal: (row['sec_normal'] as num?)?.toInt() ?? 0,
      secTired: (row['sec_tired'] as num?)?.toInt() ?? 0,
      secDrowsy: (row['sec_drowsy'] as num?)?.toInt() ?? 0,
      secCritical: (row['sec_critical'] as num?)?.toInt() ?? 0,
      criticalEvents: (row['critical_events'] as num?)?.toInt() ?? 0,
      drowsinessPoints: points,
    ));
  }

  return records;
});

class _ParsedEvent {
  final DateTime at;
  final String severity;
  final double lat;
  final double lng;

  const _ParsedEvent({
    required this.at,
    required this.severity,
    required this.lat,
    required this.lng,
  });
}

bool _isDrowsinessSeverity(String s) =>
    s == 'tired' || s == 'drowsy' || s == 'critical';
