import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/models/calender.dart';
import 'package:todo_list/models/task_model.dart';
import 'package:todo_list/providers/NotificationProvider.dart';
import 'package:todo_list/providers/category_provider.dart';
import 'package:todo_list/providers/task_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:todo_list/screens/repeatpicker.dart';
import 'package:todo_list/screens/timepicker.dart';
import 'package:todo_list/utils/theme.dart';

class EditTaskScreen extends StatefulWidget {
  final String taskId;

  const EditTaskScreen({super.key, required this.taskId});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  String? selectedCategory;
  bool isReminderOn = false;
  String? selectedReminder;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String repeatFrequency = 'No';
  late Task currentTask;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _subtaskController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  List<String> subtasks = [];
  bool _showSubtaskField = false;
  bool isCompleted = false;
  late TaskProvider _taskProvider;

  String _getReminderTimeText(TimeOfDay selectedTime, String reminderDuration) {
    int minutes = 0;
    final regex = RegExp(r'(\d+)');
    final match = regex.firstMatch(reminderDuration);
    if (match != null) {
      minutes = int.tryParse(match.group(1)!) ?? 0;
    }
    int totalMinutes = selectedTime.hour * 60 + selectedTime.minute - minutes;
    if (totalMinutes < 0) totalMinutes += 1440;
    final reminderTime = TimeOfDay(
      hour: totalMinutes ~/ 60,
      minute: totalMinutes % 60,
    );
    return reminderTime.format(context);
  }

  @override
  void initState() {
    super.initState();
    _taskProvider = Provider.of<TaskProvider>(context, listen: false);
    currentTask = _taskProvider.activeTasks.firstWhere(
      (task) => task.id == widget.taskId,
      orElse: () => _taskProvider.completedTasks.firstWhere(
        (task) => task.id == widget.taskId,
        orElse: () =>
            throw Exception("Task with id ${widget.taskId} not found"),
      ),
    );
    isCompleted = currentTask.isCompleted;

    selectedCategory = currentTask.category;
    isReminderOn = currentTask.isReminderOn;
    selectedReminder = currentTask.reminderOption;
    repeatFrequency = currentTask.repeatFrequency ?? 'No';
    selectedDate = currentTask.dateTime;
    selectedTime = TimeOfDay(
      hour: currentTask.dateTime.hour,
      minute: currentTask.dateTime.minute,
    );
    _titleController.text = currentTask.title;
    subtasks = currentTask.subtasks;

    // Add listener to title controller to save changes instantly
    _titleController.addListener(_updateTask);
    _notesController.text = currentTask.notes ?? '';
  }

  @override
  void dispose() {
    _titleController.removeListener(_updateTask);
    _titleController.dispose();
    _subtaskController.dispose();
    super.dispose();
  }

  void _updateTask() {
    if (selectedCategory == null) return;

    DateTime? finalDateTime;
    if (selectedDate != null) {
      finalDateTime = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        selectedTime?.hour ?? 0,
        selectedTime?.minute ?? 0,
      );
    }

    final updatedTask = currentTask.copyWith(
      title: _titleController.text,
      category: selectedCategory,
      isReminderOn: isReminderOn,
      reminderOption: selectedReminder,
      dateTime: finalDateTime ?? selectedDate,
      repeatFrequency: repeatFrequency,
      subtasks: subtasks,
      subtasksCompleted: currentTask.subtasksCompleted,
      notes: _notesController.text,
      isCompleted: isCompleted, // <-- THIS LINE is crucial!
    );

    _taskProvider.updateTask(updatedTask);
    final notificationProvider =
        Provider.of<NotificationProvider>(context, listen: false);

    if (isReminderOn && finalDateTime != null) {
      // Schedule new notification if reminder is enabled
      notificationProvider.scheduleTaskNotification(updatedTask);
    } else {
      // Cancel notification if reminder is disabled or time removed
      notificationProvider.cancelTaskNotification(updatedTask);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final pickedTime = await CustomTimePicker.show(
      context: context,
      initialTime: selectedTime,
    );

    setState(() {
      if (pickedTime == null) {
        selectedTime = null;
        isReminderOn = false;
        selectedReminder = null;
      } else {
        selectedTime = pickedTime;
        selectedDate ??= DateTime.now();
        isReminderOn = true;
        selectedReminder = '5m';
      }
      _updateTask();
    });
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => DatePickerPage(
          onDateSelected: (date, time, reminderEnabled, reminder, repeat) {},
          initialDate: selectedDate,
          initialTime: selectedTime,
          initialReminderEnabled: isReminderOn,
          initialReminder: selectedReminder ?? '5m',
          initialRepeat: repeatFrequency,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        selectedDate = result['date'];
        selectedTime = result['time'];
        isReminderOn = result['time'] != null
            ? (result['reminderEnabled'] ?? false)
            : false;
        selectedReminder =
            result['time'] != null ? (result['reminder'] ?? '5m') : null;
        repeatFrequency = result['repeat'] ?? 'No';

        if (result['time'] == null) {
          isReminderOn = false;
          selectedReminder = null;
        }
        _updateTask();
      });
    }
  }

  void _deleteTask() {
    final notificationProvider =
        Provider.of<NotificationProvider>(context, listen: false);
    notificationProvider.cancelTaskNotification(currentTask);
    _taskProvider.deleteTask(currentTask.id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task deleted successfully!')),
    );
    Navigator.pop(context);
  }

  void _markAsDone() {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final notificationProvider =
        Provider.of<NotificationProvider>(context, listen: false);
    taskProvider.toggleCompletion(currentTask.id);
    setState(() {
      isCompleted = !isCompleted;
    });
    if (isCompleted) {
      notificationProvider.cancelTaskNotification(currentTask);
    } else if (currentTask.isReminderOn) {
      // Re-enable notification if task is marked undone and had a reminder
      notificationProvider.scheduleTaskNotification(currentTask);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              isCompleted ? 'Task marked as done!' : 'Task marked as undone!')),
    );
    _updateTask();
  }

  void _shareTask() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality will be implemented')),
    );
  }

  void _addSubtask(String subtask) {
    if (subtask.isNotEmpty) {
      setState(() {
        subtasks.add(subtask);
        _subtaskController.clear();
        _showSubtaskField = false;
        _updateTask();
      });
    }
  }

  Future<void> _selectRepeat() async {
    final selectedRepeat = await showDialog<String>(
      context: context,
      builder: (context) => RepeatPickerDialog(
        initialRepeat: repeatFrequency,
      ),
    );

    if (selectedRepeat != null) {
      setState(() {
        repeatFrequency = selectedRepeat;
        _updateTask();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        toolbarHeight: 0,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            AbsorbPointer(
              absorbing: isCompleted,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: isCompleted ? 0.6 : 1.0,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(top: 50),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10, right: 0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.dimmedCardColor3,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedCategory,
                                isDense: true,
                                isExpanded: false,
                                icon: const Icon(Icons.arrow_drop_down,
                                    size: 18, color: Colors.black),
                                dropdownColor:Theme.of(context).scaffoldBackgroundColor,
                                style:TextStyle(
                                  fontSize: 16,
                                  color: Theme.of(context).iconTheme.color,
                                ),
                                items: [
                                  ...Provider.of<CategoryProvider>(context)
                                      .visibleCategories
                                      .map((category) =>
                                          DropdownMenuItem<String>(
                                            value: category,
                                            child: Text(category),
                                          )),
                                   DropdownMenuItem<String>(
                                    value: 'create_new_category',
                                    child: Row(
                                      children: [
                                        const Text(
                                          '➕ ',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                       Text(
                                          'Create New',
                                          style: TextStyle(
                                            color:Theme.of(context).secondaryHeaderColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                onChanged: (value) {
                                  if (value == 'create_new_category') {
                                    _showCreateCategoryDialog(context);
                                  } else {
                                    setState(() {
                                      selectedCategory = value;
                                      _updateTask();
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 16),
                          child: TextField(
                            controller: _titleController,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color:Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Task title',
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        // Subtasks
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Container(
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: AppTheme.barColor2,
                                  width: 1.0,
                                ),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                for (final subtask in subtasks)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      children: [
                                        Checkbox(
                                          value: currentTask.subtasksCompleted
                                              .contains(subtask),
                                          onChanged: (value) {
                                            setState(() {
                                              if (value == true) {
                                                if (!currentTask
                                                    .subtasksCompleted
                                                    .contains(subtask)) {
                                                  currentTask.subtasksCompleted
                                                      .add(subtask);
                                                }
                                              } else {
                                                currentTask.subtasksCompleted
                                                    .remove(subtask);
                                              }
                                              _updateTask();
                                            });
                                          },
                                          shape: const CircleBorder(),
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            subtask,
                                            style: TextStyle(
                                              decoration: currentTask
                                                      .subtasksCompleted
                                                      .contains(subtask)
                                                  ? TextDecoration.lineThrough
                                                  : TextDecoration.none,
                                              color: currentTask
                                                      .subtasksCompleted
                                                      .contains(subtask)
                                                  ? AppTheme.namedGrey
                                                  : Colors.black,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon:
                                              const Icon(Icons.close, size: 18),
                                          onPressed: () {
                                            setState(() {
                                              subtasks.remove(subtask);
                                              currentTask.subtasksCompleted
                                                  .remove(subtask);
                                              _updateTask();
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                if (_showSubtaskField)
                                  Row(
                                    children: [
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: TextField(
                                          controller: _subtaskController,
                                          autofocus: true,
                                          decoration: const InputDecoration(
                                            hintText: 'Add subtask...',
                                            border: InputBorder.none,
                                            isDense: true,
                                          ),
                                          onSubmitted: _addSubtask,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.cancel),
                                        onPressed: () {
                                          setState(() {
                                            _showSubtaskField = false;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                if (!_showSubtaskField)
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 0),
                                      child: TextButton(
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _showSubtaskField = true;
                                          });
                                        },
                                        child:  Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SizedBox(width: 4),
                                            Icon(Icons.add, size: 30),
                                            SizedBox(width: 8),
                                            Text(
                                              'Add Subtask',
                                              style: TextStyle(
                                                  color: Theme.of(context).secondaryHeaderColor,
                                                  fontSize: 18),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Container(
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: AppTheme.barColor2,
                                  width: 1.0,
                                ),
                              ),
                            ),
                            child: InkWell(
                              onTap: () => _selectDateTime(context),
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 12, left: 12),
                                child: Row(
                                  children: [
                                    FaIcon(
                                      FontAwesomeIcons.calendarDays,
                                      size: 18,
                                      color: Theme.of(context).iconTheme.color,
                                    ),
                                    const SizedBox(width: 14),
                                     Text(
                                      'Due Date',
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: Theme.of(context).iconTheme.color,
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color:AppTheme.dimmedCardColor3,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        selectedDate != null
                                            ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                                            : 'No date',
                                        style:  TextStyle(
                                          fontSize: 16,
                                          color:Theme.of(context).iconTheme.color,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Container(
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color:AppTheme.barColor2,
                                  width: 1.0,
                                ),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InkWell(
                                  onTap: () => _selectTime(context),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 12, left: 12, right: 0),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.access_time_filled,
                                          size: 18,
                                          color:Theme.of(context).iconTheme.color, 
                                        ),
                                        const SizedBox(width: 14),
                                        Text(
                                          'Time & Reminder',
                                          style: TextStyle(
                                            fontSize: 18,
                                            color:Theme.of(context).iconTheme.color,
                                          ),
                                        ),
                                        const Spacer(),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: AppTheme.dimmedCardColor3,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            selectedTime != null
                                                ? (selectedTime!.hour == 0 &&
                                                        selectedTime!.minute ==
                                                            0)
                                                    ? 'No '
                                                    : selectedTime!
                                                        .format(context)
                                                : 'No ',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Theme.of(context).iconTheme.color,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (isReminderOn &&
                                    selectedReminder != null &&
                                    selectedTime != null)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 45, right: 0, bottom: 12),
                                    child: Row(
                                      children: [
                                       Text(
                                          'Reminder at',
                                          style: TextStyle(
                                            fontSize: 18,
                                            color:Theme.of(context).iconTheme.color,
                                          ),
                                        ),
                                        const Spacer(),
                                        InkWell(
                                          onTap: _showReminderDialog,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: AppTheme.dimmedCardColor3,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              _getReminderTimeText(
                                                  selectedTime!,
                                                  selectedReminder!),
                                              style:  TextStyle(
                                                fontSize: 16,
                                                color: Theme.of(context).iconTheme.color,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Container(
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: AppTheme.barColor2,
                                  width: 1.0,
                                ),
                              ),
                            ),
                            child: InkWell(
                              onTap: _selectRepeat,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 12, left: 12, right: 0),
                                child: Row(
                                  children: [
                                    const FaIcon(
                                      FontAwesomeIcons.repeat,
                                      size: 18,
                                    
                                    ),
                                    const SizedBox(width: 15),
                                  Text(
                                      'Repeat',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color:Theme.of(context).iconTheme.color,
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: AppTheme.dimmedCardColor3,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        repeatFrequency,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color:Theme.of(context).iconTheme.color,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius:
                                  BorderRadius.circular(12), // Rounded corners
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                 Row(
                                    children: [
                                      Icon(
                                        Icons.notes,
                                        size: 18,
                                        color:  Theme.of(context).secondaryHeaderColor,
                                      ),
                                      SizedBox(width: 14),
                                      Text(
                                        'Notes',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color:  Theme.of(context).secondaryHeaderColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: _notesController,
                                    maxLines: 3,
                                    decoration: const InputDecoration(
                                      hintText: 'Add notes...',
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    onChanged: (value) {
                                      _updateTask();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 10,
              left: 10,
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  if (value == 'mark_done') {
                    _markAsDone();
                  } else if (value == 'share') {
                    _shareTask();
                  } else if (value == 'delete') {
                    _deleteTask();
                  }
                },
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem<String>(
                    value: 'mark_done',
                    child:
                        Text(isCompleted ? 'Mark as Undone' : 'Mark as Done'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'share',
                    child: Text('Share'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Text('Delete'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReminderDialog() {
    bool tempIsReminderOn = isReminderOn;
    String? tempSelectedReminder = selectedReminder;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            tempIsReminderOn
                                ? 'Reminder is on'
                                : 'Reminder is off',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Switch(
                            value: tempIsReminderOn,
                            onChanged: (value) {
                              setModalState(() {
                                tempIsReminderOn = value;
                                if (!value) {
                                  tempSelectedReminder = null;
                                } else {
                                  tempSelectedReminder ??= '5m';
                                }
                              });
                            },
                            activeColor: Theme.of(context).cardColor,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Reminder at',
                            style: TextStyle(
                              fontSize: 16,
                              color: tempIsReminderOn
                                  ? Theme.of(context).textTheme.bodyMedium?.color
                                  : Theme.of(context).primaryIconTheme.color,
                            ),
                          ),
                          DropdownButton<String>(
                            value:
                                tempIsReminderOn ? tempSelectedReminder : null,
                            underline: const SizedBox(),
                            disabledHint: Text(
                              'None',
                              style:
                                  TextStyle(color: Theme.of(context).iconTheme.color,fontSize: 14),
                            ),
                            style:  TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).iconTheme.color,
                            ),
                            dropdownColor: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(20),
                            items: const [
                              DropdownMenuItem(
                                  value: '0m', child: Text('At time of event')),
                              DropdownMenuItem(
                                  value: '5m', child: Text('5 minutes before')),
                              DropdownMenuItem(
                                  value: '10m',
                                  child: Text('10 minutes before')),
                              DropdownMenuItem(
                                  value: '15m',
                                  child: Text('15 minutes before')),
                              DropdownMenuItem(
                                  value: '30m',
                                  child: Text('30 minutes before')),
                              DropdownMenuItem(
                                  value: '1h', child: Text('1 hour before')),
                              DropdownMenuItem(
                                  value: '1d', child: Text('1 day before')),
                            ],
                            onChanged: tempIsReminderOn
                                ? (value) {
                                    setModalState(() {
                                      tempSelectedReminder = value;
                                    });
                                  }
                                : null,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 16, bottom: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            child: Text(
                              'CANCEL',
                              style: TextStyle(color: AppTheme.dimmedCardColor,),
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 16),
                          TextButton(
                            child:  Text(
                              'DONE',
                              style: TextStyle(color: Theme.of(context).cardColor,),
                            ),
                            onPressed: () {
                              setState(() {
                                isReminderOn = tempIsReminderOn;
                                selectedReminder = tempSelectedReminder;
                              });
                              _updateTask();
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showCreateCategoryDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: 300,
            maxWidth: 350,
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Create new category",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 24),
                Stack(
                  children: [
                    TextField(
                      controller: controller,
                      maxLength: 50,
                      maxLines: 1,
                      decoration: InputDecoration(
                        hintText: "Input here.",
                        hintStyle: TextStyle(color:Theme.of(context).primaryIconTheme.color),
                        filled: true,
                        fillColor: const Color(0xFFF8F9F9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        isCollapsed: true,
                        contentPadding:
                            const EdgeInsets.fromLTRB(16, 12, 50, 50),
                        counterText: '',
                      ),
                    ),
                    Positioned(
                      bottom: 2,
                      right: 6,
                      child: Text(
                        '${controller.text.length}/50',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).primaryIconTheme.color,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        "CANCEL",
                        style: TextStyle(
                            color: AppTheme.dimmedCardColor,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        final newCategory = controller.text.trim();
                        if (newCategory.isNotEmpty) {
                          Provider.of<CategoryProvider>(context, listen: false)
                              .addCategory(newCategory);
                          setState(() {
                            selectedCategory = newCategory;
                            _updateTask();
                          });
                        }
                        Navigator.of(context).pop();
                      },
                      child:  Text(
                        "DONE",
                        style: TextStyle(
                            color: Theme.of(context).cardColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
