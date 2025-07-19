import 'package:flutter/material.dart';
import 'package:todo_list/utils/theme.dart';

class ReminderPicker extends StatefulWidget {
  final bool initialEnabled;
  final String? initialReminder;
  final TimeOfDay? selectedTime;
  final Function(bool, String?) onReminderChanged;

  const ReminderPicker({
    super.key,
    required this.initialEnabled,
    required this.initialReminder,
    required this.selectedTime,
    required this.onReminderChanged,
  });

  @override
  State<ReminderPicker> createState() => _ReminderPickerState();
}

class _ReminderPickerState extends State<ReminderPicker> {
  late bool _enabled;
  late String? _selectedReminder;

  @override
  void initState() {
    super.initState();
    _enabled = widget.initialEnabled;
    _selectedReminder = widget.initialReminder;
  }

   String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }


  String _getReminderText(String? reminder) {
    if (!_enabled || reminder == null || widget.selectedTime == null) {
      return 'No';
    }

    final time = widget.selectedTime!;
    final now = DateTime.now();
    final eventTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    DateTime reminderTime;

    switch (reminder) {
      case '0m':
        return _formatTime(time);
      case '5m':
        reminderTime = eventTime.subtract(const Duration(minutes: 5));
        return _formatTime(TimeOfDay(hour: reminderTime.hour, minute: reminderTime.minute));
      case '10m':
        reminderTime = eventTime.subtract(const Duration(minutes: 10));
        return _formatTime(TimeOfDay(hour: reminderTime.hour, minute: reminderTime.minute));
      case '15m':
        reminderTime = eventTime.subtract(const Duration(minutes: 15));
        return _formatTime(TimeOfDay(hour: reminderTime.hour, minute: reminderTime.minute));
      case '30m':
        reminderTime = eventTime.subtract(const Duration(minutes: 30));
        return _formatTime(TimeOfDay(hour: reminderTime.hour, minute: reminderTime.minute));
      case '1h':
        reminderTime = eventTime.subtract(const Duration(hours: 1));
        return _formatTime(TimeOfDay(hour: reminderTime.hour, minute: reminderTime.minute));
      case '1d':
        reminderTime = eventTime.subtract(const Duration(days: 1));
        return '${reminderTime.day}/${reminderTime.month} ${_formatTime(TimeOfDay(hour: reminderTime.hour, minute: reminderTime.minute))}';
      default:
        return 'None';
    }
  }

   Widget _buildReminderDialog() {
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
                        _enabled ? 'Reminder is on' : 'Reminder is off',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Switch(
                        value: _enabled,
                        onChanged: (value) {
                          setModalState(() {
                            _enabled = value;
                            if (!value) {
                              _selectedReminder = null;
                            } else {
                              _selectedReminder ??= '5m';
                            }
                          });
                          widget.onReminderChanged(_enabled, _selectedReminder);
                        },
                        activeColor:  Theme.of(context).cardColor,
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
                          color: _enabled ? Theme.of(context).textTheme.bodyMedium?.color: Theme.of(context).primaryIconTheme.color,
                        ),
                      ),
                      DropdownButton<String>(
                        value: _enabled ? _selectedReminder : null,
                        underline: const SizedBox(),
                        disabledHint:  Text(
                          'None',
                          style: TextStyle(color: Theme.of(context).primaryIconTheme.color, fontSize: 14),
                        ),
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                        dropdownColor: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(20),
                        items: const [
                          DropdownMenuItem(value: '0m', child: Text('At time of event')),
                          DropdownMenuItem(value: '5m', child: Text('5 minutes before')),
                          DropdownMenuItem(value: '10m', child: Text('10 minutes before')),
                          DropdownMenuItem(value: '15m', child: Text('15 minutes before')),
                          DropdownMenuItem(value: '30m', child: Text('30 minutes before')),
                          DropdownMenuItem(value: '1h', child: Text('1 hour before')),
                          DropdownMenuItem(value: '1d', child: Text('1 day before')),
                        ],
                        onChanged: _enabled
                            ? (value) {
                                if (value != null) {
                                  setModalState(() {
                                    _selectedReminder = value;
                                  });
                                  widget.onReminderChanged(_enabled, _selectedReminder);
                                }
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
                        child: const Text(
                          'CANCEL',
                          style: TextStyle(color:AppTheme.dimmedCardColor,),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 16),
                      TextButton(
                        child: Text(
                          'DONE',
                          style: TextStyle(color: Theme.of(context).cardColor),
                        ),
                        onPressed: () {
                          widget.onReminderChanged(_enabled, _selectedReminder);
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
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) => _buildReminderDialog(),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(Icons.notifications_outlined, size: 24, color:  Theme.of(context).iconTheme.color),
            const SizedBox(width: 10),
             Text('Reminder', style: TextStyle(fontSize: 16,color: Theme.of(context).iconTheme.color,)),
            const Spacer(),
            Text(
              _getReminderText(_selectedReminder),
              style:  TextStyle(fontSize: 16, color: Theme.of(context).iconTheme.color,),
            ),
            const SizedBox(width: 3),
             Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).iconTheme.color,),
          ],
        ),
      ),
    );
  }
}