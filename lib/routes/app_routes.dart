import 'package:flutter/material.dart';
import 'package:todo_list/navbar/main_tab.dart';
import 'package:todo_list/screens/add_task.dart';
import 'package:todo_list/screens/edit_task.dart';


class AppRoutes {
  static const String home = '/';
  static const String addTask = '/add_task';
  static const String editTask = '/edit_task';

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const MainTabView());
      case addTask:
        return MaterialPageRoute(builder: (_) => AddTaskScreen());
      case editTask:
        final args = settings.arguments as Map<String, String>;
        return MaterialPageRoute(
          builder: (_) => EditTaskScreen(
            taskId: args['id']!,
          ),
        );
      default:
        return MaterialPageRoute(builder: (_) => const MainTabView());
    }
  }
}