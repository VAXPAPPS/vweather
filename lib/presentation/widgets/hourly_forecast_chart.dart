import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:vweather/core/colors/vaxp_colors.dart';
import '../../domain/entities/weather.dart';
import 'venom_glass_card.dart';

class HourlyForecastChart extends StatelessWidget {
  final List<Weather> hourlyData;

  const HourlyForecastChart({super.key, required this.hourlyData});

  @override
  Widget build(BuildContext context) {
    if (hourlyData.isEmpty) return const SizedBox.shrink();

    // Calculate dynamic min/max for Y axis
    double minTemp = 100;
    double maxTemp = -100;
    for (var w in hourlyData) {
      if (w.temperature < minTemp) minTemp = w.temperature;
      if (w.temperature > maxTemp) maxTemp = w.temperature;
    }
    minTemp -= 2;
    maxTemp += 2;

    return VenomGlassCard(
      padding: const EdgeInsets.fromLTRB(16, 24, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "24-Hour Temperature Trend",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.white.withOpacity(0.05),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      interval: 4, // Show every 4th hour
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < hourlyData.length) {
                          // cityName currently holds "HH:00" from data model hack
                          // Better to parse the full time if available, but for now this works as the label
                          return Text(
                            hourlyData[index].cityName,
                            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 5,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}°',
                          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (hourlyData.length - 1).toDouble(),
                minY: minTemp,
                maxY: maxTemp,
                lineBarsData: [
                  LineChartBarData(
                    spots: hourlyData.asMap().entries.map((e) {
                      return FlSpot(e.key.toDouble(), e.value.temperature);
                    }).toList(),
                    isCurved: true,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF23B6E6), Color(0xFF02D39A)],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF23B6E6).withOpacity(0.2),
                          const Color(0xFF02D39A).withOpacity(0.05),
                        ],
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
  }
}
