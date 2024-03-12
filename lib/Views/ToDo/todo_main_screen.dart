import 'package:intl/intl.dart';
import '../../SQLite/sqlite.dart';
import 'package:flutter/material.dart';
import 'package:note_app/JsonModels/task_model.dart';
import 'package:note_app/Views/ToDo/detail_todo_screen.dart';
import 'package:note_app/Views/ToDo/add_todo_task_screen.dart';

// ignore_for_file: use_build_context_synchronously

// ignore_for_file: non_constant_identifier_names, must_be_immutable

// ignore_for_file: unnecessary_null_comparison

// ignore_for_file: deprecated_member_use, prefer_null_aware_operators

class ToDoMainScreen extends StatefulWidget {
  const ToDoMainScreen({super.key});

  @override
  State<ToDoMainScreen> createState() => _ToDoMainScreenState();
}

class _ToDoMainScreenState extends State<ToDoMainScreen> {
  late DatabaseHelper helper;
  late Future<List<TaskModel>> task;

  late TextEditingController search;

  @override
  void initState() {
    super.initState();

    search = TextEditingController();
    helper = DatabaseHelper();
    task = helper.fetchTaskData();

    helper.getTaskDb().whenComplete(() {
      task = getAllTasks();
    });
  }

  Future<List<TaskModel>> getAllTasks() async {
    return await helper.fetchTaskData();
  }

  Future<void> refresh() async {
    setState(() {
      task = getAllTasks();
    });
  }

  Future<List<TaskModel>> searchTask() {
    return helper.searchtasks(search.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
                color: const Color(0xff734a34).withOpacity(.2),
                borderRadius: BorderRadius.circular(8)),
            child: TextFormField(
              controller: search,
              onChanged: (value) {
                if (value.isNotEmpty) {
                  setState(() {
                    task = searchTask();
                  });
                } else {
                  setState(() {
                    task = getAllTasks();
                  });
                }
              },
              decoration: const InputDecoration(
                  border: InputBorder.none,
                  icon: Icon(Icons.search),
                  hintText: "Search"),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: FutureBuilder<List<TaskModel>>(
                future: task,
                builder: (context, AsyncSnapshot<List<TaskModel>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                    return const Center(child: Text("No Tasks Avaible"));
                  } else if (snapshot.hasError) {
                    return Center(child: Text(snapshot.error.toString()));
                  } else {
                    final items = snapshot.data ?? <TaskModel>[];
                    return ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Card(
                            shadowColor: const Color(0xff734a34),
                            elevation: 3,
                            child: ListTile(
                              leading: const Icon(
                                Icons.task,
                                size: 30,
                              ),
                              title: Text(
                                items[index].taskTitle.toString(),
                              ),
                              subtitle: Text(DateFormat("yMd").format(
                                  DateTime.parse(items[index].createdAt))),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ToDoUpdateScreen(
                                        taskName: items[index].taskTitle,
                                        taskId: items[index].taskId!,
                                      ),
                                    )).then((value) {
                                  if (value) {
                                    refresh();
                                  }
                                });
                              },
                            ),
                          ),
                        );
                      },
                    );
                  }
                }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff734a34),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const AddTaskScreen())).then((value) {
            if (value) {
              refresh();
            }
          });
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 35,
        ),
      ),
    );
  }
}
