import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class TaskPage extends StatefulWidget {
  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final List<Map<String, dynamic>> _tasks = [];
  final TextEditingController _taskNameController = TextEditingController();
  final TextEditingController _taskDescriptionController =
      TextEditingController();
  DateTime? _selectedDeadline;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _saveTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> encodedTasks = _tasks.map((task) => jsonEncode(task)).toList();
    await prefs.setStringList('tasks', encodedTasks);
  }

  Future<void> _loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? encodedTasks = prefs.getStringList('tasks');
    if (encodedTasks != null) {
      setState(() {
        _tasks.clear();
        _tasks.clear();
        _tasks.addAll(encodedTasks
            .map((task) => jsonDecode(task) as Map<String, dynamic>)
            .toList());
      });
    }
  }

  void _addTask(String name, String description, DateTime deadline) {
    if (name.isNotEmpty && description.isNotEmpty) {
      setState(() {
        _tasks.add({
          "name": name,
          "description": description,
          "deadline": deadline.toIso8601String(),
          "isCompleted": false,
        });
      });
      _saveTasks();
      _taskNameController.clear();
      _taskDescriptionController.clear();
      _selectedDeadline = null;
    }
  }

  void _editTask(int index) {
    _taskNameController.text = _tasks[index]["name"] ?? "";
    _taskDescriptionController.text = _tasks[index]["description"] ?? "";
    _selectedDeadline = DateTime.parse(_tasks[index]["deadline"]);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _taskNameController,
                decoration: const InputDecoration(hintText: 'Task name'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _taskDescriptionController,
                decoration: const InputDecoration(hintText: 'Task description'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _selectDeadline,
                child: Text(_selectedDeadline == null
                    ? 'Select Deadline'
                    : 'Deadline: ${DateFormat('yyyy-MM-dd – kk:mm').format(_selectedDeadline!)}'),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Save'),
              onPressed: () {
                setState(() {
                  _tasks[index] = {
                    "name": _taskNameController.text,
                    "description": _taskDescriptionController.text,
                    "deadline": _selectedDeadline!.toIso8601String(),
                    "isCompleted": _tasks[index]["isCompleted"],
                  };
                });
                _saveTasks();
                _taskNameController.clear();
                _taskDescriptionController.clear();
                _selectedDeadline = null;
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _selectDeadline() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime:
            TimeOfDay.fromDateTime(_selectedDeadline ?? DateTime.now()),
      );
      if (pickedTime != null) {
        setState(() {
          _selectedDeadline = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _showAddTaskDialog() {
    _selectedDeadline = null;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _taskNameController,
                decoration: const InputDecoration(hintText: 'Task name'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _taskDescriptionController,
                decoration: const InputDecoration(hintText: 'Task description'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _selectDeadline,
                child: Text(_selectedDeadline == null
                    ? 'Select Deadline'
                    : 'Deadline: ${DateFormat('yyyy-MM-dd – kk:mm').format(_selectedDeadline!)}'),
              ),
            ],
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
                if (_selectedDeadline != null) {
                  _addTask(_taskNameController.text,
                      _taskDescriptionController.text, _selectedDeadline!);
                }
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
              'Your Tasks',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.brown,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _tasks.isEmpty
                  ? const Center(
                      child: Text(
                        'No tasks yet. Add your tasks!',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _tasks.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: Icon(
                              (_tasks[index]["isCompleted"] ?? false)
                                  ? Icons.check_circle
                                  : Icons.check_circle_outline_outlined,
                              color: (_tasks[index]["isCompleted"] ?? false)
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            title: Text(
                              _tasks[index]["name"] ?? "",
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _tasks[index]["description"] ?? "",
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.grey),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Deadline: ${DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.parse(_tasks[index]["deadline"]))}',
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.orange),
                                  onPressed: () {
                                    _editTask(index);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Delete Task'),
                                        content: const Text(
                                            'Apakah kamu yakin ingin menghapus tugas ini?'),
                                        actions: [
                                          TextButton(
                                            child: const Text('Cancel'),
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                          ),
                                          TextButton(
                                            child: const Text('Delete'),
                                            onPressed: () {
                                              setState(() {
                                                _tasks.removeAt(index);
                                              });
                                              _saveTasks();
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: Icon(
                                    (_tasks[index]["isCompleted"] ?? false)
                                        ? Icons.undo
                                        : Icons.check,
                                    color:
                                        (_tasks[index]["isCompleted"] ?? false)
                                            ? Colors.grey
                                            : Colors.green,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _tasks[index]["isCompleted"] =
                                          !(_tasks[index]["isCompleted"] ??
                                              false);
                                    });
                                    _saveTasks();
                                  },
                                ),
                              ],
                            ),
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
        onPressed: _showAddTaskDialog,
      ),
    );
  }
}
