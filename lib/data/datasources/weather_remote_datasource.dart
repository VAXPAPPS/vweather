import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class WeatherRemoteDataSource {
  final http.Client client;
  final String _baseUrl = 'https://api.open-meteo.com/v1';
  final String _geocodingUrl = 'https://geocoding-api.open-meteo.com/v1';

  WeatherRemoteDataSource({required this.client});

  Future<WeatherModel> getCurrentWeather(String cityName) async {
    // 1. Geocoding
    final geoUri = Uri.parse('$_geocodingUrl/search?name=$cityName&count=1&language=en&format=json');
    final geoResponse = await client.get(geoUri);

    if (geoResponse.statusCode != 200) {
      throw Exception('Failed to load location data');
    }

    final geoJson = json.decode(geoResponse.body);
    if (!geoJson.containsKey('results') || (geoJson['results'] as List).isEmpty) {
      throw Exception('Location not found');
    }

    final location = geoJson['results'][0];
    final double lat = location['latitude'];
    final double lon = location['longitude'];
    final String name = location['name'];
    final String country = location['country'] ?? '';

    // 2. Weather
    // Requesting:
    // Current: temp, weathercode, windspeed, humidity, apparent_temp (feels_like), is_day, visibility
    // Hourly: temp, weathercode (next 24h)
    // Daily: sunset, uv_index_max
    final weatherUri = Uri.parse(
      '$_baseUrl/forecast?latitude=$lat&longitude=$lon'
      '&current=temperature_2m,relative_humidity_2m,apparent_temperature,is_day,precipitation,weather_code,wind_speed_10m,visibility'
      '&hourly=temperature_2m,weather_code'
      '&daily=weather_code,sunset,uv_index_max'
      '&timezone=auto'
    );
    
    final weatherResponse = await client.get(weatherUri);

    if (weatherResponse.statusCode != 200) {
      throw Exception('Failed to load weather data');
    }

    final weatherJson = json.decode(weatherResponse.body);
    return WeatherModel.fromJson(weatherJson, name, country);
  }

  Future<List<WeatherModel>> getForecast(String cityName) async {
    // Re-using logic effectively requires refactoring or just duplicating geocoding for now.
    // For efficiency in this specific task, I'll duplicate the geocoding or assume the caller handles it?
    // The repo calls this. I should refactor geocoding to a helper or just duplicate for speed.
    // Let's duplicate for now to avoid breaking existing logic risk.
    
    final geoUri = Uri.parse('$_geocodingUrl/search?name=$cityName&count=1&language=en&format=json');
    final geoResponse = await client.get(geoUri);

    if (geoResponse.statusCode != 200) throw Exception('Failed to load location data');
    final geoJson = json.decode(geoResponse.body);
    if (!geoJson.containsKey('results') || (geoJson['results'] as List).isEmpty) throw Exception('Location not found');
    final location = geoJson['results'][0];
    final double lat = location['latitude'];
    final double lon = location['longitude'];

    final weatherUri = Uri.parse('$_baseUrl/forecast?latitude=$lat&longitude=$lon&daily=weathercode,temperature_2m_max,temperature_2m_min&timezone=auto');
    final weatherResponse = await client.get(weatherUri);

    if (weatherResponse.statusCode != 200) throw Exception('Failed to load weather data');

    final weatherJson = json.decode(weatherResponse.body);
    return WeatherModel.fromDailyJson(weatherJson, cityName);
  }
}
