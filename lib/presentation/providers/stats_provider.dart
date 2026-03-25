import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/remote/event_service.dart';

class DriverStats {
  final int safetyScore;
  final String performanceMessage;
  final List<FlSpot> chartData;
  final int totalEvents;

  DriverStats({
    required this.safetyScore,
    required this.performanceMessage,
    required this.chartData,
    required this.totalEvents,
  });
}

final statsProvider = FutureProvider.autoDispose<DriverStats>((ref) async {
  final service = EventService();
  final data = await service.getEventsForLastDays(7);
  
  if (data.isEmpty) {
    return DriverStats(
      safetyScore: 100,
      performanceMessage: "¡Excelente! Sin incidentes registrados.",
      chartData: List.generate(7, (i) => FlSpot(i.toDouble(), 0)),
      totalEvents: 0,
    );
  }

  final now = DateTime.now();
  Map<int, int> eventsPerDay = {for (var i = 0; i < 7; i++) i: 0};
  int totalCritical = 0;
  int totalDrowsy = 0;

  for (final row in data) {
    final date = DateTime.parse(row['created_at'] as String);
    final daysAgo = now.difference(date).inDays;
    
    if (daysAgo >= 0 && daysAgo < 7) {
      // Coordenada x: 0 = hace 6 días, 6 = hoy
      final xIndex = 6 - daysAgo;
      eventsPerDay[xIndex] = (eventsPerDay[xIndex] ?? 0) + 1;
    }

    final severity = row['severity'] as String?;
    if (severity == 'critical') totalCritical++;
    if (severity == 'drowsy' || severity == 'tired') totalDrowsy++;
  }

  // Generar puntos para fl_chart
  final spots = eventsPerDay.entries
      .map((e) => FlSpot(e.key.toDouble(), e.value.toDouble()))
      .toList();
  spots.sort((a, b) => a.x.compareTo(b.x));

  // Fórmula matemática del Índice de Seguridad (Safety Score)
  // Penaliza fuertemente el estado crítico (-10%) y levemente el inicio de sueño (-3%)
  int score = 100 - (totalCritical * 10) - (totalDrowsy * 3);
  if (score < 0) score = 0;

  String message;
  if (score >= 90) {
    message = "Conducción impecable. Eres un profesional seguro.";
  } else if (score >= 70) {
    message = "Algunos episodios de fatiga observados. Conduce con cuidado.";
  } else if (score >= 50) {
    message = "Alerta de peligro. Múltiples alertas de somnolencia seguidas.";
  } else {
    message = "Riesgo crítico. Demasiados microsueños detectados.";
  }

  return DriverStats(
    safetyScore: score,
    performanceMessage: message,
    chartData: spots,
    totalEvents: data.length,
  );
});
