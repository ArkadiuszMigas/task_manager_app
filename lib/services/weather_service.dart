import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherInfo {
  final String locationName;
  final double temperatureC;
  final String conditionText;

  const WeatherInfo({
    required this.locationName,
    required this.temperatureC,
    required this.conditionText,
  });
}

class WeatherService {
  final String apiKey;

  const WeatherService({required this.apiKey});

  Future<WeatherInfo?> fetchByLatLon({required double lat, required double lon}) async {
    final Uri url = Uri.parse('https://api.weatherapi.com/v1/current.json?key=$apiKey&q=$lat,$lon&aqi=no');
    final http.Response resp = await http.get(url);
    if (resp.statusCode != 200) return null;

    final Object decoded = jsonDecode(resp.body);
    if (decoded is! Map<String, Object?>) return null;

    final Object? location = decoded['location'];
    final Object? current = decoded['current'];

    if (location is! Map<String, Object?> || current is! Map<String, Object?>) {
      return null;
    }

    final Object? name = location['name'];
    final Object? tempC = current['temp_c'];
    final Object? condition = current['condition'];

    String locName = name is String ? name : 'Twoja lokalizacja';
    double temperature = tempC is num ? tempC.toDouble() : 0.0;

    String condText = '';
    if (condition is Map<String, Object?>) {
      final Object? text = condition['text'];
      if (text is String) condText = text;
    }

    return WeatherInfo(locationName: locName, temperatureC: temperature, conditionText: condText);
  }
}