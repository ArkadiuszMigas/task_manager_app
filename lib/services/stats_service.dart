import 'package:collection/collection.dart';
import '../data/task.dart';

class StatsResult {
  final int completedCount;
  final String mostProductiveDay;
  final int mostProductiveCount; //Do zliczania zadań wykonanych w dni

  const StatsResult({
    required this.completedCount,
    required this.mostProductiveDay,
    required this.mostProductiveCount,
  });
}

class StatsService {
  const StatsService();

  StatsResult computeForCurrentWeek(List<Task> allTasks, {DateTime? now}) {
    final DateTime _now = now ?? DateTime.now();
    // Start tygodnia: poniedziałek 00:00
    final DateTime weekStart = DateTime(_now.year, _now.month, _now.day)
        .subtract(Duration(days: _now.weekday - DateTime.monday));
    final DateTime weekEnd = weekStart.add(const Duration(days: 7));

    // Wszystkie ukończone (globalnie – do licznika), ale do produktywności filtrujemy tydzień
    final List<Task> doneAll = allTasks.where((Task t) => t.done).toList();
    final int completedCount = doneAll.length;
    final Map<int, int> byWeekday = <int, int>{};
    // Zliczanie zadania wykonane w każdym dniu tygodnia
    for (final Task t in doneAll) {
      final DateTime when = t.completedAt ?? t.deadline;
      if (when.isBefore(weekStart) || !when.isBefore(weekEnd)) {
        continue; // poza tygodniem
      }
      byWeekday[when.weekday] = (byWeekday[when.weekday] ?? 0) + 1;
    }
    final MapEntry<int, int>? top = byWeekday.entries
        .sorted((a, b) => b.value.compareTo(a.value))
        .firstOrNull;
    final int bestWeekday = top?.key ?? DateTime.monday;
    final int bestCount = top?.value ?? 0;
    final String dayLabel = _weekdayToPl(bestWeekday);

    return StatsResult(
      completedCount: completedCount,
      mostProductiveDay: dayLabel,
      mostProductiveCount: bestCount,
    );
  }

  String _weekdayToPl(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Poniedziałek';
      case DateTime.tuesday:
        return 'Wtorek';
      case DateTime.wednesday:
        return 'Środa';
      case DateTime.thursday:
        return 'Czwartek';
      case DateTime.friday:
        return 'Piątek';
      case DateTime.saturday:
        return 'Sobota';
      case DateTime.sunday:
      default:
        return 'Niedziela';
    }
  }
}
