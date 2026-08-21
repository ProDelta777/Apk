import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Reminder {
  final String id;
  final String title;
  final String note;
  final DateTime date;
  bool isCompleted;

  Reminder({
    required this.id,
    required this.title,
    required this.note,
    required this.date,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'note': note,
    'date': date.toIso8601String(),
    'isCompleted': isCompleted,
  };

  factory Reminder.fromJson(Map<String, dynamic> json) => Reminder(
    id: json['id'],
    title: json['title'],
    note: json['note'] ?? '',
    date: DateTime.parse(json['date']),
    isCompleted: json['isCompleted'] ?? false,
  );
}

class LocalRemindersScreen extends StatefulWidget {
  const LocalRemindersScreen({super.key});

  @override
  State<LocalRemindersScreen> createState() => _LocalRemindersScreenState();
}

class _LocalRemindersScreenState extends State<LocalRemindersScreen> {
  List<Reminder> _reminders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? remindersJson = prefs.getString('offline_reminders');
      if (remindersJson != null) {
        final List<dynamic> decoded = jsonDecode(remindersJson);
        setState(() {
          _reminders = decoded.map((e) => Reminder.fromJson(e)).toList();
        });
      }
    } catch (e) {
      debugPrint("Error loading reminders: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveReminders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = jsonEncode(_reminders.map((e) => e.toJson()).toList());
      await prefs.setString('offline_reminders', encoded);
    } catch (e) {
      debugPrint("Error saving reminders: $e");
    }
  }

  void _addReminder(String title, String note, DateTime date) {
    setState(() {
      _reminders.add(Reminder(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        note: note,
        date: date,
      ));
      _reminders.sort((a, b) => a.date.compareTo(b.date));
    });
    _saveReminders();
  }

  void _deleteReminder(String id) {
    setState(() {
      _reminders.removeWhere((r) => r.id == id);
    });
    _saveReminders();
  }

  void _toggleCompleted(String id) {
    setState(() {
      final index = _reminders.indexWhere((r) => r.id == id);
      if (index != -1) {
        _reminders[index].isCompleted = !_reminders[index].isCompleted;
      }
    });
    _saveReminders();
  }

  Future<void> _showAddDialog() async {
    final titleCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(hours: 1));

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('New Reminder'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: noteCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Note (Optional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Date & Time'),
                      subtitle: Text(
                        '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')} ${selectedDate.hour.toString().padLeft(2, '0')}:${selectedDate.minute.toString().padLeft(2, '0')}',
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                        );
                        if (date != null && mounted) {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(selectedDate),
                          );
                          if (time != null) {
                            setDialogState(() {
                              selectedDate = DateTime(
                                date.year, date.month, date.day, time.hour, time.minute,
                              );
                            });
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('CANCEL'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (titleCtrl.text.trim().isNotEmpty) {
                      _addReminder(titleCtrl.text.trim(), noteCtrl.text.trim(), selectedDate);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('SAVE'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final upcoming = _reminders.where((r) => !r.isCompleted).toList();
    final completed = _reminders.where((r) => r.isCompleted).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Reminders'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reminders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.alarm_off, size: 64, color: theme.hintColor),
                      const SizedBox(height: 16),
                      Text(
                        'No Reminders',
                        style: theme.textTheme.titleLarge?.copyWith(color: theme.hintColor),
                      ),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (upcoming.isNotEmpty) ...[
                      Text('Upcoming', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ...upcoming.map((r) => _buildReminderCard(r, theme)),
                      const SizedBox(height: 24),
                    ],
                    if (completed.isNotEmpty) ...[
                      Text('Completed', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey)),
                      const SizedBox(height: 8),
                      ...completed.map((r) => _buildReminderCard(r, theme)),
                    ],
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildReminderCard(Reminder r, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: r.isCompleted ? theme.colorScheme.surfaceVariant.withOpacity(0.1) : theme.colorScheme.surfaceVariant.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: ListTile(
        leading: Checkbox(
          value: r.isCompleted,
          onChanged: (_) => _toggleCompleted(r.id),
        ),
        title: Text(
          r.title,
          style: TextStyle(
            decoration: r.isCompleted ? TextDecoration.lineThrough : null,
            color: r.isCompleted ? Colors.grey : null,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (r.note.isNotEmpty)
              Text(
                r.note,
                style: TextStyle(color: r.isCompleted ? Colors.grey : theme.hintColor),
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: r.isCompleted ? Colors.grey : theme.colorScheme.primary),
                const SizedBox(width: 4),
                Text(
                  '${r.date.year}-${r.date.month.toString().padLeft(2, '0')}-${r.date.day.toString().padLeft(2, '0')} ${r.date.hour.toString().padLeft(2, '0')}:${r.date.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 12,
                    color: r.isCompleted ? Colors.grey : theme.colorScheme.primary,
                  ),
                ),
              ],
            )
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () => _deleteReminder(r.id),
        ),
      ),
    );
  }
}
