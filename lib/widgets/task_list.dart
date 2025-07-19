import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/models/task_model.dart';
import 'package:todo_list/providers/task_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:todo_list/utils/theme.dart';


class TaskList extends StatefulWidget {
  final List<Task> tasks;
  final bool showCompletedOnly;

  const TaskList({
    super.key,
    required this.tasks,
    this.showCompletedOnly = false,
  });

  @override
  State<TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> _playBellSound() async {
    await _audioPlayer.play(AssetSource('sound/bell.mp3'));
  }

  bool _shouldShowRepeatIcon(Task task) {
    if (task.repeatFrequency == null) return false;
    final frequency = task.repeatFrequency!.toLowerCase().trim();
    const validRepeatValues = ['daily', 'weekly', 'monthly', 'yearly'];
    return validRepeatValues.contains(frequency);
  }

  @override
  Widget build(BuildContext context) {
    final tasksToDisplay = widget.showCompletedOnly
        ? widget.tasks.where((task) => task.isCompleted).toList()
        : widget.tasks;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tasksToDisplay.length,
      itemBuilder: (context, index) {
        final task = tasksToDisplay[index];
        final today = DateFormat('dd/MM').format(DateTime.now());
        final selectedDate = DateFormat('dd/MM').format(task.dateTime);
        final timeFormat = DateFormat('HH:mm');
        final hasTimeSet = task.dateTime.hour != 0 || task.dateTime.minute != 0;
        final timeText =
            hasTimeSet ? ' • ${timeFormat.format(task.dateTime)}' : '';
        final showRepeatIcon = _shouldShowRepeatIcon(task);

        final isCompleted = task.isCompleted;
        final textColor = isCompleted ? Theme.of(context).textTheme.bodyMedium?.color: Theme.of(context).textTheme.bodyMedium?.color;
        final subtitleColor = isCompleted ? AppTheme.namedGrey : AppTheme.lightTheme.primaryColor;
        final reminderColor = isCompleted ? AppTheme.namedGrey : AppTheme.futureColor;
        final repeatColor = isCompleted ? AppTheme.namedGrey : AppTheme.lightTheme.secondaryHeaderColor;
       
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: AppTheme.boxColor2,
            borderRadius: BorderRadius.circular(20),
            
          ),
          child: ListTile(
            leading: GestureDetector(
              onTap: () {
                _playBellSound();
                Provider.of<TaskProvider>(context, listen: false)
                    .toggleCompletion(task.id);
              },
              child: Icon(
                task.isCompleted
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: isCompleted ? AppTheme.lightTheme.secondaryHeaderColor : AppTheme.namedGrey,
                size: 28,
              ),
            ),
            title: Text(
              task.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                decoration:
                    isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                color: textColor,
              ),
            ),
            subtitle: Row(
              children: [
                Text(
                  "$today - $selectedDate$timeText",
                  style: TextStyle(fontSize: 11, color: subtitleColor),
                ),
                if (task.isReminderOn)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Icon(Icons.alarm, size: 16, color: reminderColor),
                  ),
                if (showRepeatIcon)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: FaIcon(FontAwesomeIcons.repeat,
                        size: 13, color: repeatColor),
                  ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.edit, color:  AppTheme.futureColor),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/edit_task',
                  arguments: {'id': task.id, 'title': task.title},
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
