import 'package:equatable/equatable.dart';

class Task extends Equatable {
  final int? id;
  final String title;
  final String? description;
  final DateTime deadline;
  final bool done;
  final DateTime? completedAt;

  const Task({
    this.id,
    required this.title,
    this.description,
    required this.deadline,
    this.done = false,
    this.completedAt,
  });

  Task copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? deadline,
    bool? done,
    DateTime? completedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      done: done ?? this.done,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'title': title,
      'description': description,
      'deadline': deadline.millisecondsSinceEpoch,
      'done': done ? 1 : 0,
      'completedAt': completedAt?.millisecondsSinceEpoch,
    };
  }

  static Task fromMap(Map<String, Object?> map) {
    final Object? idVal = map['id'];
    final Object? titleVal = map['title'];
    final Object? descVal = map['description'];
    final Object? deadlineVal = map['deadline'];
    final Object? doneVal = map['done'];
    final Object? completedVal = map['completedAt'];

    return Task(
      id: idVal is int ? idVal : (idVal is num ? idVal.toInt() : null),
      title: titleVal is String ? titleVal : '',
      description: descVal is String ? descVal : null,
      deadline: DateTime.fromMillisecondsSinceEpoch(
        deadlineVal is int ? deadlineVal : (deadlineVal is num ? deadlineVal.toInt() : 0),
      ),
      done: (doneVal is int ? doneVal : (doneVal is num ? doneVal.toInt() : 0)) == 1,
      completedAt: completedVal == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(
              completedVal is int ? completedVal : (completedVal is num ? completedVal.toInt() : 0),
            ),
    );
  }

  @override
  List<Object?> get props => <Object?>[id, title, description, deadline, done, completedAt];
}