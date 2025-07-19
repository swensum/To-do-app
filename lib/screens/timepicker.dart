import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:todo_list/utils/theme.dart';

class CustomTimePicker {
  static Future<TimeOfDay?> show({
    required BuildContext context,
    TimeOfDay? initialTime,
    bool includeNoTimeOption = true,
  }) async {
    return await showDialog<TimeOfDay?>(
      context: context,
      builder: (BuildContext context) {
       
        DateTime selectedDateTime = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          initialTime?.hour ?? TimeOfDay.now().hour,
          initialTime?.minute ?? TimeOfDay.now().minute,
        );

       
        bool isNoTimeSelected = initialTime == null && includeNoTimeOption;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            final predefinedTimes = [
              TimeOfDay(hour: 7, minute: 0),
              TimeOfDay(hour: 9, minute: 0),
              TimeOfDay(hour: 12, minute: 0),
              TimeOfDay(hour: 14, minute: 0),
              TimeOfDay(hour: 16, minute: 0),
              TimeOfDay(hour: 18, minute: 0),
              TimeOfDay(hour: 20, minute: 0),
            ];

            return Dialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: 400,
                  maxWidth: 500,
              
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(15, 15, 15, 2),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Set Time',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 200,
                        child: CupertinoTheme(
                          data: const CupertinoThemeData(
                            brightness: Brightness.light,
                          ),
                          child: StatefulBuilder(
                            builder: (context, innerSetState) {
                              return CupertinoDatePicker(
                                key: ValueKey(selectedDateTime.toString()),
                                mode: CupertinoDatePickerMode.time,
                                initialDateTime: selectedDateTime,
                                onDateTimeChanged: (DateTime newDateTime) {
                                  setState(() {
                                    selectedDateTime = newDateTime;
                                    isNoTimeSelected = false;
                                  });
                                },
                              );
                            },
                            
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.start,
                        children: [
                          if (includeNoTimeOption)
                            SizedBox(
                              width: 80,
                              child: TextButton(
                                onPressed: () {
                                  setState(() {
                                    isNoTimeSelected = true;
                                  });
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: isNoTimeSelected
                                      ?  Theme.of(context).cardColor
                                      : AppTheme.dimmedCardColor2,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  'No time',
                                  style: TextStyle(
                                    color: isNoTimeSelected
                                        ? Theme.of(context).scaffoldBackgroundColor
                                        : Theme.of(context).textTheme.bodyMedium?.color,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ...predefinedTimes.map((time) {
                            bool isSelected = !isNoTimeSelected &&
                                selectedDateTime.hour == time.hour &&
                                selectedDateTime.minute == time.minute;
                            return SizedBox(
                              width: 70,
                              child: TextButton(
                                onPressed: () {
                                  setState(() {
                                    selectedDateTime = DateTime(
                                      selectedDateTime.year,
                                      selectedDateTime.month,
                                      selectedDateTime.day,
                                      time.hour,
                                      time.minute,
                                    );
                                    isNoTimeSelected = false;
                                  });
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: isSelected
                                      ? Theme.of(context).cardColor
                                      : AppTheme.dimmedCardColor2,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  '${time.hour}:${time.minute.toString().padLeft(2, '0')}',
                                  style: TextStyle(
                                    color: isSelected
                                        ? Theme.of(context).scaffoldBackgroundColor
                                        : Theme.of(context).textTheme.bodyMedium?.color,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text(
                              'CANCEL',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: AppTheme.dimmedCardColor,),
                            ),
                          ),
                          const SizedBox(width: 10),
                          TextButton(
                            onPressed: () {
                              final pickedTime = isNoTimeSelected
                                  ? null
                                  : TimeOfDay.fromDateTime(selectedDateTime);
                              Navigator.of(context).pop(pickedTime);
                            },
                            child: const Text(
                              'DONE',
                              style:
                                  TextStyle(fontSize: 16, color:Color.fromARGB(156, 25, 49, 183)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
