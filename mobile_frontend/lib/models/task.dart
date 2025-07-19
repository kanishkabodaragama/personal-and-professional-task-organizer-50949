class Task {
  final int? id;
  final String title;
  final String description;
  final DateTime? dueDate;
  final String category;
  final String priority;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool hasReminder;
  final int reminderMinutes;

  const Task({
    this.id,
    required this.title,
    required this.description,
    this.dueDate,
    required this.category,
    required this.priority,
    this.isCompleted = false,
    required this.createdAt,
    required this.updatedAt,
    this.hasReminder = false,
    this.reminderMinutes = 60, // Default to 1 hour before
  });

  // PUBLIC_INTERFACE
  /// Creates a copy of the task with optional parameter overrides
  Task copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? dueDate,
    String? category,
    String? priority,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? hasReminder,
    int? reminderMinutes,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      hasReminder: hasReminder ?? this.hasReminder,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
    );
  }

  // PUBLIC_INTERFACE
  /// Converts the task to a Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate?.millisecondsSinceEpoch,
      'category': category,
      'priority': priority,
      'isCompleted': isCompleted ? 1 : 0,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'hasReminder': hasReminder ? 1 : 0,
      'reminderMinutes': reminderMinutes,
    };
  }

  // PUBLIC_INTERFACE
  /// Creates a Task instance from a Map (typically from database)
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id']?.toInt(),
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      dueDate: map['dueDate'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['dueDate'])
          : null,
      category: map['category'] ?? '',
      priority: map['priority'] ?? '',
      isCompleted: (map['isCompleted'] ?? 0) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
      hasReminder: (map['hasReminder'] ?? 0) == 1,
      reminderMinutes: map['reminderMinutes'] ?? 60,
    );
  }

  @override
  String toString() {
    return 'Task{id: $id, title: $title, description: $description, dueDate: $dueDate, category: $category, priority: $priority, isCompleted: $isCompleted, createdAt: $createdAt, updatedAt: $updatedAt, hasReminder: $hasReminder, reminderMinutes: $reminderMinutes}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Task &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          description == other.description &&
          dueDate == other.dueDate &&
          category == other.category &&
          priority == other.priority &&
          isCompleted == other.isCompleted &&
          hasReminder == other.hasReminder &&
          reminderMinutes == other.reminderMinutes;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      description.hashCode ^
      dueDate.hashCode ^
      category.hashCode ^
      priority.hashCode ^
      isCompleted.hashCode ^
      hasReminder.hashCode ^
      reminderMinutes.hashCode;
}
