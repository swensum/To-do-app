import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/models/categorydropdown.dart';
import 'package:todo_list/models/calender.dart';
import 'package:todo_list/models/database_helper.dart';
import 'package:todo_list/models/task_model.dart';
import 'package:todo_list/providers/NotificationProvider.dart';
import 'package:todo_list/providers/task_provider.dart';
import 'package:todo_list/utils/theme.dart';
import 'package:uuid/uuid.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _subtaskController = TextEditingController();

  String selectedCategory = 'No Category';
  DateTime? _selectedDateTime;
  final _formKey = GlobalKey<FormState>();
  TimeOfDay? _selectedTime;
  bool _reminderEnabled = false;
  String? _selectedReminder;
  String _selectedRepeat = 'No';
  bool _showSubtaskField = false;
  List<String> subtasks = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeNotifications();
    });
  }
   Future<void> _initializeNotifications() async {
    try {
      await Provider.of<NotificationProvider>(context, listen: false).init();
      debugPrint('Notification provider initialized');
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 8, bottom: 16),
                ),
              ),
              
              // Task Title TextField
              TextFormField(
                controller: _titleController,
                style: theme.textTheme.bodyLarge,
                decoration: InputDecoration(
                  labelText: 'What needs to be done?',
                  labelStyle: TextStyle(
                    color:  Theme.of(context).cardColor,
                  ),
                  filled: true,
                  fillColor: AppTheme.fillColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: AppTheme.dimmedCardColor,
                      width: 2.0,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 15,
                  ),
                  suffixIcon: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color:  Theme.of(context).cardColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.send, color: colorScheme.onPrimary,size: 16,),
                    ),
                    onPressed: _submitTask,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a task';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 18),
              
              Row(
                children: [
                  CategoryDropdown(
                    initialValue: selectedCategory,
                    onCategorySelected: (category) {
                      setState(() {
                        selectedCategory = category;
                      });
                    },
                  ),
                  const SizedBox(width: 2),
                  IconButton(
                    iconSize: 20,
                    icon: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.playlist_add,
                          color: _showSubtaskField ||
                                  subtasks.isNotEmpty 
                              ?  Theme.of(context).cardColor
                              : AppTheme.namedGrey,
                        ),
                      ],
                    ),
                    onPressed: () {
                      setState(() {
                        _showSubtaskField = true; 
                      });
                    },
                  ),
                  const SizedBox(width: 2),
                  IconButton(
                    iconSize: 20,
                    icon: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color:
                              _selectedDateTime != null || _selectedTime != null
                                  ?  Theme.of(context).cardColor
                                  : AppTheme.namedGrey,
                        ),
                        if (_selectedDateTime != null || _selectedTime != null)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                    onPressed: _showCalendarBottomSheet,
                  ),
                ],
              ),
              Column(
                children: [
                  for (final subtask in subtasks)
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 16, right: 16, top: 4), 
                      child: Row(
                        children: [
                          const Icon(Icons.arrow_right, size: 24),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              subtask,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                          IconButton(
                            padding: EdgeInsets.zero, 
                            constraints:
                                const BoxConstraints(),
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () {
                              setState(() {
                                subtasks.remove(subtask);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
              

                  if (_showSubtaskField)
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 16, right: 16, top: 4), 
                      child: Row(
                        children: [
                          const Icon(Icons.arrow_right, size: 24),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _subtaskController,
                              autofocus: true,
                              decoration: InputDecoration(
                                hintText: 'Add subtask...',
                             hintStyle: TextStyle(color: AppTheme.namedGrey),
                                border: InputBorder.none,
                                isDense: true, // Reduces internal padding
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 10),
                              ),
                              onSubmitted: (value) {
                                if (value.isNotEmpty) {
                                  setState(() {
                                    subtasks.add(value);
                                    _subtaskController.clear();
                                    _showSubtaskField = false;
                                  });
                                }
                              },
                            ),
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(Icons.cancel, size: 18),
                            onPressed: () {
                              setState(() {
                                _showSubtaskField = false;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCalendarBottomSheet() {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color.fromARGB(0, 219, 218, 218),
      builder: (context) {
        return Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height *
                  0.87, // 85% of screen height
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withOpacity(0.2),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Theme(
                data: theme,
                child: DatePickerPage(
                  onDateSelected: (date, time, reminderEnabled, reminderOption,
                      repeatFrequency) {
                    setState(() {
                      _selectedDateTime = date;
                      _selectedTime = time;
                      _reminderEnabled = reminderEnabled;
                      _selectedReminder = reminderOption;
                      _selectedRepeat = repeatFrequency ?? 'No';
                    });
                  },
                  initialDate: _selectedDateTime,
                  initialTime: _selectedTime,
                  initialReminderEnabled: _reminderEnabled,
                  initialReminder: _selectedReminder,
                  initialRepeat: _selectedRepeat,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _submitTask() async {
    final id = const Uuid().v4();
    final title = _titleController.text.trim();

    // Add any pending subtask before validation
    if (_subtaskController.text.isNotEmpty) {
      setState(() {
        subtasks.add(_subtaskController.text);
        _subtaskController.clear();
        _showSubtaskField = false;
      });
    }

    if (_formKey.currentState?.validate() ?? false) {
      if (title.isNotEmpty) {
        DateTime? taskDateTime;

        if (_selectedDateTime != null) {
          // If time is selected, combine it with the date
          if (_selectedTime != null) {
            taskDateTime = DateTime(
              _selectedDateTime!.year,
              _selectedDateTime!.month,
              _selectedDateTime!.day,
               _selectedTime!.hour,
              _selectedTime!.minute,
            );
          } else {
            taskDateTime = DateTime(
              _selectedDateTime!.year,
              _selectedDateTime!.month,
              _selectedDateTime!.day,
            );
          }
        } else {
          final now = DateTime.now();
          taskDateTime = DateTime(now.year, now.month, now.day);
        }

        final newTask = Task(
          id: id,
          title: title,
          category: selectedCategory,
          dateTime: taskDateTime,
          isReminderOn: _reminderEnabled,
          reminderOption: _selectedReminder,
          repeatFrequency: _selectedRepeat,
          subtasks: subtasks,
        );

        try {
          await DatabaseHelper.instance.insertTask(newTask);
          Provider.of<TaskProvider>(context, listen: false).addTask(newTask);
           if (_reminderEnabled) {
            try {
              final notificationProvider = 
                  Provider.of<NotificationProvider>(context, listen: false);
              await notificationProvider.scheduleTaskNotification(newTask);
              debugPrint("Notification scheduled successfully");
            } catch (e) {
              debugPrint("Failed to schedule notification: $e");
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Task saved but notification failed: $e')),
                );
              }
            }
          }
          if (mounted) Navigator.pop(context);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to save task: $e')),
            );
          }
        }
      }
    }
  }
}
