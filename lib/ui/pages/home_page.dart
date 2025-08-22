import 'dart:async';

import 'package:flutter/material.dart';
import '../../data/task.dart';
import '../../data/task_db.dart';
import '../../services/notification_service.dart';
import '../../services/location_service.dart';
import '../../services/weather_service.dart';
import '../widgets/task_tile.dart';
import '../widgets/weather_header.dart';
import 'edit_task_page.dart';
import '../../services/app_events.dart';

class HomePage extends StatefulWidget {
  final NotificationService notifications;
  final WeatherService? weather;
  final LocationService locationService;

  const HomePage({
    super.key,
    required this.notifications,
    required this.locationService,
    this.weather,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TaskDb _db = TaskDb();
  List<Task> _pending = <Task>[];
  List<Task> _done = <Task>[];
  WeatherInfo? _weatherInfo;
  StreamSubscription<AppEvent>? _sub;

  @override
  void initState() {
    super.initState();
    _refresh();
    _maybeLoadWeather();
    _sub = AppEvents.I.stream.listen((AppEvent e) {
      if (e == AppEvent.tasksChanged) {
        _refresh();
      }
    });
  }

  Future<void> _maybeLoadWeather() async {
    if (widget.weather == null) return;
    final position = await widget.locationService.getCurrentPosition();
    if (position == null) return;
    final WeatherInfo? info = await widget.weather!
        .fetchByLatLon(lat: position.latitude, lon: position.longitude);
    if (!mounted) return;
    setState(() {
      _weatherInfo = info;
    });
  }

  Future<void> _refresh() async {
    final List<Task> pending = await _db.getPendingTasks();
    final List<Task> done = await _db.getCompletedTasks();
    setState(() {
      _pending = pending;
      _done = done;
    });
  }

  Future<void> _addOrEdit({Task? editing}) async {
    final Task? result = await Navigator.of(context).push<Task>(
      MaterialPageRoute<Task>(builder: (_) => EditTaskPage(initial: editing)),
    );
    if (result == null) return;

    if (editing == null) {
      final int id = await _db.insertTask(result);
      final Task withId = result.copyWith(id: id);
      await widget.notifications.scheduleForTask(withId);
    } else {
      await _db.updateTask(result);
      await widget.notifications.cancelForTask(editing);
      await widget.notifications.scheduleForTask(result);
    }

    await _refresh();
  }

  Future<void> _toggle(Task t, bool done) async {
    await _db.toggleDone(t, done: done);
    if (done) {
      await widget.notifications.cancelForTask(t);
    } else {
      await widget.notifications.scheduleForTask(t);
    }
    await _refresh();
  }

  Future<void> _delete(Task t) async {
    await widget.notifications.cancelForTask(t);
    if (t.id != null) {
      await _db.deleteTask(t.id as int);
    }
    await _refresh();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Twoje zadania')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEdit(),
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          children: <Widget>[
            if (_weatherInfo != null)
              WeatherHeader(info: _weatherInfo as WeatherInfo),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
              child: Text('Do zrobienia',
                  style: Theme.of(context).textTheme.titleLarge),
            ),
            if (_pending.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text('Brak zadań. Kliknij + aby dodać pierwsze!'),
              )
            else
              ..._pending.map((Task t) => TaskTile(
                    task: t,
                    onToggleDone: (bool v) => _toggle(t, v),
                    onTap: () => _addOrEdit(editing: t),
                    onDelete: () => _delete(t),
                  )),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
              child: Text('Wykonane',
                  style: Theme.of(context).textTheme.titleLarge),
            ),
            if (_done.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text('Jeszcze nic nie wykonano.'),
              )
            else
              ..._done.map((Task t) => TaskTile(
                    task: t,
                    onToggleDone: (bool v) => _toggle(t, v),
                    onTap: () => _addOrEdit(editing: t),
                    onDelete: () => _delete(t),
                  )),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
