import 'package:flutter/material.dart';

enum TaskStatus {
  pending,
  completed,
  overdue,
}

class Task {
  final String id;
  final String title;
  final String project;
  final DateTime time;
  final TaskStatus status;
  final DateTime? dueDate;

  Task({
    required this.id,
    required this.title,
    required this.project,
    required this.time,
    this.status = TaskStatus.pending,
    this.dueDate,
  });
}

