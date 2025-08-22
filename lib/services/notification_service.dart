import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;
import '../data/task.dart';

class NotificationService {
  NotificationService();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tzdata.initializeTimeZones();

    // ustawienie lokalnej strefy czasowej
    try {
      final String tzName = await FlutterTimezone.getLocalTimezone();
      final tz.Location loc = tz.getLocation(tzName);
      tz.setLocalLocation(loc);
    } catch (_) {
      // jeśli nie uda się uzyskać strefy czasowej urządzenia, ustawiamy domyślną UTC
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosInit = DarwinInitializationSettings();
    const InitializationSettings initSettings =
        InitializationSettings(android: androidInit, iOS: iosInit);
    await _plugin.initialize(initSettings);

    final AndroidFlutterLocalNotificationsPlugin? android =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      await android.requestNotificationsPermission();
    }
  }

  Future<void> scheduleForTask(Task task) async {
    // powiadomienie 1h lub 10min przed deadlinem.
    final tz.TZDateTime deadlineLocal =
        tz.TZDateTime.from(task.deadline, tz.local);
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);

    tz.TZDateTime when = deadlineLocal.subtract(const Duration(hours: 1));
    if (!when.isAfter(now)) {
      when = deadlineLocal.subtract(const Duration(minutes: 10));
    }
    // za późno na powiadomienie
    if (!when.isAfter(now)) {
      return;
    }

    await _plugin.zonedSchedule(
      task.id ?? task.deadline.millisecondsSinceEpoch,
      'Zbliża się deadline',
      task.title,
      when,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'deadlines_channel',
          'Deadlines',
          channelDescription: 'Przypomnienia o zbliżających się deadline\'ach',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: null,
    );
  }

  Future<void> cancelForTask(Task task) async {
    await _plugin.cancel(task.id ?? task.deadline.millisecondsSinceEpoch);
  }
}
