import '../entities/weather.dart';

abstract class IWeatherRepository {
  Future<Weather> getCurrentWeather(String cityName);
  Future<List<Weather>> getForecast(String cityName);
}
