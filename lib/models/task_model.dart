enum TaskStatus {
  pending,
  completed,
  overdue,
}

enum TaskPriority {
  high,
  medium,
  low,
  urgent,
}

class Task {
  final String id;
  final String title;
  final String? description;
  final String project;
  final DateTime time;
  final TaskStatus status;
  final DateTime? dueDate;
  final TaskPriority priority;
  final List<String> tags;
  final String? categoryId;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.project,
    required this.time,
    this.status = TaskStatus.pending,
    this.dueDate,
    this.priority = TaskPriority.medium,
    this.tags = const [],
    this.categoryId,
  });
}

