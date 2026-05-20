class SessionMapPoint {
  final double latitude;
  final double longitude;
  final String severity;
  final DateTime at;

  const SessionMapPoint({
    required this.latitude,
    required this.longitude,
    required this.severity,
    required this.at,
  });
}

class DrivingSessionRecord {
  final String id;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int? durationSeconds;
  final String maxLevel;
  final int secNormal;
  final int secTired;
  final int secDrowsy;
  final int secCritical;
  final int criticalEvents;
  final List<SessionMapPoint> drowsinessPoints;

  const DrivingSessionRecord({
    required this.id,
    required this.startedAt,
    this.endedAt,
    this.durationSeconds,
    required this.maxLevel,
    required this.secNormal,
    required this.secTired,
    required this.secDrowsy,
    required this.secCritical,
    required this.criticalEvents,
    required this.drowsinessPoints,
  });

  bool get hasMapPoints => drowsinessPoints.isNotEmpty;
}
