import 'package:flutter/material.dart';
import 'app.dart';
import 'services/notification_service.dart';
import 'services/location_service.dart';
import 'services/weather_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final NotificationService notifications = NotificationService();
  await notifications.init();

  //Ustawienie klucza API dla WeatherService.
  const String weatherApiKey = '5c56f7e9598f4ffbae4181021252008';
  final WeatherService? weather = weatherApiKey.isEmpty ? null : const WeatherService(apiKey: weatherApiKey);

  runApp(TaskManagerApp(
    notifications: notifications,
    locationService: const LocationService(),
    weather: weather,
  ));
}