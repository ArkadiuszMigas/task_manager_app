import 'package:flutter/material.dart';
import '../../data/task.dart';
import 'package:intl/intl.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final ValueChanged<bool> onToggleDone;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const TaskTile({
    super.key,
    required this.task,
    required this.onToggleDone,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final DateFormat df = DateFormat('dd.MM.yyyy HH:mm');
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: ListTile(
        leading: Checkbox(
          value: task.done,
          onChanged: (bool? v) => onToggleDone(v ?? false),
          shape: const CircleBorder(),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.done ? TextDecoration.lineThrough : TextDecoration.none,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text('Do: ${df.format(task.deadline)}${task.description != null && task.description!.isNotEmpty ? '\n${task.description}' : ''}'),
        isThreeLine: task.description != null && task.description!.isNotEmpty,
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: onDelete,
        ),
        onTap: onTap,
      ),
    );
  }
}