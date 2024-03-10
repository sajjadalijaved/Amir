import 'dart:developer';
import 'package:path/path.dart';
import '../JsonModels/user.dart';
import 'package:sqflite/sqflite.dart';
import 'package:note_app/JsonModels/task_model.dart';
import 'package:note_app/JsonModels/note_model.dart';

class DatabaseHelper {
  static Database? database;
  final databaseName = "note.db";
  final databaseTask = "task.db";
  static String tableName = "notes_tb";
  static String tasktable = "tasks_tb";
  static String usersTableName = "users_tb";
  String noteTable =
      "CREATE TABLE $tableName(noteId INTEGER PRIMARY KEY AUTOINCREMENT, noteTitle TEXT NOT NULL, noteContent TEXT NOT NULL, createdAt TEXT DEFAULT CURRENT_TIMESTAMP)";
  String dropTableNotes = 'DROP TABLE IF EXISTS $tableName';
  String dropTableUsers = 'DROP TABLE IF EXISTS $usersTableName';

  String taskTable =
      "CREATE TABLE $tasktable(taskId INTEGER PRIMARY KEY AUTOINCREMENT, taskTitle TEXT NOT NULL, createdAt TEXT DEFAULT CURRENT_TIMESTAMP)";
  String dropTabletask = 'DROP TABLE IF EXISTS $tasktable';

  String usersTable =
      "CREATE TABLE $usersTableName(usrId INTEGER PRIMARY KEY AUTOINCREMENT, usrFullName TEXT, usrPassword TEXT, usrEmail TEXT UNIQUE)";

  Future<Database> notesDB() async {
    if (database == null) {
      database =
          await openDatabase(join(await getDatabasesPath(), databaseName),
              onCreate: (db, version) {
        db.execute(usersTable);
        db.execute(noteTable);

        log('******************OnCreate Notes ^^^^^^^^^^^^^^^^^^^^^^^^^ ');
      }, onUpgrade: (db, oldVersion, newVersion) {
        if (oldVersion != newVersion) {
          db.execute(dropTableNotes);
          db.execute(noteTable);
          db.execute(dropTableUsers);
          db.execute(usersTable);
        }
      }, version: 1);
      return Future.value(database);
    }
    return Future.value(database);
  }

  // tasks database
  Future<Database> tasksDB() async {
    if (database == null) {
      database =
          await openDatabase(join(await getDatabasesPath(), databaseTask),
              onCreate: (db, version) {
        db.execute(taskTable); // Create the tasks table

        log('******************OnCreate Task^^^^^^^^^^^^^^^^^^^^^^^^^ ');
      }, onUpgrade: (db, oldVersion, newVersion) {
        if (oldVersion != newVersion) {
          db.execute(dropTabletask);
          db.execute(taskTable);
        }
      }, version: 2); // Incremented version for tasksDB
      return Future.value(database);
    }
    return Future.value(database);
  }

  // Login user
  Future<bool> loginUser(Users user) async {
    try {
      Database? database = await notesDB();
      dynamic result = await database.rawQuery(
          "select * from $usersTableName where usrEmail = '${user.usrEmail}' AND usrPassword = '${user.usrPassword}'");

      if (result.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      log("Login User Error : $e");
      return false;
    }
  }

  // Sign Up user
  Future<bool> signUpUser(Users user) async {
    try {
      Database? database = await notesDB();

      int result = await database.insert(
        usersTableName,
        user.toMap(),
      );
      log('*************************Create Users data*******************');

      if (result < 0) {
        return false;
      }
      return true;
    } catch (e) {
      log("insert Users Error : $e");
      return false;
    }
  }

  //Get current User details
  Future<Users?> getUser(String usrName) async {
    final Database db = await notesDB();
    var res = await db
        .query(usersTableName, where: "usrEmail = ?", whereArgs: [usrName]);
    return res.isNotEmpty ? Users.fromMap(res.first) : null;
  }

// search notes
  Future<List<NoteModel>> searchNotes(String search) async {
    final Database database = await notesDB();
    List<Map<String, Object?>> searchResult = await database.rawQuery(
        "select * from $tableName where noteTitle LIKE ?", ["%$search%"]);
    return searchResult.map((e) => NoteModel.fromMap(e)).toList();
  }

  // search tasks
  Future<List<TaskModel>> searchtasks(String search) async {
    final Database database = await tasksDB();
    List<Map<String, Object?>> searchResult = await database.rawQuery(
        "select * from $taskTable where taskTitle LIKE ?", ["%$search%"]);
    return searchResult.map((e) => TaskModel.fromMap(e)).toList();
  }

// create notes method
  Future<bool> createNote(NoteModel note) async {
    try {
      Database? database = await notesDB();
      int result = await database.insert(
        tableName,
        note.toMap(),
      );
      log('*************************CreateNote data*******************');

      if (result < 0) {
        return false;
      }
      return true;
    } catch (e) {
      log("insertData Error : $e");
      return false;
    }
  }

  // create tasks method
  Future<bool> createtask(TaskModel task) async {
    try {
      Database? database = await tasksDB();
      int result = await database.insert(
        taskTable,
        task.toMap(),
      );
      log('*************************CreateNote data*******************');

      if (result < 0) {
        return false;
      }
      return true;
    } catch (e) {
      log("insertData Error : $e");
      return false;
    }
  }

  // Get notes
  Future<List<NoteModel>> fetchData() async {
    Database? database = await notesDB();
    List list = await database.query(tableName);
    return list.map((map) => NoteModel.fromMap(map)).toList();
  }

  // Get tasks
  Future<List<TaskModel>> fetchTaskData() async {
    await tasksDB(); // Ensure the tasks table is created
    Database? database = await tasksDB();
    List<Map<String, dynamic>> list = await database.query(taskTable);
    return list.map((map) => TaskModel.fromMap(map)).toList();
  }

  // delete one note from database
  Future<bool> daleteOneDataItem(int id) async {
    try {
      Database? database = await notesDB();
      int rows = await database
          .delete(tableName, where: 'noteId = ?', whereArgs: [id]);

      if (rows < 0) {
        return false;
      }
      return true;
    } catch (e) {
      log("daleteOneDataItem Error : $e");
      return false;
    }
  }

  // delete one task from database
  Future<bool> daleteOneTaskItem(int id) async {
    try {
      Database? database = await tasksDB();
      int rows = await database
          .delete(taskTable, where: 'taskId = ?', whereArgs: [id]);

      if (rows < 0) {
        return false;
      }
      return true;
    } catch (e) {
      log("daleteOneTaskItem Error : $e");
      return false;
    }
  }

  // delete all table
  Future<bool> daleteAllData() async {
    try {
      Database? database = await notesDB();
      int rows = await database.delete(tableName);

      if (rows < 0) {
        return false;
      }
      return true;
    } catch (e) {
      log("daleteAllData Error : $e");
      return false;
    }
  }

  // update note
  Future<int> updateNote(title, content, noteId) async {
    final Database db = await notesDB();
    return db.rawUpdate(
        'update $tableName set noteTitle = ?, noteContent = ? where noteId = ?',
        [title, content, noteId]);
  }

  // update task
  Future<int> updateTask(task, taskId) async {
    final Database db = await tasksDB();
    return db.rawUpdate('update $taskTable set taskTitle = ?, where taskId = ?',
        [task, taskId]);
  }
}
