import 'package:equatable/equatable.dart';

class Weather extends Equatable {
  final String cityName;
  final String country;
  final double temperature;
  final String condition;
  final String iconCode;
  final double humidity;
  final double windSpeed;

  final double feelsLike;
  final double uvIndex;
  final double visibility;
  final String sunsetTime;
  final List<Weather> hourlyForecast;

  const Weather({
    required this.cityName,
    required this.country,
    required this.temperature,
    required this.condition,
    required this.iconCode,
    required this.humidity,
    required this.windSpeed,
    this.feelsLike = 0.0,
    this.uvIndex = 0.0,
    this.visibility = 0.0,
    this.sunsetTime = '',
    this.hourlyForecast = const [],
  });

  @override
  List<Object?> get props => [
    cityName,
    country,
    temperature,
    condition,
    iconCode,
    humidity,
    windSpeed,
    feelsLike,
    uvIndex,
    sunsetTime,
    hourlyForecast,
  ];
}
