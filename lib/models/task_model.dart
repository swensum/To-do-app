class Task {
  final String id;
  final String title;
  final String category;
  final DateTime dateTime;
  final String? notes;
  final bool isReminderOn;
  final String? reminderOption;
  final String? repeatFrequency;
  final List<String> subtasks;
  List<String> subtasksCompleted;
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.category,
    required this.dateTime,
    this.notes,
    required this.isReminderOn,
    this.reminderOption,
    this.repeatFrequency = 'none',
    this.isCompleted = false,
    this.subtasks = const [],
    List<String>? subtasksCompleted,
  }) : subtasksCompleted = subtasksCompleted ?? [];
  

  void toggleCompletion() {
    isCompleted = !isCompleted;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'dateTime': dateTime.toIso8601String(),
      'notes': notes,
      'isReminderOn': isReminderOn ? 1 : 0,
      'reminderOption': reminderOption,
      'repeatFrequency': repeatFrequency,
      'isCompleted': isCompleted ? 1 : 0,
      'subtasks': subtasks.join('|'),
      'subtasksCompleted': subtasksCompleted.join('|'),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
  return Task(
    id: map['id'] ?? '',
    title: map['title'] ?? '',
    category: map['category'] ?? '',
    dateTime: DateTime.parse(map['dateTime']),
    notes: map['notes'],
    isReminderOn: (map['isReminderOn'] ?? 0) == 1,
    reminderOption: map['reminderOption'],
    repeatFrequency: map['repeatFrequency'] ?? 'none',
    isCompleted: (map['isCompleted'] ?? 0) == 1,
    subtasks: (map['subtasks'] ?? '')
        .toString()
        .split('|')
        .where((s) => s.isNotEmpty)
        .toList(),
    subtasksCompleted: (map['subtasksCompleted'] ?? '')
        .toString()
        .split('|')
        .where((s) => s.isNotEmpty)
        .toList(),
  );
}


  Task copyWith({
    String? id,
    String? title,
    String? category,
    DateTime? dateTime,
    String? notes,
    bool? isReminderOn,
    String? reminderOption,
    String? repeatFrequency,
    bool? isCompleted,
    List<String>? subtasks,
    List<String>? subtasksCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      dateTime: dateTime ?? this.dateTime,
      notes: notes ?? this.notes,
      isReminderOn: isReminderOn ?? this.isReminderOn,
      reminderOption: reminderOption ?? this.reminderOption,
      repeatFrequency: repeatFrequency ?? this.repeatFrequency,
      isCompleted: isCompleted ?? this.isCompleted,
      subtasks: subtasks ?? this.subtasks,
      subtasksCompleted: subtasksCompleted ?? this.subtasksCompleted,
    );
  }
}
