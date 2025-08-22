import 'package:flutter/material.dart';
import '../../services/weather_service.dart';

class WeatherHeader extends StatelessWidget {
  final WeatherInfo info;
  const WeatherHeader({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: <Widget>[
            const Icon(Icons.wb_sunny_outlined, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(info.locationName, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text('${info.temperatureC.toStringAsFixed(1)}°C • ${info.conditionText}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}