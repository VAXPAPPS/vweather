import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:vweather/core/colors/vaxp_colors.dart';
import 'package:window_manager/window_manager.dart';
import 'package:venom_config/venom_config.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

import 'data/datasources/weather_remote_datasource.dart';
import 'data/repositories/weather_repository.dart';
import 'domain/repositories/i_weather_repository.dart';
import 'presentation/bloc/weather_bloc.dart';
import 'presentation/pages/weather_page.dart';
import 'core/theme/vaxp_theme.dart'; // Ensure theme is available if needed implicitly by widgets

import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await VenomConfig().init();
  VaxpColors.init();
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(1000, 700),
    center: true,
    titleBarStyle: TitleBarStyle.hidden,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  // 1. Initialize Location
  // Check for saved location first
  final prefs = await SharedPreferences.getInstance();
  String? savedCity = prefs.getString('saved_city');
  String cityToLoad;

  if (savedCity != null && savedCity.isNotEmpty) {
    debugPrint("Loaded saved city: $savedCity");
    cityToLoad = savedCity;
  } else {
    debugPrint("No saved city found. Auto-detecting...");
    cityToLoad = await _determineDefaultCity();
    // Save the auto-detected city so we don't auto-detect next time
    await prefs.setString('saved_city', cityToLoad);
  }
  
  runApp(VenomApp(defaultCity: cityToLoad));
}

Future<String> _determineDefaultCity() async {
  // 1. Try dart:io System Checks (Linux/Desktop specific)
  try {
    if (Platform.isLinux) {
      // A. Environment Variable
      final envTz = Platform.environment['TZ'];
      if (envTz != null && envTz.contains('/')) {
        debugPrint("Detected System TZ (Env): $envTz");
        return envTz.split('/').last.replaceAll('_', ' ');
      }

      // B. /etc/timezone
      try {
        final f = File('/etc/timezone');
        if (f.existsSync()) {
          final content = f.readAsStringSync().trim();
          if (content.isNotEmpty && content.contains('/')) {
             debugPrint("Detected System TZ (File): $content");
             return content.split('/').last.replaceAll('_', ' ');
          }
        }
      } catch (e) {
        debugPrint("Error reading /etc/timezone: $e");
      }
    }
  } catch (e) {
    debugPrint("System check failed: $e");
  }

  // 2. Try Timezone Package (Fallback)
  try {
    // FlutterTimezone (5.0.1) returns TimezoneInfo or String depending on platform?
    // The error says it returns TimezoneInfo. 
    // We'll treat it as dynamic and convert to string.
    final dynamic timezone = await FlutterTimezone.getLocalTimezone();
    final String tzString = timezone.toString();
    debugPrint("Detected Timezone (Package): $tzString");
    
    // Handle "TimezoneInfo(Asia/Baghdad, null)" string format
    String cleanTz = tzString;
    if (cleanTz.startsWith("TimezoneInfo(")) {
      final start = cleanTz.indexOf('(') + 1;
      final end = cleanTz.indexOf(',');
      if (start > 0 && end > start) {
        cleanTz = cleanTz.substring(start, end).trim();
      }
    }

    if (cleanTz != 'UTC' && cleanTz != 'GMT' && cleanTz.contains('/')) {
       final parts = cleanTz.split('/');
       if (parts.length >= 2) {
         return parts.last.replaceAll('_', ' ');
       }
    }
  } catch (e) {
    debugPrint("Timezone detection failed: $e");
  }

  // 2. Fallback to IP Geolocation (More accurate for Desktop)
  try {
    debugPrint("Attempting IP Geolocation...");
    final response = await http.get(Uri.parse('http://ip-api.com/json'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'success' && data['city'] != null) {
        debugPrint("IP Location Found: ${data['city']}, ${data['country']}");
        return data['city'];
      }
    }
  } catch (e) {
    debugPrint("IP Geolocation failed: $e");
  }
  
  return 'London';
}


class VenomApp extends StatelessWidget {
  final String defaultCity;

  const VenomApp({super.key, required this.defaultCity});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<IWeatherRepository>(
      create: (context) => WeatherRepository(
        remoteDataSource: WeatherRemoteDataSource(client: http.Client()),
      ),
      child: BlocProvider(
        create: (context) => WeatherBloc(
          repository: context.read<IWeatherRepository>(),
        )..add(WeatherRequested(city: defaultCity)),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: VaxpTheme.dark, // Ensure theme is applied
          home: const WeatherPage(),
        ),
      ),
    );
  }
}
