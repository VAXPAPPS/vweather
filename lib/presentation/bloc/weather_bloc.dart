import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/weather.dart';
import '../../domain/repositories/i_weather_repository.dart';

part 'weather_event.dart';
part 'weather_state.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final IWeatherRepository repository;

  WeatherBloc({required this.repository}) : super(WeatherInitial()) {
    on<WeatherRequested>((event, emit) async {
      emit(WeatherLoading());
      try {
        final results = await Future.wait([
          repository.getCurrentWeather(event.city),
          repository.getForecast(event.city),
        ]);
        
        emit(WeatherLoaded(
          weather: results[0] as Weather, 
          forecast: results[1] as List<Weather>
        ));
      } catch (e) {
        emit(WeatherError(message: e.toString()));
      }
    });
  }
}
