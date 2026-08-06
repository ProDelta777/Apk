import 'package:flutter/material.dart';
import 'package:pro_army/services/database_helper.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({Key? key}) : super(key: key);

  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _notes = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshNotes();
  }

  void _refreshNotes() async {
    final data = await dbHelper.queryAllNotes();
    setState(() {
      _notes = data;
    });
  }

  void _addNote() async {
    if (_titleController.text.isNotEmpty && _contentController.text.isNotEmpty) {
      Map<String, dynamic> row = {
        'title': _titleController.text,
        'content': _contentController.text,
        'timestamp': DateTime.now().toIso8601String(),
      };
      await dbHelper.insertNote(row);
      _titleController.clear();
      _contentController.clear();
      _refreshNotes();
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  void _showAddNoteDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text('Add Field Note', style: TextStyle(color: Colors.green)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Title', labelStyle: TextStyle(color: Colors.green)),
              ),
              TextField(
                controller: _contentController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Content', labelStyle: TextStyle(color: Colors.green)),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
            ElevatedButton(onPressed: _addNote, style: ElevatedButton.styleFrom(backgroundColor: Colors.green), child: const Text('Save')),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Field Notes')),
      body: _notes.isEmpty
          ? const Center(child: Text('No notes found. Create one.'))
          : ListView.builder(
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                return Card(
                  color: const Color(0xFF1E1E1E),
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(_notes[index]['title'], style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    subtitle: Text(_notes[index]['content'], style: const TextStyle(color: Colors.white70)),
                    trailing: Text(
                      _notes[index]['timestamp'].toString().substring(0, 10),
                      style: const TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddNoteDialog,
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
