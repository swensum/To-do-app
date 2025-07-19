import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/providers/task_provider.dart';
import 'package:todo_list/routes/app_routes.dart';
import 'package:todo_list/utils/theme.dart';
import '../models/task_model.dart';

class TaskItem extends StatelessWidget {
  final Task task;

  const TaskItem({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
   
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;
    final iconColor = Theme.of(context).iconTheme.color;

    return ListTile(
      title: GestureDetector(
        onTap: () {
         
          Navigator.pushNamed(
            context,
            AppRoutes.editTask,
            arguments: {'id': task.id, 'title': task.title},
          );
        },
        child: Container(
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            border: Border.all(
              color: AppTheme.namedGrey,
            ),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
     
              Expanded(
                child: Text(
                  task.title,
                  style: TextStyle(
                    decoration:
                        task.isCompleted ? TextDecoration.lineThrough : null,
                    color: textColor,
                  ),
                ),
              ),
    
              IconButton(
                icon: Icon(
                  task.isCompleted ? Icons.check_circle : Icons.circle_outlined,
                  color: task.isCompleted
                      ? Theme.of(context).secondaryHeaderColor
                      : iconColor, 
                ),
                onPressed: () {
                  Provider.of<TaskProvider>(context, listen: false)
                      .toggleCompletion(task.id);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
