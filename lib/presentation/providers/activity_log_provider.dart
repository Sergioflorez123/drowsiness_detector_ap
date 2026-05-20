import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/remote/activity_log_datasource.dart';

class ActivityLogEntry {
  final String type;
  final DateTime recordedAt;
  final Map<String, dynamic>? details;

  ActivityLogEntry({
    required this.type,
    required this.recordedAt,
    this.details,
  });
}

final recentActivityProvider =
    FutureProvider.autoDispose<List<ActivityLogEntry>>((ref) async {
  final ds = ref.read(activityLogDataSourceProvider);
  final rows = await ds.recent(limit: 60);
  return rows.map((row) {
    final raw = row['recorded_at'] as String? ?? '';
    return ActivityLogEntry(
      type: row['activity_type'] as String? ?? '',
      recordedAt: DateTime.tryParse(raw)?.toLocal() ?? DateTime.now(),
      details: row['details'] as Map<String, dynamic>?,
    );
  }).toList();
});
