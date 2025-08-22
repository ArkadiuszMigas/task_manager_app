import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/task.dart';

// Strona do edycji lub tworzenia nowego zadania
// Tytuł, opis i terminu zadania

class EditTaskPage extends StatefulWidget {
  final Task? initial;
  const EditTaskPage({super.key, this.initial});

  @override
  State<EditTaskPage> createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _description;
  DateTime _deadline = DateTime.now().add(const Duration(hours: 2));

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.initial?.title ?? '');
    _description = TextEditingController(text: widget.initial?.description ?? '');
    _deadline = widget.initial?.deadline ?? _deadline;
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final DateTime now = DateTime.now();
    final DateTime firstDate = now.subtract(const Duration(days: 1));

    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _deadline.isAfter(now) ? _deadline : now,
      firstDate: firstDate,
      lastDate: now.add(const Duration(days: 365 * 5)),
    );
    if (date == null) return;

    final TimeOfDay initialTime = TimeOfDay(hour: _deadline.hour, minute: _deadline.minute);
    final TimeOfDay? time = await showTimePicker(context: context, initialTime: initialTime);
    if (time == null) return;

    setState(() {
      _deadline = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final Task result = Task(
      id: widget.initial?.id,
      title: _title.text.trim(),
      description: _description.text.trim().isEmpty ? null : _description.text.trim(),
      deadline: _deadline,
      done: widget.initial?.done ?? false,
      completedAt: widget.initial?.completedAt,
    );
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat df = DateFormat('dd.MM.yyyy HH:mm');
    return Scaffold(
      appBar: AppBar(title: Text(widget.initial == null ? 'Nowe zadanie' : 'Edytuj zadanie')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Tytuł', border: OutlineInputBorder()),
              validator: (String? v) => (v == null || v.trim().isEmpty) ? 'Podaj tytuł' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _description,
              decoration: const InputDecoration(labelText: 'Opis (opcjonalnie)', border: OutlineInputBorder()),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Deadline'),
              subtitle: Text(df.format(_deadline)),
              trailing: FilledButton.tonal(
                onPressed: _pickDateTime,
                child: const Text('Zmień'),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: _save, child: const Text('Zapisz')),
          ],
        ),
      ),
    );
  }
}