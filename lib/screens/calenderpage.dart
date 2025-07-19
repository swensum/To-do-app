import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/models/task_model.dart';
import 'package:todo_list/providers/task_provider.dart';
import 'package:todo_list/utils/theme.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskProvider>(context, listen: false).loadTasks();
    });
  }

  bool isTaskRepeating(Task task) {
    if (task.repeatFrequency == null) return false;
    final frequency = task.repeatFrequency!.toLowerCase().trim();
    const validRepeatValues = ['daily', 'weekly', 'monthly', 'yearly'];
    return validRepeatValues.contains(frequency);
  }

  // Method to check if a date should show a marker based on repeating tasks
  bool _shouldShowMarker(DateTime date, TaskProvider taskProvider) {
    for (final task in taskProvider.tasks.where(isTaskRepeating)) {
      if (_isDateInRepeatSequence(date, task)) {
        return true;
      }
    }
    return false;
  }

  bool _isDateInRepeatSequence(DateTime date, Task task) {
    if (task.repeatFrequency == null) return false;
    if (date.isBefore(task.dateTime)) return false;

    final frequency = task.repeatFrequency!.toLowerCase().trim();

    if (frequency == 'daily') {
      return true;
    } else if (frequency == 'weekly') {
      return date.weekday == task.dateTime.weekday;
    } else if (frequency == 'monthly') {
      return date.day == task.dateTime.day;
    } else if (frequency == 'yearly') {
      return date.month == task.dateTime.month && date.day == task.dateTime.day;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/task.jpg'),
              fit: BoxFit.cover,
              opacity: 0.1,
            ),
          ),
          child: Column(
            children: [
              Consumer<TaskProvider>(
                builder: (context, taskProvider, child) {
                  return TableCalendar(
                    firstDay:
                        DateTime.now().subtract(const Duration(days: 365)),
                    lastDay: DateTime.now().add(const Duration(days: 365)),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) {
                      return isSameDay(_selectedDay, day);
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    calendarFormat: _calendarFormat,
                    onFormatChanged: (format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    },
                    calendarBuilders: CalendarBuilders(
                      markerBuilder: (context, date, events) {
                        if (_shouldShowMarker(date, taskProvider)) {
                          return Positioned(
                            bottom: 0,
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          );
                        }
                        return SizedBox.shrink();
                      },
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: true,
                      titleCentered: true,
                      leftChevronIcon:
                          Icon(FontAwesomeIcons.caretLeft, size: 20),
                      rightChevronIcon:
                          Icon(FontAwesomeIcons.caretRight, size: 20),
                    ),
                    daysOfWeekStyle: DaysOfWeekStyle(
                      weekdayStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      weekendStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.lightTheme.primaryColor,
                      ),
                    ),
                    calendarStyle: CalendarStyle(
                      defaultTextStyle: TextStyle(fontSize: 14),
                      todayTextStyle: TextStyle(fontWeight: FontWeight.bold),
                      outsideDaysVisible: true,
                    ),
                    rowHeight: 45,
                  );
                },
              ),
              SizedBox(height: 12),
              Expanded(
                child: Consumer<TaskProvider>(
                  builder: (context, taskProvider, child) {
                    final selectedDateTasks =
                        taskProvider.tasks.where((task) {
                      return isSameDay(task.dateTime, _selectedDay);
                    }).toList();
        
                    if (selectedDateTasks.isEmpty) {
                      return Center(
                        child: Text(
                          'No tasks for ${DateFormat('MMM dd, yyyy').format(_selectedDay!)}',
                          style: TextStyle(fontSize: 16, color: AppTheme.namedGrey),
                        ),
                      );
                    }
        
                    return ListView.builder(
                      itemCount: selectedDateTasks.length,
                      itemBuilder: (context, index) {
                        final task = selectedDateTasks[index];
                        final hasSpecificTime = !(task.dateTime.hour == 0 &&
                            task.dateTime.minute == 0);
                        final showReminder = task.isReminderOn;
                        final showRepeat = isTaskRepeating(task);
        
                        return Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: 18, vertical: 4),
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(
                                color: Theme.of(context).cardColor,
                                width: 10,
                              ),
                            ),
                            color: AppTheme.fillColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: ListTile(
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 12),
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  task.title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (hasSpecificTime ||
                                    showReminder ||
                                    showRepeat) ...[
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      if (hasSpecificTime) ...[
                                        Icon(Icons.access_time,
                                            size: 14, color: AppTheme.namedGrey,),
                                        SizedBox(width: 4),
                                        Text(
                                          DateFormat('hh:mm a')
                                              .format(task.dateTime),
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: AppTheme.namedGrey,),
                                        ),
                                      ],
                                      if (showReminder) ...[
                                        if (hasSpecificTime)
                                          SizedBox(width: 8),
                                        Icon(Icons.notifications,
                                            size: 14, color: AppTheme.namedGrey,),
                                      ],
                                      if (showRepeat) ...[
                                        if (hasSpecificTime || showReminder)
                                          SizedBox(width: 8),
                                        FaIcon(FontAwesomeIcons.repeat,
                                            size: 13, color: AppTheme.namedGrey,),
                                      ],
                                    ],
                                  ),
                                ],
                              ],
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                Icons.edit,
                                size: 20,
                                color: Theme.of(context).cardColor,
                              ),
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/edit_task',
                                  arguments: {
                                    'id': task.id,
                                    'title': task.title
                                  },
                                );
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

