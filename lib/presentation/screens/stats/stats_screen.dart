import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/stats_provider.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final statsAsyncValue = ref.watch(statsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Análisis del Conductor')),
      body: statsAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text('Error al procesar data:\n$err', textAlign: TextAlign.center),
        ),
        data: (stats) {
          List<Color> gradientColors = [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.0),
          ];

          // Auto-escalar el eje Y según la cantidad de alertas
          double maxY = 5;
          for (var spot in stats.chartData) {
            if (spot.y > maxY) maxY = spot.y + 2;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Safety Score Card Real
                Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [theme.colorScheme.surface, theme.colorScheme.surface],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1), 
                        blurRadius: 20, 
                        offset: const Offset(0, 10))
                    ]
                  ),
                  child: Column(
                    children: [
                      const Text('Puntaje de Seguridad', style: TextStyle(fontSize: 18, color: Colors.grey)),
                      const SizedBox(height: 10),
                      Text(
                        '${stats.safetyScore}%',
                        style: TextStyle(
                          fontSize: 72, 
                          fontWeight: FontWeight.w900, 
                          color: stats.safetyScore > 80 ? theme.colorScheme.primary : (stats.safetyScore > 50 ? Colors.orange : Colors.redAccent),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(stats.performanceMessage, style: const TextStyle(fontSize: 16), textAlign: TextAlign.center),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                
                Text('Incidentes de Alerta (Historial semanal: ${stats.totalEvents})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                
                // Gráfica de Datos Reales
                SizedBox(
                  height: 250,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 1,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(color: theme.dividerColor.withOpacity(0.3), strokeWidth: 1);
                        },
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) {
                              const style = TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold);
                              String text;
                              switch (value.toInt()) {
                                case 0: text = '-6 d'; break;
                                case 2: text = '-4 d'; break;
                                case 4: text = '-2 d'; break;
                                case 6: text = 'Hoy'; break;
                                default: text = ''; break;
                              }
                              return Padding(padding: const EdgeInsets.only(top: 8.0), child: Text(text, style: style));
                            },
                          )
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      minX: 0,
                      maxX: 6,
                      minY: 0,
                      maxY: maxY,
                      lineBarsData: [
                        LineChartBarData(
                          spots: stats.chartData,
                          isCurved: true,
                          color: theme.colorScheme.primary,
                          barWidth: 4,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(radius: 4, color: theme.colorScheme.primary, strokeWidth: 2, strokeColor: Colors.white);
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: gradientColors,
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
