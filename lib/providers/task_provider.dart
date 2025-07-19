import 'package:flutter/material.dart';

import 'package:todo_list/models/database_helper.dart';
import 'package:todo_list/models/task_model.dart'; 

class TaskProvider extends ChangeNotifier {
  final List<Task> _tasks = [];
 List<Task> get tasks => _tasks;
  List<Task> get activeTasks => _tasks.where((task) => !task.isCompleted).toList();
  List<Task> get completedTasks => _tasks.where((task) => task.isCompleted).toList();

  Future<void> loadTasks() async {
    final dbTasks = await DatabaseHelper.instance.getAllTasks();
    _tasks.clear();
    _tasks.addAll(dbTasks);
    notifyListeners();
  }

 Future<void> addTask(Task task) async {
  // First add to database (which you're already doing in AddTaskScreen)
  // Then add to local list
  _tasks.add(task);
  notifyListeners();
}

  void updateTask(Task updatedTask) async {
    final index = _tasks.indexWhere((task) => task.id == updatedTask.id);
    if (index != -1) {
      _tasks[index] = updatedTask;
      await DatabaseHelper.instance.updateTask(updatedTask); // update in DB
      notifyListeners();
    }
  }

 
  void toggleCompletion(String taskId) async {
    final index = _tasks.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(
        isCompleted: !_tasks[index].isCompleted,
      );
      await DatabaseHelper.instance.updateTask(_tasks[index]);
      notifyListeners(); // This is crucial
      
      // Print for debugging
      debugPrint('Task ${_tasks[index].id} toggled to ${_tasks[index].isCompleted}');
    }
  }


  void deleteTask(String id) async {
    _tasks.removeWhere((task) => task.id == id);
    await DatabaseHelper.instance.deleteTask(id); // remove from DB
    notifyListeners();
  }
 void deleteAllCompletedTasks() async {
  _tasks.removeWhere((task) => task.isCompleted);
  await DatabaseHelper.instance.deleteAllCompletedTasks();
  notifyListeners();
}

}