import '../../SQLite/sqlite.dart';
import 'package:flutter/material.dart';
import '../../JsonModels/task_model.dart';
import '../../widgets/custom_button.dart';
import 'package:animate_do/animate_do.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  late TextEditingController addTask;
  late DatabaseHelper helper;
  GlobalKey<FormState> key = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    addTask = TextEditingController();
    helper = DatabaseHelper();
  }

  @override
  void dispose() {
    addTask.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Task'),
      ),
      body: Form(
        key: key,
        child: Column(
          children: [
            const SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.all(30),
              child: FadeInUp(
                duration: const Duration(milliseconds: 1500),
                child: TextFormField(
                  cursorColor: const Color(0xff734a34),
                  controller: addTask,
                  textCapitalization: TextCapitalization.words,
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Content is required";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.add_task,
                        color: Colors.grey,
                      ),
                      labelText: 'Enter Task Name',
                      labelStyle: const TextStyle(color: Colors.grey),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                            width: 2, color: Color(0xff734a34)),
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Color(0xff734a34))),
                      errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.red)),
                      disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Color(0xff734a34))),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              width: 2, color: Color(0xff734a34)))),
                ),
              ),
            ),
            FadeInUp(
                duration: const Duration(milliseconds: 1000),
                delay: const Duration(milliseconds: 1300),
                child: Padding(
                  padding: const EdgeInsets.only(left: 30, right: 30),
                  child: CustomButton(
                      title: "Save Task",
                      onTap: () {
                        if (key.currentState!.validate()) {
                          String title = addTask.text;

                          addTask.clear();

                          helper
                              .createtask(TaskModel(
                                  taskTitle: title,
                                  createdAt: DateTime.now().toIso8601String()))
                              .whenComplete(() {
                            Navigator.of(context).pop(true);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Task Add Successfully!")));
                        }
                      }),
                ))
          ],
        ),
      ),
    );
  }
}
