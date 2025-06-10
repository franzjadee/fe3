import 'package:flutter/material.dart';
import 'package:movie_app/model/task.dart';
import 'package:movie_app/database/app_db.dart';
import 'package:movie_app/screens/finished_screen.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Task> todoList = [];
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _seasonController = TextEditingController();
  final TextEditingController _episodeController = TextEditingController();

  String _selectedType = 'Movie'; // default
  int updateIndex = -1;

  @override
  void initState() {
    super.initState();
    refreshList();
  }

  Future<void> refreshList() async {
    final tasks = await TaskDatabase.instance.getTasks(isDone: false);
    setState(() {
      todoList = tasks;
    });
  }

  Future<void> addList(String title) async {
    if (title.trim().isEmpty) return;

    final task = Task(
      title: title,
      isDone: false,
      finishedDate: null,
      showType: _selectedType,
      season: _selectedType == 'Series' ? _seasonController.text : null,
      episode: _selectedType == 'Series' ? _episodeController.text : null,
    );

    await TaskDatabase.instance.insertTask(task);
    _controller.clear();
    _seasonController.clear();
    _episodeController.clear();
    setState(() => _selectedType = 'Movie');
    refreshList();
  }

  Future<void> updateListItem(String title, int index) async {
  final task = todoList[index];
  final updatedTask = task.copyWith(
    title: title,
    showType: _selectedType,
    season: _selectedType == 'Series' ? _seasonController.text : null,
    episode: _selectedType == 'Series' ? _episodeController.text : null,
  );

  await TaskDatabase.instance.updateTask(updatedTask);
  updateIndex = -1;
  _controller.clear();
  _seasonController.clear();
  _episodeController.clear();
  setState(() => _selectedType = 'Movie');
  refreshList();
}


  Future<void> deleteItem(int index) async {
    await TaskDatabase.instance.deleteTask(todoList[index].id!);
    refreshList();
  }

  Future<void> toggleDone(int index) async {
    final task = todoList[index];

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm"),
        content: const Text("Mark this Show as finished?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Confirm")),
        ],
      ),
    );

    if (confirm != true) return;

    final finishedDate = DateFormat.yMMMd().format(DateTime.now());
    final updatedTask = task.copyWith(isDone: true, finishedDate: finishedDate);
    await TaskDatabase.instance.updateTask(updatedTask);
    refreshList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('SHOWGANIZER', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 25, 26, 25),
        foregroundColor: const Color.fromARGB(255, 206, 201, 201),
        actions: [
          IconButton(
            icon: const Icon(Icons.checklist),
            tooltip: 'View Finished Tasks',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FinishedTasksScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(), // dismiss keyboard on tap
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: todoList.length,
                    itemBuilder: (context, index) {
                      final task = todoList[index];
                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        color: const Color.fromARGB(255, 44, 44, 44),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.only(left: 20),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          decoration: task.isDone ? TextDecoration.lineThrough : TextDecoration.none,
                                        ),
                                        children: [
                                          TextSpan(text: task.title),
                                          if (task.showType == 'Series' && (task.season?.isNotEmpty ?? false) && (task.episode?.isNotEmpty ?? false))
                                            TextSpan(
                                              text: ' (S${task.season}E${task.episode})',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.normal,
                                                fontSize: 16,
                                                color: Colors.white70,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    if (task.isDone && task.finishedDate != null)
                                      Text(
                                        'Finished on: ${task.finishedDate}',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  task.isDone ? Icons.check_circle : Icons.check_circle_outline,
                                  color: Colors.white,
                                  size: 30,
                                ),
                                onPressed: () => toggleDone(index),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.white, size: 30),
                                onPressed: () {
                                  _controller.text = task.title;
                                  _selectedType = task.showType ?? 'Movie';
                                  _seasonController.text = task.season ?? '';
                                  _episodeController.text = task.episode ?? '';
                                  setState(() {
                                    updateIndex = index;
                                  });
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.white, size: 30),
                                onPressed: () => deleteItem(index),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                buildInputSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              flex: 5,
              child: TextFormField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: 'Add Show...',
                  labelStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color.fromARGB(255, 30, 31, 30)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              flex: 3,
              child: DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(labelText: 'Type'),
                items: ['Movie', 'Series']
                    .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
              ),
            ),
            const SizedBox(width: 5),
            FloatingActionButton(
              backgroundColor: const Color.fromARGB(255, 49, 49, 49),
              foregroundColor: Colors.white,
              onPressed: () {
                updateIndex != -1
                    ? updateListItem(_controller.text, updateIndex)
                    : addList(_controller.text);
              },
              child: Icon(updateIndex != -1 ? Icons.edit : Icons.add),
            ),
          ],
        ),
        if (_selectedType == 'Series') ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _seasonController,
                  keyboardType: TextInputType.number,
inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(labelText: 'Season'),
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: TextFormField(
                  controller: _episodeController,
                  keyboardType: TextInputType.number,
inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(labelText: 'Episode'),
                ),
              ),
            ],
          ),
        ]
      ],
    );
  }
}
