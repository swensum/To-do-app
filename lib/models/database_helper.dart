import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:todo_list/models/task_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tasks.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
  path,
  version: 2, // 👈 increment version
  onCreate: _createDB,
  onUpgrade: _upgradeDB,
);
  }

  Future _createDB(Database db, int version) async {
  await db.execute('''
    CREATE TABLE tasks (
      id TEXT PRIMARY KEY,
      title TEXT NOT NULL,
      category TEXT NOT NULL,
      dateTime TEXT NOT NULL,
      notes TEXT,
      isReminderOn INTEGER NOT NULL,
      reminderOption TEXT,
      repeatFrequency TEXT,
      isCompleted INTEGER,
      subtasks TEXT,
      subtasksCompleted TEXT
    )
  ''');
}
Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
  if (oldVersion < 2) {
    await db.execute('ALTER TABLE tasks ADD COLUMN notes TEXT');
    await db.execute('ALTER TABLE tasks ADD COLUMN isCompleted INTEGER');
    await db.execute('ALTER TABLE tasks ADD COLUMN subtasksCompleted TEXT');
  }
}


  Future<int> insertTask(Task task) async {
    final db = await instance.database;
    return await db.insert('tasks', task.toMap());
  }
Future<List<Task>> getAllTasks() async {
  try {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('tasks');
    return List.generate(maps.length, (i) {
      return Task.fromMap(maps[i]);
    });
  } catch (e) {
    debugPrint('Error loading tasks: $e');
    return [];
  }
}

Future<int> updateTask(Task task) async {
  final db = await instance.database;
  return await db.update(
    'tasks',
    task.toMap(),
    where: 'id = ?',
    whereArgs: [task.id],
  );
}

Future<int> deleteTask(String id) async {
  final db = await instance.database;
  return await db.delete(
    'tasks',
    where: 'id = ?',
    whereArgs: [id],
  );
}
  Future<int> deleteAllCompletedTasks() async {
  final db = await instance.database;
  return await db.delete(
    'tasks',
    where: 'isCompleted = ?',
    whereArgs: [1],
  );
}

}