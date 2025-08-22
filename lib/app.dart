import 'package:flutter/material.dart';
import 'ui/pages/home_page.dart';
import 'ui/pages/stats_page.dart';
import 'services/notification_service.dart';
import 'services/location_service.dart';
import 'services/weather_service.dart';

class TaskManagerApp extends StatefulWidget {
  final NotificationService notifications;
  final WeatherService? weather;
  final LocationService locationService;

  const TaskManagerApp({
    super.key,
    required this.notifications,
    required this.locationService,
    this.weather,
  });

  @override
  State<TaskManagerApp> createState() => _TaskManagerAppState();
}

class _TaskManagerAppState extends State<TaskManagerApp> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color.fromARGB(255, 41, 20, 115),
        brightness: Brightness.light,
      ),
      home: Scaffold(
        body: IndexedStack(
          index: _index,
          children: <Widget>[
            HomePage(
              notifications: widget.notifications,
              weather: widget.weather,
              locationService: widget.locationService,
            ),
            const StatsPage(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (int i) => setState(() => _index = i),
          destinations: const <NavigationDestination>[
            NavigationDestination(icon: Icon(Icons.checklist_outlined), label: 'Zadania'),
            NavigationDestination(icon: Icon(Icons.insights_outlined), label: 'Statystyki'),
          ],
        ),
      ),
    );
  }
}