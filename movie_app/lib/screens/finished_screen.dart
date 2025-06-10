import 'package:flutter/material.dart';
import 'package:movie_app/model/task.dart';
import 'package:movie_app/database/app_db.dart';

class FinishedTasksScreen extends StatefulWidget {
  const FinishedTasksScreen({super.key});

  @override
  State<FinishedTasksScreen> createState() => _FinishedTasksScreenState();
}

class _FinishedTasksScreenState extends State<FinishedTasksScreen> {
  List<Task> finishedTasks = [];

  @override
  void initState() {
    super.initState();
    loadFinishedTasks();
  }

  Future<void> loadFinishedTasks() async {
    final tasks = await TaskDatabase.instance.getTasks(isDone: true);
    setState(() {
      finishedTasks = tasks;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finished Shows'),
        backgroundColor: const Color.fromARGB(255, 25, 26, 25),
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: finishedTasks.length,
        itemBuilder: (context, index) {
  final task = finishedTasks[index];
  return Card(
    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    color: const Color.fromARGB(255, 35, 36, 35),
    child: ListTile(
      title: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 16,
          ),
          children: [
            TextSpan(text: task.title),
            if (task.showType == 'Series' && (task.season?.isNotEmpty ?? false) && (task.episode?.isNotEmpty ?? false))
              TextSpan(
                text: ' (S${task.season}E${task.episode})',
                style: const TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
          ],
        ),
      ),
      subtitle: task.finishedDate != null
          ? Text(
              'Finished on: ${task.finishedDate}',
              style: const TextStyle(color: Colors.white70),
            )
          : null,
    ),
  );
}
      ),
    );
  }
}