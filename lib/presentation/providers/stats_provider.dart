import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/remote/driving_remote_datasource.dart';
import '../../data/datasources/remote/event_service.dart';

class DriverStats {
  final int safetyScore;
  final List<FlSpot> weeklyAlertSpots;
  final List<FlSpot> dailyOpenSpots;
  final int totalEvents;
  final int totalSessions;
  final bool isEmpty;

  DriverStats({
    required this.safetyScore,
    required this.weeklyAlertSpots,
    required this.dailyOpenSpots,
    required this.totalEvents,
    required this.totalSessions,
    required this.isEmpty,
  });
}

int _dayIndexInWeek(DateTime eventDay, DateTime today) {
  final e = DateTime(eventDay.year, eventDay.month, eventDay.day);
  final t = DateTime(today.year, today.month, today.day);
  final diff = t.difference(e).inDays;
  if (diff < 0 || diff > 6) return -1;
  return 6 - diff;
}

final statsProvider = FutureProvider.autoDispose<DriverStats>((ref) async {
  final events = EventService();
  final driving = ref.read(drivingRemoteDataSourceProvider);

  final eventRows = await events.getEventsForLastDays(7);
  final dailyRows = await driving.dailyOpensLastDays(7);
  final sessionRows = await driving.sessionsLastDays(7);

  final now = DateTime.now();
  String dayKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  final opensByDay = <String, int>{};
  for (final row in dailyRows) {
    final key = row['usage_date'] as String?;
    if (key == null) continue;
    opensByDay[key] = (row['open_count'] as num?)?.toInt() ?? 0;
  }

  final dailyOpenSpots = <FlSpot>[];
  for (var i = 0; i < 7; i++) {
    final d = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: 6 - i));
    dailyOpenSpots.add(
      FlSpot(i.toDouble(), (opensByDay[dayKey(d)] ?? 0).toDouble()),
    );
  }

  final alertsByDayIndex = List<double>.filled(7, 0);
  for (final row in eventRows) {
    final created = DateTime.tryParse(row['created_at'] as String? ?? '');
    if (created == null) continue;
    final idx = _dayIndexInWeek(created, now);
    if (idx < 0) continue;
    alertsByDayIndex[idx] += 1;
  }

  final weeklyAlertSpots = List.generate(
    7,
    (i) => FlSpot(i.toDouble(), alertsByDayIndex[i]),
  );

  var totalCriticalSignals = 0;
  var fatigueSignals = 0;

  for (final row in eventRows) {
    final sev = row['severity'] as String? ?? '';
    if (sev == 'critical') totalCriticalSignals++;
    if (sev == 'drowsy' || sev == 'tired') fatigueSignals++;
  }

  for (final row in sessionRows) {
    totalCriticalSignals +=
        (row['critical_events'] as num?)?.toInt() ?? 0;
    final maxL = row['max_level'] as String? ?? '';
    if (maxL == 'tired' || maxL == 'drowsy') fatigueSignals++;
  }

  var score = 100 - (totalCriticalSignals * 6) - (fatigueSignals * 2);
  if (score < 0) score = 0;

  final empty = eventRows.isEmpty && sessionRows.isEmpty && dailyRows.isEmpty;
  if (empty) {
    return DriverStats(
      safetyScore: 100,
      weeklyAlertSpots: List.generate(7, (i) => FlSpot(i.toDouble(), 0)),
      dailyOpenSpots: List.generate(7, (i) => FlSpot(i.toDouble(), 0)),
      totalEvents: 0,
      totalSessions: 0,
      isEmpty: true,
    );
  }

  return DriverStats(
    safetyScore: score,
    weeklyAlertSpots: weeklyAlertSpots,
    dailyOpenSpots: dailyOpenSpots,
    totalEvents: eventRows.length,
    totalSessions: sessionRows.length,
    isEmpty: false,
  );
});
