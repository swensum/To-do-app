import 'package:flutter/material.dart';
import 'package:todo_list/utils/theme.dart';

class RepeatPickerDialog extends StatefulWidget {
  final String initialRepeat;

  const RepeatPickerDialog({
    super.key,
    required this.initialRepeat,
  });

  @override
  State<RepeatPickerDialog> createState() => _RepeatPickerDialogState();
}

class _RepeatPickerDialogState extends State<RepeatPickerDialog> {
  late bool isRepeatEnabled;
  late String selectedOption;

  final List<String> repeatOptions = [
    'Hour',
    'Daily',
    'Weekly',
    'Monthly',
    'Yearly'
  ];

  @override
  void initState() {
    super.initState();
    isRepeatEnabled = widget.initialRepeat != 'No';
    selectedOption = isRepeatEnabled ? widget.initialRepeat : 'Daily';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      insetPadding:
          const EdgeInsets.symmetric(horizontal: 25.0, vertical: 24.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 100.0),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title & Switch
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Set as Repeat Task',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Switch(
                    value: isRepeatEnabled,
                    onChanged: (value) {
                      setState(() {
                        isRepeatEnabled = value;
                        if (value && selectedOption.isEmpty) {
                          selectedOption = repeatOptions.first;
                        }
                      });
                    },
                    activeColor: Theme.of(context).cardColor,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Repeat options row - Always visible but disabled when switch is off
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: repeatOptions.map((option) {
                    final isSelected = selectedOption == option;
                    return GestureDetector(
                      onTap: isRepeatEnabled
                          ? () {
                              setState(() {
                                selectedOption = option;
                              });
                            }
                          : null,
                      child: Opacity(
                        opacity: isRepeatEnabled ? 1.0 : 0.5,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected && isRepeatEnabled
                                ? Theme.of(context).cardColor
                                : AppTheme.dimmedCardColor2,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            option,
                            style: TextStyle(
                              color: isSelected && isRepeatEnabled
                                  ?  Theme.of(context).scaffoldBackgroundColor
                                  : Theme.of(context).textTheme.bodyMedium?.color,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),
              // Cancel and Done buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Cancel and return null
                    },
                    child: const Text(
                      'CANCEL',
                      style: TextStyle(color: AppTheme.dimmedCardColor),
                    ),
                  ),
                  const SizedBox(width: 5), // Increased spacing
                  TextButton(
                    onPressed: () {
                      Navigator.pop(
                          context, isRepeatEnabled ? selectedOption : 'No');
                    },
                    child: Text(
                      'DONE',
                      style: TextStyle(color: Theme.of(context).cardColor),
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
}
