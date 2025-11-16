import 'package:flutter/material.dart';

enum NotificationType {
  overdue,      // Quá hạn
  upcoming,     // Sắp tới hạn
  reminder,     // Nhắc nhở
  newTask,      // Công việc mới
}

class NotificationItem {
  final String id;
  final NotificationType type;
  final String title;
  final String description;
  final DateTime timestamp;
  final bool isRead;
  final Color? iconColor;
  final IconData icon;

  NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
    this.isRead = false,
    this.iconColor,
    required this.icon,
  });

  String getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      if (difference.inDays == 1) {
        return 'Hôm qua';
      }
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }

  Color getBackgroundColor() {
    // Một số notification có background xám nhạt, một số có background trắng
    if (type == NotificationType.overdue || type == NotificationType.upcoming) {
      return const Color(0xFFF3F4F6); // Light grey
    }
    return Colors.white;
  }
}

