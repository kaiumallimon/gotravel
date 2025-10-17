import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WeatherTool {
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  static final String _apiKey = dotenv.env['OPENWEATHER_API_KEY'] ?? '';

  /// Get current weather for a location
  static Future<Map<String, dynamic>> getCurrentWeather(String location) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/weather?q=$location&appid=$_apiKey&units=metric',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'location': data['name'],
          'country': data['sys']['country'],
          'temperature': data['main']['temp'],
          'feels_like': data['main']['feels_like'],
          'humidity': data['main']['humidity'],
          'description': data['weather'][0]['description'],
          'wind_speed': data['wind']['speed'],
          'clouds': data['clouds']['all'],
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to fetch weather data for $location',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Error fetching weather: $e',
      };
    }
  }

  /// Get weather forecast for a location (5 days)
  static Future<Map<String, dynamic>> getForecast(String location) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/forecast?q=$location&appid=$_apiKey&units=metric',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List forecasts = data['list'].take(5).map((item) {
          return {
            'date': item['dt_txt'],
            'temperature': item['main']['temp'],
            'description': item['weather'][0]['description'],
          };
        }).toList();

        return {
          'success': true,
          'location': data['city']['name'],
          'country': data['city']['country'],
          'forecasts': forecasts,
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to fetch forecast for $location',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Error fetching forecast: $e',
      };
    }
  }

  /// Format weather data for AI response
  static String formatWeatherForAI(Map<String, dynamic> weatherData) {
    if (weatherData['success'] == false) {
      return weatherData['error'];
    }

    return '''
Current weather in ${weatherData['location']}, ${weatherData['country']}:
- Temperature: ${weatherData['temperature']}°C (feels like ${weatherData['feels_like']}°C)
- Conditions: ${weatherData['description']}
- Humidity: ${weatherData['humidity']}%
- Wind Speed: ${weatherData['wind_speed']} m/s
- Cloud Coverage: ${weatherData['clouds']}%
''';
  }
}
