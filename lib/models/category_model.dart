import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final int taskCount;
  final int order;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.taskCount = 0,
    this.order = 0,
  });

  Category copyWith({
    String? id,
    String? name,
    IconData? icon,
    Color? color,
    int? taskCount,
    int? order,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      taskCount: taskCount ?? this.taskCount,
      order: order ?? this.order,
    );
  }
}

