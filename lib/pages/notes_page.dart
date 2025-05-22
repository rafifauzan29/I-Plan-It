import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NotesPage extends StatefulWidget {
  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  List<Map<String, String>> _notes = [];
  final TextEditingController _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final String? notesString = prefs.getString('notes');

    if (notesString != null) {
      setState(() {
        _notes = List<Map<String, String>>.from(
          (json.decode(notesString) as List)
              .map((e) => Map<String, String>.from(e)),
        );
      });
    }
  }

  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedNotes = json.encode(_notes);
    await prefs.setString('notes', encodedNotes);
  }

  void _addNote(String title) {
    if (title.isNotEmpty) {
      setState(() {
        _notes.add({
          "title": title,
          "content": "",
        });
      });
      _saveNotes();
      _titleController.clear();
    }
  }

  void _deleteNoteAt(int index) {
    setState(() {
      _notes.removeAt(index);
    });
    _saveNotes();
  }

  void _navigateToNoteDetail(Map<String, String> note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteDetailPage(
          note: note,
          onSave: (updatedContent) {
            setState(() {
              note["content"] = updatedContent;
            });
            _saveNotes();
          },
        ),
      ),
    );
  }

  void _showAddNoteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Note'),
          content: TextField(
            controller: _titleController,
            decoration: const InputDecoration(hintText: 'Note title'),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Add'),
              onPressed: () {
                _addNote(_titleController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Notes',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.brown,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _notes.isEmpty
                  ? const Center(
                      child: Text(
                        'No notes yet. Add your notes!',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _notes.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(
                              _notes[index]["title"] ?? "",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteNoteAt(index),
                            ),
                            onTap: () => _navigateToNoteDetail(_notes[index]),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: _showAddNoteDialog,
      ),
    );
  }
}

class NoteDetailPage extends StatefulWidget {
  final Map<String, String> note;
  final Function(String) onSave;

  NoteDetailPage({required this.note, required this.onSave});

  @override
  _NoteDetailPageState createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.note["content"]);
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note["title"] ?? ""),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              widget.onSave(_contentController.text);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: _contentController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Write your notes here...',
          ),
          maxLines: null,
          keyboardType: TextInputType.multiline,
        ),
      ),
    );
  }
}
