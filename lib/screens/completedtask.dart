import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/models/task_model.dart';
import 'package:todo_list/providers/task_provider.dart';
import 'package:todo_list/utils/theme.dart';
import 'package:todo_list/widgets/task_list.dart';

class CompletedTasksPage extends StatelessWidget {
  const CompletedTasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final completedTasks = context.watch<TaskProvider>().completedTasks;

    String formatDate(DateTime date) {
      return DateFormat('MM/dd/yyyy').format(date);
    }

    Map<String, List<Task>> groupedTasks = {};
    for (var task in completedTasks) {
      String formattedDate = formatDate(task.dateTime);
      if (!groupedTasks.containsKey(formattedDate)) {
        groupedTasks[formattedDate] = [];
      }
      groupedTasks[formattedDate]?.add(task);
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        actions: [
          if (completedTasks.isNotEmpty)
            IconButton(
              icon:Icon(Icons.delete, color: AppTheme.lightTheme.primaryColor,),
              tooltip: 'Delete all completed tasks',
              onPressed: () {
                _showDeleteConfirmationDialog(context);
              },
            ),
        ],
      ),
      body: completedTasks.isEmpty
          ? const Center(
              child: Text(
                'No completed tasks yet',
                style: TextStyle(fontSize: 16, color: AppTheme.namedGrey),
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 30.0, bottom: 8.0),
                      child: Text(
                        'Completed Time',
                        style: TextStyle(
                          color:  AppTheme.lightTheme.primaryColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ...groupedTasks.entries.map((entry) {
                      String date = entry.key;
                      List<Task> tasksOnDate = entry.value;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date row with circle marker
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 24,
                                child: Column(
                                  children: [
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          width: 16,
                                          height: 16,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Theme.of(context).primaryColor,
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Theme.of(context).primaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 1),
                                    Container(
                                      width: 2,
                                      height: 24,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 7),
                              Padding(
                                padding: const EdgeInsets.only(top: 0),
                                child: Text(
                                  date,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color:  AppTheme.lightTheme.primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // Tasks with connecting line
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width:21,
                                child: Padding(
                                   padding: const EdgeInsets.only(left: 3),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 2,
                                        height: _calculateTaskListHeight(tasksOnDate),
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                             
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 0, bottom: 8.0),
                                  child: TaskList(
                                    tasks: tasksOnDate,
                                    showCompletedOnly: true,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
    );
  }

  double _calculateTaskListHeight(List<Task> tasks) {
    const double taskItemHeight = 87.0;
    const double additionalHeight = 15.0;
    return (tasks.length * taskItemHeight) + additionalHeight;
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
    
      context: context,
    
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: const Text("Delete all completed tasks?", style: TextStyle(fontSize: 18),),
       
        actions: [
          TextButton(
            
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: AppTheme.dimmedCardColor,),),
          ),
          TextButton(
            onPressed: () {
              Provider.of<TaskProvider>(context, listen: false).deleteAllCompletedTasks();
              Navigator.pop(context);
            },
            child: Text(
              "Delete",
              style: TextStyle(color: Theme.of(context).cardColor,),
            ),
          ),
        ],
      ),
    );
  }
}
