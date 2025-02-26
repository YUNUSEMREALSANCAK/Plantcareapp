import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/weather_repository.dart';
import '../../domain/models/weather_model.dart';

enum WeatherStatus { initial, loading, loaded, error }

class WeatherState {
  final WeatherStatus status;
  final List<WeatherModel>? weatherData;
  final String? errorMessage;

  WeatherState({
    this.status = WeatherStatus.initial,
    this.weatherData,
    this.errorMessage,
  });

  factory WeatherState.initial() => WeatherState();

  factory WeatherState.loading() => WeatherState(status: WeatherStatus.loading);

  factory WeatherState.loaded(List<WeatherModel> weatherData) => WeatherState(
        status: WeatherStatus.loaded,
        weatherData: weatherData,
      );

  factory WeatherState.error(String message) => WeatherState(
        status: WeatherStatus.error,
        errorMessage: message,
      );
}

class WeatherCubit extends Cubit<WeatherState> {
  final WeatherRepository _repository;

  WeatherCubit(this._repository) : super(WeatherState.initial());

  Future<void> getWeather({
    required String city,
    String lang = 'en',
  }) async {
    try {
      emit(WeatherState.loading());
      final weatherData = await _repository.getWeather(city: city, lang: lang);
      emit(WeatherState.loaded(weatherData));
    } catch (e) {
      emit(WeatherState.error(e.toString()));
    }
  }
}
