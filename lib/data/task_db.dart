import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'task.dart';
import '../services/app_events.dart';

//Zarzadzanie bazy danych

class TaskDb {
  static const String _dbName = 'tasks.db';
  static const int _dbVersion = 1;

  static const String _table = 'tasks';

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db as Database;
    _db = await _initDb();
    return _db as Database;
  }

  Future<Database> _initDb() async {
    final String dir = (await getApplicationDocumentsDirectory()).path;
    final String path = p.join(dir, _dbName);

    final Database db = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE $_table (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            description TEXT,
            deadline INTEGER NOT NULL,
            done INTEGER NOT NULL DEFAULT 0,
            completedAt INTEGER
          )
        ''');
      },
    );
    return db;
  }

  Future<int> insertTask(Task task) async {
    final Database db = await database;
    final int id = await db.insert(_table, task.toMap());
    AppEvents.I.emit(AppEvent.tasksChanged);
    return id;
  }

  Future<int> updateTask(Task task) async {
    final Database db = await database;
    final int n = await db.update(_table, task.toMap(), where: 'id = ?', whereArgs: <Object?>[task.id]);
    AppEvents.I.emit(AppEvent.tasksChanged);
    return n;
  }

  Future<int> deleteTask(int id) async {
    final Database db = await database;
    final int n = await db.delete(_table, where: 'id = ?', whereArgs: <Object?>[id]);
    AppEvents.I.emit(AppEvent.tasksChanged);
    return n;
  }

  Future<List<Task>> getAllTasks() async {
    final Database db = await database;
    final List<Map<String, Object?>> rows = await db.query(_table);
    final List<Task> tasks = rows.map((Map<String, Object?> r) => Task.fromMap(r)).toList();
    tasks.sort((Task a, Task b) => a.deadline.compareTo(b.deadline));
    return tasks;
  }

  Future<List<Task>> getPendingTasks() async {
    final Database db = await database;
    final List<Map<String, Object?>> rows = await db.query(_table, where: 'done = 0');
    final List<Task> tasks = rows.map((Map<String, Object?> r) => Task.fromMap(r)).toList();
    tasks.sort((Task a, Task b) => a.deadline.compareTo(b.deadline));
    return tasks;
  }

  Future<List<Task>> getCompletedTasks() async {
    final Database db = await database;
    final List<Map<String, Object?>> rows = await db.query(_table, where: 'done = 1');
    final List<Task> tasks = rows.map((Map<String, Object?> r) => Task.fromMap(r)).toList();
    tasks.sort((Task a, Task b) => (b.completedAt ?? b.deadline).compareTo(a.completedAt ?? a.deadline));
    return tasks;
  }

  Future<void> toggleDone(Task task, {required bool done}) async {
    final Task updated = task.copyWith(done: done, completedAt: done ? DateTime.now() : null);
    await updateTask(updated);
    AppEvents.I.emit(AppEvent.tasksChanged);
  }
}