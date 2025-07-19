import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:todo_list/models/task_model.dart';

class NotificationProvider with ChangeNotifier {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final Map<String, Timer> _activeTimers = {};

 Future<void> requestNotificationPermissions() async {
  final status = await Permission.notification.request();

  debugPrint('Notification permission granted: ${status.isGranted}');
}

  Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _notificationsPlugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: (_) {},
    );
     await requestNotificationPermissions();
  }

  Future<void> scheduleTaskNotification(Task task) async {
    if (!task.isReminderOn) {
      debugPrint('Notification not scheduled: ${task.dateTime == null ? "No date time" : "Reminder off"}');
      return;
    }

    if (task.dateTime.isBefore(DateTime.now())) {
      debugPrint('Notification not scheduled: Task time is in the past');
      await cancelTaskNotification(task);
      return;
    }

    _activeTimers[task.id]?.cancel();
    _activeTimers.remove(task.id);

    Duration? reminderDuration = _parseReminderOption(task.reminderOption!);
    if (reminderDuration == null) {
      debugPrint('Notification not scheduled: Invalid reminder option');
      return;
    }

    final reminderTime = task.dateTime.subtract(reminderDuration);
    debugPrint('Task time: ${task.dateTime}');
    debugPrint('Reminder will fire at: $reminderTime');
    debugPrint('Current time: ${DateTime.now()}');

    if (reminderTime.isBefore(DateTime.now())) {
      debugPrint('Notification not scheduled: Reminder time is in the past');
      return;
    }

    final duration = reminderTime.difference(DateTime.now());
    debugPrint('Notification will fire in: $duration');

    // Add debug message for repeat setting
    if (task.repeatFrequency != null && task.repeatFrequency!.toLowerCase() != 'none') {
      debugPrint('Repeat is set to: ${task.repeatFrequency}');
      Duration? repeatDuration = _getRepeatDuration(task.repeatFrequency!.toLowerCase());
      if (repeatDuration != null) {
        debugPrint('Next occurrence will be after: $repeatDuration');
      } else {
        debugPrint('Invalid repeat frequency: ${task.repeatFrequency}');
      }
    } else {
      debugPrint('No repeat set for this task');
    }

    _activeTimers[task.id] = Timer(duration, () async {
      debugPrint('Notification fired for task: ${task.title}');
      await _showNotification(
        id: task.id.hashCode,
        title: ' ${task.title}',
        body: ' ${DateFormat('h:mm a').format(task.dateTime)}',
      );

      // Reschedule for repeat, if applicable
      if (task.repeatFrequency != null && task.repeatFrequency!.toLowerCase() != 'none') {
        Duration? repeatDuration = _getRepeatDuration(task.repeatFrequency!.toLowerCase());
        if (repeatDuration != null) {
          Task updatedTask = task.copyWith(
            dateTime: task.dateTime.add(repeatDuration),
          );
          debugPrint('Rescheduling task for next occurrence at: ${updatedTask.dateTime}');
          await scheduleTaskNotification(updatedTask);
        }
      }

      _activeTimers.remove(task.id);
    });
  }

  Duration? _parseReminderOption(String? option) {
    if (option == null) return null;

    switch (option.toLowerCase()) {
      case '0m':
      case 'at time of event':
        return Duration.zero;
      case '5m':
      case '5 minutes before':
        return const Duration(minutes: 5);
      case '10m':
      case '10 minutes before':
        return const Duration(minutes: 10);
      case '15m':
      case '15 minutes before':
        return const Duration(minutes: 15);
      case '30m':
      case '30 minutes before':
        return const Duration(minutes: 30);
      case '1h':
      case '1 hour before':
        return const Duration(hours: 1);
      case '1d':
      case '1 day before':
        return const Duration(days: 1);
      default:
        return null;
    }
  }

  Duration? _getRepeatDuration(String repeat) {
    switch (repeat.toLowerCase()) {
      case 'hour':
      case 'hourly':
        return const Duration(hours: 1);
      case 'daily':
        return const Duration(days: 1);
      case 'weekly':
        return const Duration(days: 7);
      case 'monthly':
        return const Duration(days: 30); // approximation
      case 'yearly':
        return const Duration(days: 365); // approximation
      default:
        return null;
    }
  }

  Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    await _notificationsPlugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_reminder_channel',
          'Task Reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  Future<void> cancelTaskNotification(Task task) async {
    _activeTimers[task.id]?.cancel();
    _activeTimers.remove(task.id);
    await _notificationsPlugin.cancel(task.id.hashCode);
  }

  Future<void> cancelAllNotifications() async {
    _activeTimers.forEach((_, timer) => timer.cancel());
    _activeTimers.clear();
    await _notificationsPlugin.cancelAll();
  }

  Future<void> updateTaskNotification(Task oldTask, Task newTask) async {
    await cancelTaskNotification(oldTask);
    await scheduleTaskNotification(newTask);
  }

  @override
  void dispose() {
    _activeTimers.forEach((_, timer) => timer.cancel());
    _activeTimers.clear();
    super.dispose();
  }
}
