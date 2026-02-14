import '../../domain/entities/weather.dart';
import '../../domain/repositories/i_weather_repository.dart';
import '../datasources/weather_remote_datasource.dart';

class WeatherRepository implements IWeatherRepository {
  final WeatherRemoteDataSource remoteDataSource;

  WeatherRepository({required this.remoteDataSource});

  @override
  Future<Weather> getCurrentWeather(String cityName) async {
    return await remoteDataSource.getCurrentWeather(cityName);
  }

  @override
  Future<List<Weather>> getForecast(String cityName) async {
    return await remoteDataSource.getForecast(cityName);
  }
}
