import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class WeatherRepository {
  final String _apiKey = '0lHeqoofsMOZjcnIwknTTW:4ndodQ3hco5dcm22NZOsEz';
  final String _baseUrl = 'https://api.collectapi.com/weather/getWeather';

  Future<List<WeatherModel>> getWeather({
    required String city,
    String lang = 'en',
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl?data.lang=$lang&data.city=$city'),
        headers: {
          'authorization': 'apikey $_apiKey',
          'content-type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> result = data['result'];
        return result.map((item) => WeatherModel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching weather: $e');
      throw Exception('Failed to load weather data: $e');
    }
  }
}
