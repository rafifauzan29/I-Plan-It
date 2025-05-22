import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

class Task {
  String name;
  bool isCompleted;

  Task({required this.name, required this.isCompleted});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'isCompleted': isCompleted,
    };
  }

  static Task fromMap(Map<String, dynamic> map) {
    return Task(
      name: map['name'],
      isCompleted: map['isCompleted'],
    );
  }
}

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? encodedTasks = prefs.getStringList('tasks');
    if (encodedTasks != null) {
      setState(() {
        tasks = encodedTasks
            .map((task) =>
                Task.fromMap(jsonDecode(task) as Map<String, dynamic>))
            .toList();
      });
    }
  }

  int get totalTasks => tasks.length;

  int get completedTasks => tasks.where((task) => task.isCompleted).length;

  int get pendingTasks => tasks.where((task) => !task.isCompleted).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Dashboard',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 26,
              color: Colors.brown,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kalender',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 5,
                    spreadRadius: 1,
                  ),
                ],
                borderRadius: BorderRadius.circular(10),
              ),
              child: TableCalendar(
                focusedDay: DateTime.now(),
                firstDay: DateTime(2000),
                lastDay: DateTime(2100),
                calendarFormat: CalendarFormat.month,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Statistik',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatCard(
                    'Tugas Selesai', '$completedTasks', Colors.green),
                _buildStatCard('Tugas Belum', '$pendingTasks', Colors.red),
                _buildStatCard('Total Tugas', '$totalTasks', Colors.blue),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Tugas Mendatang',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tasks.where((task) => !task.isCompleted).length,
              itemBuilder: (context, index) {
                var task =
                    tasks.where((task) => !task.isCompleted).toList()[index];
                return _buildTaskTile(task.name, task.isCompleted);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String count, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color),
      ),
      child: Column(
        children: [
          Text(
            count,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: TextStyle(fontSize: 14, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskTile(String task, bool isCompleted) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        leading: Icon(
          isCompleted ? Icons.check_circle : Icons.list_alt,
          color: isCompleted ? Colors.green : Colors.grey,
        ),
        title: Text(
          task,
          style: TextStyle(
            decoration: isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        trailing: isCompleted
            ? const Text(
                'Selesai',
                style:
                    TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              )
            : const Text(
                'Belum',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: DashboardPage(),
    theme: ThemeData(primarySwatch: Colors.blue),
  ));
}
