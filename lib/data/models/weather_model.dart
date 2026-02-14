import '../../domain/entities/weather.dart';

class WeatherModel extends Weather {
  const WeatherModel({
    required super.cityName,
    required super.country,
    required super.temperature,
    required super.condition,
    required super.iconCode,
    required super.humidity,
    required super.windSpeed,
    required super.feelsLike,
    required super.uvIndex,
    required super.visibility,
    required super.sunsetTime,
    required super.hourlyForecast,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json, String cityName, String country) {
    // Current
    // ignore: unused_local_variable
    final current = json['current_weather']; // Note: OpenMeteo 'current_weather' is legacy, using 'current' block if available or extracting from hourly/daily requires careful URL construction.
    // Actually, to get UV and FeelsLike, we need 'current=...' in URL which returns a 'current' object in newer API versions, 
    // OR we just map from the 'current' block if we requested parameters.
    // check remote datasource URL plan: &current=temperature_2m,relative_humidity_2m,apparent_temperature,is_day,precipitation,weather_code,wind_speed_10m
    
    // Let's assume the datasource will be updated to return a robust structure.
    // For now, let's look at what we likely get.
    // If we use the new URL format: &current=temperature_2m,weather_code,wind_speed_10m,relative_humidity_2m,apparent_temperature
    
    final currentBlock = json['current']; 
    final dailyBlock = json['daily'];
    
    // Safe fallback if 'current' is missing (legacy compat)
    final temp = currentBlock != null ? (currentBlock['temperature_2m'] as num).toDouble() : (json['current_weather']['temperature'] as num).toDouble();
    final speed = currentBlock != null ? (currentBlock['wind_speed_10m'] as num).toDouble() : (json['current_weather']['windspeed'] as num).toDouble();
    final code = currentBlock != null ? currentBlock['weather_code'] as int : json['current_weather']['weathercode'] as int;
    
    final humidity = currentBlock != null ? (currentBlock['relative_humidity_2m'] as num).toDouble() : 0.0;
    final feelsLike = currentBlock != null ? (currentBlock['apparent_temperature'] as num).toDouble() : temp;
    final visibility = currentBlock != null && currentBlock['visibility'] != null ? (currentBlock['visibility'] as num).toDouble() : 10000.0;
    
    // Daily for sunset/uv (usually in daily)
    String sunset = '';
    double uv = 0.0;
    
    if (dailyBlock != null) {
      if ((dailyBlock['sunset'] as List).isNotEmpty) sunset = dailyBlock['sunset'][0].toString();
      if ((dailyBlock['uv_index_max'] as List).isNotEmpty) uv = (dailyBlock['uv_index_max'][0] as num).toDouble();
    }

    return WeatherModel(
      cityName: cityName,
      country: country,
      temperature: temp,
      condition: _mapWmoCodeToCondition(code),
      iconCode: code.toString(),
      humidity: humidity, 
      windSpeed: speed,
      feelsLike: feelsLike,
      uvIndex: uv,
      visibility: visibility,
      sunsetTime: sunset,
      hourlyForecast: _parseHourly(json['hourly']),
    );
  }

  static List<WeatherModel> _parseHourly(Map<String, dynamic>? hourly) {
    if (hourly == null) return [];
    final times = hourly['time'] as List;
    final temps = hourly['temperature_2m'] as List;
    final codes = hourly['weather_code'] as List;
    
    // Take next 24 hours
    List<WeatherModel> list = [];
    final now = DateTime.now();
    
    for (int i = 0; i < times.length; i++) {
       final timeStr = times[i].toString();
       final time = DateTime.tryParse(timeStr);
       if (time != null && time.isAfter(now) && list.length < 24) {
          list.add(WeatherModel(
             cityName: "${time.hour}:00", // Hack: reusing cityName for time label
             country: '', // Not needed for hourly items
             temperature: (temps[i] as num).toDouble(),
             condition: _mapWmoCodeToCondition(codes[i] as int),
             iconCode: codes[i].toString(),
             humidity: 0,
             windSpeed: 0,
             feelsLike: 0,
             uvIndex: 0,
             visibility: 10000.0,
             sunsetTime: '',
             hourlyForecast: [],
          ));
       }
    }
    return list;
  }

  
  static String _mapWmoCodeToCondition(int code) {
    if (code == 0) return 'Clear Sky';
    if (code >= 1 && code <= 3) return 'Partly Cloudy';
    if (code >= 45 && code <= 48) return 'Fog';
    if (code >= 51 && code <= 67) return 'Rain';
    if (code >= 71 && code <= 77) return 'Snow';
    if (code >= 95 && code <= 99) return 'Thunderstorm';
    return 'Unknown';
  }

  static List<WeatherModel> fromDailyJson(Map<String, dynamic> json, String cityName) {
    final daily = json['daily'];
    final List<dynamic> time = daily['time'];
    final List<dynamic> codes = daily['weathercode'];
    final List<dynamic> maxTemps = daily['temperature_2m_max'];
    final List<dynamic> minTemps = daily['temperature_2m_min'];

    List<WeatherModel> forecast = [];
    for (int i = 0; i < time.length; i++) {
        // Simple average for temperature or just show max
        final double avgTemp = ((maxTemps[i] as num) + (minTemps[i] as num)) / 2;
        
        forecast.add(WeatherModel(
          cityName: _formatDay(time[i]), // Better formatting
          country: '', // Not needed for daily forecast items
          temperature: avgTemp,
          condition: _mapWmoCodeToCondition(codes[i]),
          iconCode: codes[i].toString(),
          humidity: 0, 
          windSpeed: 0,
          feelsLike: 0,
          uvIndex: 0,
          visibility: 10000.0,
          sunsetTime: '',
          hourlyForecast: [],
        ));
    }
    return forecast;
  }
  
  static String _formatDay(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      final now = DateTime.now();
      if (date.year == now.year && date.month == now.month && date.day == now.day) return 'Today';
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[date.weekday - 1];
    } catch (e) {
      return isoDate;
    }
  }
}
