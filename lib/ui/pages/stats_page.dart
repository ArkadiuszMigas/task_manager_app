import 'dart:async';

import 'package:flutter/material.dart';
import '../../data/task_db.dart';
import '../../services/stats_service.dart';
import '../../services/app_events.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});
  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  final TaskDb _db = TaskDb();
  final StatsService _stats = const StatsService();

  int _completed = 0;
  String _bestDay = '-';
  int _bestDayCount = 0; // ile zadań ma aktualny „najlepszy” dzień
  StreamSubscription<AppEvent>? _sub;

  @override
  void initState() {
    super.initState();
    _load();
    _sub = AppEvents.I.stream.listen((AppEvent e) {
      if (e == AppEvent.tasksChanged) {
        _load();
      }
    });
  }

  Future<void> _load() async {
    final all = await _db.getAllTasks();
    final result = _stats.computeForCurrentWeek(all);
    setState(() {
      _completed = result.completedCount; // globalna liczba ukończonych (jak wcześniej)
      // Zmieniamy tylko jeśli obecny lider ma WIĘKSZY wynik niż zapamiętany.
      if (result.mostProductiveCount > _bestDayCount || _bestDay == '-') {
        _bestDayCount = result.mostProductiveCount;
        _bestDay = result.mostProductiveDay;
      }
      // Jeśli jest remis (==), nie zmieniamy dnia – zachowujemy dotychczasowy.
      // Reset tygodniowy dzieje się naturalnie, bo compute patrzy tylko na bieżący tydzień.
      if (DateTime.now().weekday == DateTime.monday && result.mostProductiveCount == 0) {
        // W poniedziałek rano, dopóki nic nie ukończono, wyczyść stan UI
        _bestDay = '-';
        _bestDayCount = 0;
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Card(
            child: ListTile(
              leading: const Icon(Icons.check_circle_outline),
              title: const Text('Wykonane zadania'),
              trailing: Text('$_completed',
                  style: Theme.of(context).textTheme.headlineSmall),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.calendar_today_outlined),
              title: const Text('Najbardziej produktywny dzień'),
              trailing:
                  Text(_bestDay, style: Theme.of(context).textTheme.titleLarge),
            ),
          ),
        ],
      ),
    );
  }
}
