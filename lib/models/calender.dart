import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:todo_list/screens/reminderpicker.dart';
import 'package:todo_list/screens/repeatpicker.dart';
import 'package:todo_list/screens/timepicker.dart';
import 'package:todo_list/utils/theme.dart';

class DatePickerPage extends StatefulWidget {
  final Function(DateTime?, TimeOfDay?, bool, String?, String?) onDateSelected;
  final DateTime? initialDate;
  final TimeOfDay? initialTime;
  final bool initialReminderEnabled;
  final String? initialReminder;
  final String initialRepeat;

  const DatePickerPage({
    super.key,
    required this.onDateSelected,
    this.initialDate,
    this.initialTime,
    this.initialReminderEnabled = false,
    this.initialReminder,
    this.initialRepeat = 'No',
  });

  @override
  State<DatePickerPage> createState() => _DatePickerPageState();
}

class _DatePickerPageState extends State<DatePickerPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  TimeOfDay? _selectedTime;
  bool _reminderEnabled = false;
  String? _selectedReminder;
  String _selectedRepeat = 'No';
  bool get _isTimeSelected => _selectedTime != null;
  bool get _isDateSelected => _selectedDay != null;

  @override
  void initState() {
    super.initState();
    // Initialize with the passed values
    _selectedDay = widget.initialDate;
    _selectedTime = widget.initialTime;
    _reminderEnabled = widget.initialReminderEnabled;
    _selectedReminder = widget.initialReminder;
    _selectedRepeat = widget.initialRepeat;
    _focusedDay = _selectedDay ?? DateTime.now();
  }

  void _handleDateOption(DateTime? date) {
    setState(() {
      if (date == null) {
        _selectedDay = null;
        _selectedTime = null;
        _reminderEnabled = false;
        _selectedReminder = null;
        _selectedRepeat = 'No';
      } else {
        _selectedDay = date;
        _focusedDay = date;
      }
    });
  }

  Future<void> _selectYear(BuildContext context) async {
    final DateTime? picked = await showDialog<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: const Text('Select Year'),
          content: SizedBox(
            width: 300,
            height: 300,
            child: YearPicker(
              firstDate: DateTime(DateTime.now().year - 20),
              lastDate: DateTime(DateTime.now().year + 20),
              initialDate: _focusedDay,
              selectedDate: _focusedDay,
              onChanged: (DateTime dateTime) {
                Navigator.pop(context, dateTime);
              },
            ),
          ),
        );
      },
    );

    if (picked != null) {
      setState(() {
        _focusedDay = DateTime(picked.year, _focusedDay.month, _focusedDay.day);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    if (!_isDateSelected) return;
    final pickedTime = await CustomTimePicker.show(
      context: context,
      initialTime: _selectedTime,
      includeNoTimeOption: true,
    );

    setState(() {
      if (pickedTime == null) {
        // "No time" was selected
        _selectedTime = null;
        _reminderEnabled = false;
        _selectedReminder = null;
      } else {
        _selectedTime = pickedTime;
        _reminderEnabled = true;
        _selectedReminder = '5m'; // Default reminder
      }
    });
  }

  void _handleReminderChanged(bool enabled, String? reminder) {
    setState(() {
      _reminderEnabled = enabled;
      _selectedReminder = reminder;
    });
  }

  Future<void> _selectRepeat(BuildContext context) async {
    if (!_isDateSelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a date first'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return RepeatPickerDialog(initialRepeat: _selectedRepeat);
      },
    );

    if (result != null) {
      setState(() {
        _selectedRepeat = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: Column(
            children: [
              TableCalendar(
                firstDay: DateTime(2000),
                lastDay: DateTime(2101),
                focusedDay: _focusedDay,
                sixWeekMonthsEnforced: true,
                selectedDayPredicate: (day) =>
                    _selectedDay != null && isSameDay(day, _selectedDay),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                calendarStyle: CalendarStyle(
                  selectedDecoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: AppTheme.namedGrey,
                    shape: BoxShape.circle,
                  ),
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekendStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.lightTheme.primaryColor,
                  ),
                  weekdayStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                daysOfWeekHeight: 30,
                rowHeight: 40,
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  leftChevronIcon: FaIcon(
                    FontAwesomeIcons.caretLeft,
                    color: Theme.of(context).iconTheme.color,
                    size: 18,
                  ),
                  rightChevronIcon: FaIcon(
                    FontAwesomeIcons.caretRight,
                    color: Theme.of(context).iconTheme.color,
                    size: 18,
                  ),
                  formatButtonShowsNext: false,
                  headerMargin: const EdgeInsets.only(bottom: 8.0),
                  headerPadding: const EdgeInsets.symmetric(vertical: 8.0),
                ),
                availableCalendarFormats: const {
                  CalendarFormat.month: 'Month',
                },
                calendarBuilders: CalendarBuilders(
                  headerTitleBuilder: (context, day) {
                    return Center(
                      child: GestureDetector(
                        onTap: () => _selectYear(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            DateFormat('MMMM yyyy').format(day),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  markerBuilder: (context, date, events) {
                    if (_selectedDay == null || _selectedRepeat == 'No') {
                      return null;
                    }

                    // For daily repeats
                    if (_selectedRepeat == 'Daily' &&
                        date.isAfter(_selectedDay!) &&
                        !isSameDay(date, _selectedDay!)) {
                      return Positioned(
                        bottom: 4,
                        child: Center(
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      );
                    }

                    // For weekly repeats
                    if (_selectedRepeat == 'Weekly' &&
                        date.isAfter(_selectedDay!) &&
                        date.weekday == _selectedDay!.weekday &&
                        !isSameDay(date, _selectedDay!)) {
                      return Positioned(
                        bottom: 4,
                        child: Center(
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      );
                    }
                    if (_selectedRepeat == 'Monthly' &&
                        date.isAfter(_selectedDay!) &&
                        date.day == _selectedDay!.day &&
                        !isSameDay(date, _selectedDay!)) {
                      return Positioned(
                        bottom: 4,
                        child: Center(
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      );
                    }
                    if (_selectedRepeat == 'Yearly' &&
                        date.isAfter(_selectedDay!) &&
                        date.month == _selectedDay!.month &&
                        date.day == _selectedDay!.day &&
                        !isSameDay(date, _selectedDay!)) {
                      return Positioned(
                        bottom: 4,
                        child: Center(
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      );
                    }

                    return null;
                  },
                ),
              ),

              const SizedBox(height: 10),
              _buildOptionRow([
                _Option('No Date', () => null),
                _Option('Today', () => DateTime.now()),
                _Option('Tomorrow',
                    () => DateTime.now().add(const Duration(days: 1))),
              ]),
              _buildOptionRow([
                _Option('3 Days Later',
                    () => DateTime.now().add(const Duration(days: 3))),
                _Option('This Sunday', () {
                  final now = DateTime.now();
                  final daysToSunday = DateTime.sunday - now.weekday;
                  return now.add(Duration(days: daysToSunday));
                }),
              ]),
              const SizedBox(height: 12),

              // Time selection row
              InkWell(
                onTap: _isDateSelected
                    ? () => _selectTime(context)
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            content: Align(
                              alignment: Alignment.center,
                              child: Container(
                                width: 230,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Text(
                                  'Please select a date first',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                  ),
                                ),
                              ),
                            ),
                            duration: const Duration(seconds: 2),
                            margin: const EdgeInsets.all(2),
                          ),
                        );
                      },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Container(
                    padding: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: AppTheme.borderColor,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 24,
                            color: _isDateSelected
                                ? Theme.of(context).iconTheme.color
                                : Theme.of(context).primaryIconTheme.color,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Time',
                            style: TextStyle(
                              fontSize: 16,
                              color: _isDateSelected
                                  ? Theme.of(context).iconTheme.color
                                  : Theme.of(context).primaryIconTheme.color,
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 20),
                              child: Text(
                                _selectedTime != null
                                    ? _selectedTime!.format(context)
                                    : 'No',
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: _selectedTime != null
                                      ? Theme.of(context).iconTheme.color
                                      : Theme.of(context)
                                          .primaryIconTheme
                                          .color,
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

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: AppTheme.borderColor,
                        width: 1,
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 4),
                  child: GestureDetector(
                    onTap: () {
                      if (!_isTimeSelected || !_isDateSelected) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            content: Align(
                              alignment: Alignment.center,
                              child: Container(
                                width: 230,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Text(
                                  'Please select a time first',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                  ),
                                ),
                              ),
                            ),
                            duration: const Duration(seconds: 2),
                            margin: const EdgeInsets.all(2),
                          ),
                        );
                      }
                    },
                    child: Opacity(
                      opacity: (_isTimeSelected && _isDateSelected) ? 1.0 : 0.5,
                      child: AbsorbPointer(
                        absorbing: !_isTimeSelected || !_isDateSelected,
                        child: ReminderPicker(
                          initialEnabled: _reminderEnabled && _isTimeSelected,
                          initialReminder: _selectedReminder,
                          selectedTime: _selectedTime,
                          onReminderChanged: _handleReminderChanged,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              InkWell(
                onTap: _isDateSelected
                    ? () => _selectRepeat(context)
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            content: Align(
                              alignment: Alignment.center,
                              child: Container(
                                width: 230,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Text(
                                  'Please select a date first',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                  ),
                                ),
                              ),
                            ),
                            duration: const Duration(seconds: 2),
                            margin: const EdgeInsets.all(2),
                          ),
                        );
                      },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: AppTheme.borderColor,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 15, 18, 15),
                      child: Row(
                        children: [
                          Icon(
                            Icons.repeat,
                            size: 24,
                            color: _isDateSelected
                                ? Theme.of(context).iconTheme.color
                                : Theme.of(context).primaryIconTheme.color,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Repeat',
                            style: TextStyle(
                              fontSize: 16,
                              color: _isDateSelected
                                  ? Theme.of(context).iconTheme.color
                                  : Theme.of(context).primaryIconTheme.color,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _selectedRepeat,
                            style: TextStyle(
                              fontSize: 16,
                              color: _selectedTime != null
                                  ? Theme.of(context).iconTheme.color
                                  : Theme.of(context).primaryIconTheme.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Replace the Confirm button with Cancel/Done buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Just close without saving
                      },
                      child: Text(
                        'CANCEL',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppTheme.dimmedCardColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    TextButton(
                      onPressed: () {
                        DateTime? result;
                        if (_selectedDay != null) {
                          result = DateTime(
                            _selectedDay!.year,
                            _selectedDay!.month,
                            _selectedDay!.day,
                            _selectedTime?.hour ?? 0,
                            _selectedTime?.minute ?? 0,
                          );
                        }
                        widget.onDateSelected(
                          result,
                          _selectedTime,
                          _reminderEnabled,
                          _selectedReminder,
                          _selectedRepeat,
                        );
                        Navigator.of(context).pop({
                          'date': _selectedDay,
                          'time': _selectedTime,
                          'reminderEnabled': _reminderEnabled,
                          'reminder': _selectedReminder,
                          'repeat': _selectedRepeat,
                        });
                      },
                      child: Text(
                        'DONE',
                        style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).cardColor,
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
    );
  }

  Widget _buildOptionRow(List<_Option> options) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: options.map((option) {
          bool isSelected = isSameDay(_selectedDay, option.dateGetter());
          if (_selectedDay == null && option.dateGetter() == null) {
            isSelected = true;
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ChoiceChip(
              label: Text(option.label),
              selected: isSelected,
              onSelected: (_) => _handleDateOption(option.dateGetter()),
              selectedColor: Theme.of(context).cardColor,
              backgroundColor: Colors.grey.shade100,
              elevation: 0,
              pressElevation: 0,
              side: BorderSide.none,
              labelStyle: TextStyle(
                color: isSelected
                    ? Theme.of(context).scaffoldBackgroundColor
                    : Theme.of(context).primaryIconTheme.color,
              ),
              shape: const StadiumBorder(),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _Option {
  final String label;
  final DateTime? Function() dateGetter;
  const _Option(this.label, this.dateGetter);
}
