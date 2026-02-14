import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:vweather/core/venom_layout.dart';
import 'package:vweather/core/colors/vaxp_colors.dart';
// import 'package:vweather/core/theme/vaxp_theme.dart'; // Not needed if VenomGlassCard uses it internally, but good to have
import '../bloc/weather_bloc.dart';
import '../widgets/search_overlay.dart';
import '../widgets/venom_glass_card.dart';
import '../widgets/metric_tile.dart';
import '../widgets/hourly_forecast_chart.dart';
// ignore: unused_import
import '../../domain/entities/weather.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  late Timer _timer;
  String _timeString = "";

  @override
  void initState() {
    super.initState();
    _timeString = _formatTime(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => _getTime());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _getTime() {
    final String formattedDateTime = _formatTime(DateTime.now());
    if (mounted) {
      setState(() {
        _timeString = formattedDateTime;
      });
    }
  }

  String _formatTime(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  IconData _getWeatherIcon(String code) {
    final intCode = int.tryParse(code) ?? 0;
    if (intCode == 0) return Icons.wb_sunny;
    if (intCode >= 1 && intCode <= 3) return Icons.wb_cloudy;
    if (intCode >= 45 && intCode <= 48) return Icons.foggy;
    if (intCode >= 51 && intCode <= 67) return Icons.grain; // Rain
    if (intCode >= 71 && intCode <= 77) return Icons.ac_unit; // Snow
    if (intCode >= 80 && intCode <= 82) return Icons.shower; // Showers
    if (intCode >= 95 && intCode <= 99) return Icons.thunderstorm;
    return Icons.question_mark;
  }

  @override
  Widget build(BuildContext context) {
    return VenomScaffold(
        
      title: "Venom Weather Pro",
      body: BlocBuilder<WeatherBloc, WeatherState>(
        builder: (context, state) {
          if (state is WeatherLoading) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          } else if (state is WeatherLoaded) {
            final weather = state.weather;
            return Stack(
              children: [
                // Background removed for transparency
                
                // 2. Main Content
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      // --- Left Panel: Hero ---
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                             Text(
                               weather.country.isNotEmpty ? "${weather.cityName}, ${weather.country}" : weather.cityName,
                               style: const TextStyle(
                                 fontSize: 32, // Slightly smaller to fit potentially long names
                                 fontWeight: FontWeight.bold,
                                 color: Colors.white,
                                 letterSpacing: -1,
                               ),
                               maxLines: 2,
                               overflow: TextOverflow.ellipsis,
                             ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3, end: 0),
                             
                             Text(
                               _timeString, 
                               style: TextStyle(
                                 fontSize: 18, 
                                 fontWeight: FontWeight.w300, 
                                 color: Colors.white.withOpacity(0.8)
                               )
                             ).animate().fadeIn(delay: 200.ms),

                             const SizedBox(height: 40),

                             Row(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 Text(
                                   "${weather.temperature.round()}",
                                   style: const TextStyle(
                                     fontSize: 120,
                                     fontWeight: FontWeight.w100,
                                     color: Colors.white,
                                     height: 1.0,
                                   ),
                                 ).animate().fadeIn(duration: 800.ms).scale(begin: const Offset(0.8, 0.8)),
                                 Padding(
                                   padding: const EdgeInsets.only(top: 20),
                                   child: const Text("°C", style: TextStyle(fontSize: 30, color: Colors.white54)),
                                 ),
                               ],
                             ),
                             
                             Row(
                               children: [
                                 Icon(_getWeatherIcon(weather.iconCode), color: Colors.white, size: 32),
                                 const SizedBox(width: 12),
                                 Text(
                                   weather.condition,
                                   style: const TextStyle(fontSize: 24, color: Colors.white70),
                                 ),
                               ],
                             ).animate().fadeIn(delay: 400.ms).slideX(),
                             
                             const Spacer(),
                             
                             VenomGlassCard(
                               onTap: () {
                                 showDialog(
                                   context: context,
                                   builder: (context) => const SearchOverlay(),
                                 );
                               },
                               child: const Row(
                                 mainAxisSize: MainAxisSize.min,
                                 children: [
                                   Icon(Icons.search, color: Colors.white70),
                                   SizedBox(width: 8),
                                   Text("Search City", style: TextStyle(color: Colors.white70)),
                                 ],
                               ),
                             ).animate().fadeIn(delay: 800.ms),
                          ],
                        ),
                      ),

                      const SizedBox(width: 24),

                      // --- Right Panel: Details & Forecast ---
                      Expanded(
                        flex: 5,
                        child: Column(
                          children: [
                             // Hourly Chart
                             Expanded(
                               flex: 3,
                               child: HourlyForecastChart(hourlyData: weather.hourlyForecast)
                                   .animate().fadeIn(delay: 500.ms).scale(),
                             ),
                             const SizedBox(height: 16),
                             
                             // Metrics Grid
                             Expanded(
                               flex: 3,
                               child: GridView.count(
                                 crossAxisCount: 3,
                                 crossAxisSpacing: 12,
                                 mainAxisSpacing: 12,
                                 childAspectRatio: 1.3,
                                 children: [
                                   MetricTile(
                                     icon: Icons.water_drop, 
                                     label: "Humidity", 
                                     value: "${weather.humidity.round()}", 
                                     unit: "%"
                                   ),
                                   MetricTile(
                                     icon: Icons.air, 
                                     label: "Wind", 
                                     value: "${weather.windSpeed.round()}", 
                                     unit: "km/h"
                                   ),
                                   MetricTile(
                                     icon: Icons.thermostat, 
                                     label: "Feels Like", 
                                     value: "${weather.feelsLike.round()}°", 
                                     unit: ""
                                   ),
                                   MetricTile(
                                     icon: Icons.wb_sunny_outlined, 
                                     label: "UV Index", 
                                     value: "${weather.uvIndex.round()}", 
                                     unit: ""
                                   ),
                                   MetricTile(
                                     icon: Icons.wb_twilight, 
                                     label: "Sunset", 
                                     value: weather.sunsetTime.isNotEmpty ? weather.sunsetTime.substring(11, 16) : "--:--", 
                                     unit: ""
                                   ),
                                   MetricTile(
                                     icon: Icons.visibility, 
                                     label: "Visibility", 
                                     value: "${(weather.visibility / 1000).toStringAsFixed(1)}", 
                                     unit: "km"
                                   ),
                                 ].animate(interval: 100.ms).fadeIn().slideY(begin: 0.2, end: 0),
                               ),
                             ),
                             
                             // 7-Day Mini List (Horizontal)
                             const SizedBox(height: 16),
                             SizedBox(
                                height: 100,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: state.forecast.length,
                                  itemBuilder: (context, index) {
                                    final day = state.forecast[index];
                                     return Padding(
                                       padding: const EdgeInsets.only(right: 12.0),
                                       child: VenomGlassCard(
                                         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                         child: Column(
                                           mainAxisAlignment: MainAxisAlignment.center,
                                           children: [
                                             Text(day.cityName, style: const TextStyle(fontSize: 12, color: Colors.white70)),
                                             const SizedBox(height: 8),
                                             Icon(_getWeatherIcon(day.iconCode), size: 20, color: Colors.white),
                                             const SizedBox(height: 8),
                                             Text("${day.temperature.round()}°", style: const TextStyle(fontWeight: FontWeight.bold)),
                                           ],
                                         ),
                                       ),
                                     );
                                  },
                                ).animate().fadeIn(delay: 1000.ms),
                             ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else if (state is WeatherError) {
             return Center(
               child: VenomGlassCard(
                 child: Column(
                   mainAxisSize: MainAxisSize.min,
                   children: [
                     const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                     const SizedBox(height: 16),
                     Text(state.message, style: const TextStyle(color: Colors.white)),
                     const SizedBox(height: 16),
                     ElevatedButton(
                       onPressed: () => context.read<WeatherBloc>().add(const WeatherRequested(city: 'London')),
                       style: ElevatedButton.styleFrom(backgroundColor: VaxpColors.primary),
                       child: const Text("Try Again"),
                     )
                   ],
                 ),
               ),
             );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
