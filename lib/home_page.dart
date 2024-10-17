import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:notes_app_hive/data/database.dart';
import 'package:notes_app_hive/utils/show_dialog.dart';
import 'package:notes_app_hive/utils/to_do_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ToDoDatabase db = ToDoDatabase();
  final _myBox = Hive.box('myBox');
  final newTaskController = TextEditingController();

  @override
  void initState() {
    if (_myBox.get("TODOLIST") == null) {
      db.createInitialData();
    } else {
      db.loadData();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow.shade200,
      appBar: AppBar(
        title: const Text('TO DO APP'),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: db.toDoList.length,
        itemBuilder: (context, index) {
          return ToDoTile(
            taskName: db.toDoList[index][0],
            isSelected: db.toDoList[index][1],
            onChanged: (value) {
              checkBoxChanged(value!, index);
            },
            deleteTask: (buildContext) {
              deleteNewTask(index);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          openDialogBox();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void checkBoxChanged(bool value, int index) {
    setState(() {
      db.toDoList[index][1] = !db.toDoList[index][1];
    });
    db.updateData();
  }

  void openDialogBox() {
    showDialog(
        context: context,
        builder: (context) {
          return ShowDialog(
            controller: newTaskController,
            onSave: saveNewTask,
            onCancel: () {
              newTaskController.clear();
              Navigator.of(context).pop();
            },
          );
        });
  }

  void saveNewTask() {
    setState(() {
      if (newTaskController.text.isEmpty) {
        return;
      } else {
        db.toDoList.add([newTaskController.text, false]);
        newTaskController.clear();
      }
    });
    Navigator.of(context).pop();
    db.updateData();
  }

  void deleteNewTask(int index) {
    setState(() {
      db.toDoList.removeAt(index);
    });
    db.updateData();
  }
}
